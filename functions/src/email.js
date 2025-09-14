const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();
sgMail.setApiKey(functions.config().sendgrid.key);

/**
 * Send job share email notification
 * Triggered when a new job share document is created
 */
exports.sendJobShareEmail = functions.firestore
  .document('jobShares/{shareId}')
  .onCreate(async (snap, context) => {
    try {
      const shareData = snap.data();
      const shareId = context.params.shareId;
      
      // Get job details
      const jobDoc = await admin.firestore().collection('jobs').doc(shareData.jobId).get();
      if (!jobDoc.exists) {
        throw new Error(`Job ${shareData.jobId} not found`);
      }
      
      const jobData = jobDoc.data();
      
      // Get sender details
      const senderDoc = await admin.firestore().collection('users').doc(shareData.sharedBy).get();
      const senderData = senderDoc.exists ? senderDoc.data() : { displayName: 'IBEW Member' };
      
      // Generate deep link
      const deepLink = `https://journeymanjobs.app/job/${shareData.jobId}?utm_source=share&utm_medium=email&utm_campaign=job_share&utm_content=${shareId}`;
      
      // Create email template
      const emailTemplate = createJobShareEmailTemplate({
        job: jobData,
        sender: senderData,
        message: shareData.message || '',
        deepLink: deepLink,
        isStormWork: jobData.isStormWork || false
      });
      
      // Send to all recipients
      const sendPromises = shareData.recipients.map(async (recipient) => {
        const msg = {
          to: recipient.email,
          from: {
            email: 'jobs@journeymanjobs.app',
            name: 'Journeyman Jobs - IBEW Network'
          },
          subject: jobData.isStormWork 
            ? `🚨 STORM WORK: ${jobData.title} - ${jobData.union.local}` 
            : `⚡ Job Share: ${jobData.title} - ${jobData.union.local}`,
          html: emailTemplate,
          categories: ['job-share', jobData.isStormWork ? 'storm-work' : 'regular-job']
        };
        
        return sgMail.send(msg);
      });
      
      await Promise.all(sendPromises);
      
      // Update share status
      await snap.ref.update({
        status: 'delivered',
        deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
        deliveryCount: shareData.recipients.length
      });
      
      console.log(`Successfully sent job share emails for ${shareId}`);
      
    } catch (error) {
      console.error('Error sending job share email:', error);
      
      // Update share status to failed
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      throw error;
    }
  });

/**
 * Create HTML email template with electrical theme
 */
function createJobShareEmailTemplate({ job, sender, message, deepLink, isStormWork }) {
  const stormBadge = isStormWork ? `
    <div style="background: #dc2626; color: white; padding: 8px 16px; border-radius: 20px; display: inline-block; margin-bottom: 16px; font-weight: bold;">
      🚨 STORM RESTORATION WORK
    </div>
  ` : '';
  
  const urgentStyle = isStormWork ? 'border-left: 4px solid #dc2626;' : '';
  
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Job Share - Journeyman Jobs</title>
    </head>
    <body style="margin: 0; padding: 0; font-family: 'Inter', Arial, sans-serif; background-color: #f8fafc;">
      <div style="max-width: 600px; margin: 0 auto; background: white;">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%); padding: 24px; text-align: center;">
          <div style="color: #b45309; font-size: 24px; font-weight: bold; margin-bottom: 8px;">⚡ Journeyman Jobs</div>
          <div style="color: white; font-size: 16px;">IBEW Professional Network</div>
        </div>
        
        <!-- Content -->
        <div style="padding: 32px 24px;">
          ${stormBadge}
          
          <h1 style="color: #1a202c; margin: 0 0 16px 0; font-size: 24px;">New Job Opportunity Shared!</h1>
          
          <p style="color: #4a5568; margin: 0 0 24px 0; font-size: 16px; line-height: 1.5;">
            ${sender.displayName} shared a job opportunity with you:
          </p>
          
          ${message ? `
            <div style="background: #edf2f7; padding: 16px; border-radius: 8px; margin-bottom: 24px; ${urgentStyle}">
              <p style="margin: 0; color: #2d3748; font-style: italic;">"${message}"</p>
            </div>
          ` : ''}
          
          <!-- Job Details Card -->
          <div style="border: 2px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; ${urgentStyle}">
            <h2 style="color: #1a202c; margin: 0 0 16px 0; font-size: 20px;">${job.title}</h2>
            
            <div style="display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 16px;">
              <div style="background: #b45309; color: white; padding: 4px 12px; border-radius: 16px; font-size: 14px; font-weight: 500;">
                ${job.union.local}
              </div>
              <div style="background: #edf2f7; color: #2d3748; padding: 4px 12px; border-radius: 16px; font-size: 14px;">
                ${job.classification}
              </div>
              <div style="background: #edf2f7; color: #2d3748; padding: 4px 12px; border-radius: 16px; font-size: 14px;">
                ${job.constructionType}
              </div>
            </div>
            
            <div style="color: #4a5568; margin-bottom: 16px;">
              📍 ${job.location.city}, ${job.location.state}
            </div>
            
            ${job.payRate ? `
              <div style="color: #2d3748; font-weight: 600; margin-bottom: 16px;">
                💰 ${job.payRate}
              </div>
            ` : ''}
            
            ${job.description ? `
              <div style="color: #4a5568; line-height: 1.5; margin-bottom: 16px;">
                ${job.description.substring(0, 200)}${job.description.length > 200 ? '...' : ''}
              </div>
            ` : ''}
          </div>
          
          <!-- CTA Button -->
          <div style="text-align: center; margin: 32px 0;">
            <a href="${deepLink}" style="background: linear-gradient(135deg, #b45309 0%, #d69e2e 100%); color: white; padding: 16px 32px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 16px; display: inline-block; box-shadow: 0 4px 12px rgba(180, 83, 9, 0.3);">
              ⚡ View Job Details & Apply
            </a>
          </div>
          
          <div style="text-align: center; color: #718096; font-size: 14px; margin-top: 24px;">
            <p>Not an IBEW member yet? <a href="https://journeymanjobs.app/signup" style="color: #b45309;">Join the network</a> in under 2 minutes!</p>
          </div>
        </div>
        
        <!-- Footer -->
        <div style="background: #f7fafc; padding: 24px; text-align: center; border-top: 1px solid #e2e8f0;">
          <div style="color: #718096; font-size: 12px; margin-bottom: 8px;">
            Journeyman Jobs - Connecting IBEW Professionals
          </div>
          <div style="color: #a0aec0; font-size: 10px;">
            This job was shared through our professional network. <a href="#" style="color: #b45309;">Unsubscribe</a>
          </div>
        </div>
      </div>
    </body>
    </html>
  `;
}

/**
 * Send invitation email to non-users
 */
exports.sendInvitationEmail = functions.https.onCall(async (data, context) => {
  try {
    const { email, jobId, inviterName, message } = data;
    
    // Get job details
    const jobDoc = await admin.firestore().collection('jobs').doc(jobId).get();
    if (!jobDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Job not found');
    }
    
    const jobData = jobDoc.data();
    
    const signupLink = `https://journeymanjobs.app/signup?utm_source=invitation&utm_medium=email&utm_campaign=job_invitation&job=${jobId}`;
    
    const msg = {
      to: email,
      from: {
        email: 'invitations@journeymanjobs.app',
        name: 'Journeyman Jobs - IBEW Network'
      },
      subject: `⚡ You're invited to join IBEW's premier job network!`,
      html: createInvitationEmailTemplate({
        job: jobData,
        inviterName,
        message,
        signupLink
      }),
      categories: ['invitation', 'new-user']
    };
    
    await sgMail.send(msg);
    
    return { success: true, message: 'Invitation sent successfully' };
    
  } catch (error) {
    console.error('Error sending invitation email:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send invitation');
  }
});

function createInvitationEmailTemplate({ job, inviterName, message, signupLink }) {
  return `
    <!DOCTYPE html>
    <html>
    <body style="font-family: 'Inter', Arial, sans-serif; background-color: #f8fafc; margin: 0; padding: 0;">
      <div style="max-width: 600px; margin: 0 auto; background: white;">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%); padding: 32px 24px; text-align: center;">
          <div style="color: #b45309; font-size: 28px; font-weight: bold; margin-bottom: 8px;">⚡ Journeyman Jobs</div>
          <div style="color: white; font-size: 18px;">You're Invited to Join IBEW's Premier Job Network</div>
        </div>
        
        <div style="padding: 40px 24px;">
          <h1 style="color: #1a202c; font-size: 24px; margin: 0 0 20px 0;">Welcome to the Brotherhood!</h1>
          
          <p style="color: #4a5568; font-size: 16px; line-height: 1.6; margin-bottom: 24px;">
            ${inviterName} thinks you'd be perfect for this opportunity and has invited you to join Journeyman Jobs - 
            the exclusive job network for IBEW electrical professionals.
          </p>
          
          ${message ? `
            <div style="background: #edf2f7; padding: 20px; border-radius: 8px; margin-bottom: 24px; border-left: 4px solid #b45309;">
              <p style="margin: 0; color: #2d3748; font-style: italic;">"${message}"</p>
              <p style="margin: 8px 0 0 0; color: #718096; font-size: 14px;">- ${inviterName}</p>
            </div>
          ` : ''}
          
          <!-- Job Preview -->
          <div style="border: 2px solid #b45309; border-radius: 12px; padding: 24px; margin-bottom: 32px;">
            <h3 style="color: #1a202c; margin: 0 0 16px 0;">The Opportunity:</h3>
            <h2 style="color: #b45309; margin: 0 0 12px 0;">${job.title}</h2>
            <p style="color: #4a5568; margin: 0 0 12px 0;">📍 ${job.location.city}, ${job.location.state}</p>
            <p style="color: #4a5568; margin: 0;">🏛️ ${job.union.local} - ${job.classification}</p>
          </div>
          
          <!-- Benefits -->
          <div style="margin-bottom: 32px;">
            <h3 style="color: #1a202c; margin: 0 0 16px 0;">Why Join Journeyman Jobs?</h3>
            <ul style="color: #4a5568; padding-left: 20px;">
              <li>Access to exclusive IBEW job opportunities</li>
              <li>Connect with union locals across the country</li>
              <li>Storm work and emergency restoration alerts</li>
              <li>Professional networking with fellow electricians</li>
              <li>Free to join - built by electricians, for electricians</li>
            </ul>
          </div>
          
          <!-- CTA -->
          <div style="text-align: center; margin: 32px 0;">
            <a href="${signupLink}" style="background: linear-gradient(135deg, #b45309 0%, #d69e2e 100%); color: white; padding: 18px 36px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 18px; display: inline-block; box-shadow: 0 4px 16px rgba(180, 83, 9, 0.4);">
              ⚡ Join the Network - 2 Minutes
            </a>
          </div>
          
          <div style="text-align: center; color: #718096; font-size: 14px;">
            <p>Joining is quick, free, and gets you immediate access to this job and hundreds more!</p>
          </div>
        </div>
        
        <!-- Footer -->
        <div style="background: #f7fafc; padding: 24px; text-align: center; border-top: 1px solid #e2e8f0;">
          <div style="color: #718096; font-size: 12px; margin-bottom: 8px;">
            Journeyman Jobs - Connecting IBEW Professionals Nationwide
          </div>
          <div style="color: #a0aec0; font-size: 10px;">
            This invitation was sent by ${inviterName}. Not interested? Simply ignore this email.
          </div>
        </div>
      </div>
    </body>
    </html>
  `;
}