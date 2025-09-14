import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as sgMail from '@sendgrid/mail';
import * as nodemailer from 'nodemailer';

// Initialize SendGrid
const sendgridApiKey = functions.config().sendgrid?.api_key;
if (sendgridApiKey) {
  sgMail.setApiKey(sendgridApiKey);
}

// Initialize Nodemailer (fallback)
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: functions.config().email?.user,
    pass: functions.config().email?.pass,
  },
});

export const emailFunctions = {
  /**
   * Send job share email to non-users
   */
  sendJobShareEmail: functions.https.onCall(async (data, context) => {
    const { to, sharerName, job, personalMessage, shareId, signupLink } = data;
    
    // Validate auth
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    // Create email content
    const subject = `${sharerName} shared a $${job.hourlyRate}/hr ${job.title} opportunity with you`;
    
    const htmlContent = generateShareEmailHTML({
      sharerName,
      job,
      personalMessage,
      signupLink,
    });
    
    const textContent = generateShareEmailText({
      sharerName,
      job,
      personalMessage,
      signupLink,
    });
    
    try {
      if (sendgridApiKey) {
        // Use SendGrid
        const msg = {
          to,
          from: 'noreply@journeymanjobs.com',
          subject,
          text: textContent,
          html: htmlContent,
          customArgs: {
            shareId,
            jobId: job.id,
          },
          trackingSettings: {
            clickTracking: { enable: true },
            openTracking: { enable: true },
          },
        };
        
        await sgMail.send(msg);
      } else {
        // Fallback to Nodemailer
        await transporter.sendMail({
          from: '"Journeyman Jobs" <noreply@journeymanjobs.com>',
          to,
          subject,
          text: textContent,
          html: htmlContent,
        });
      }
      
      // Log email sent
      await admin.firestore().collection('email_logs').add({
        to,
        type: 'job_share',
        shareId,
        jobId: job.id,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'sent',
      });
      
      return { success: true, message: 'Email sent successfully' };
      
    } catch (error: any) {
      console.error('Error sending email:', error);
      
      // Log error
      await admin.firestore().collection('email_logs').add({
        to,
        type: 'job_share',
        shareId,
        error: error.message,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'failed',
      });
      
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send email'
      );
    }
  }),
  
  /**
   * Send bulk share emails
   */
  sendBulkShareEmails: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { emails, sharerName, job, personalMessage, shareId } = data;
    const results: any[] = [];
    
    // Process in batches to avoid rate limits
    const batchSize = 10;
    for (let i = 0; i < emails.length; i += batchSize) {
      const batch = emails.slice(i, i + batchSize);
      
      const batchPromises = batch.map(async (email: string) => {
        try {
          await emailFunctions.sendJobShareEmail.handler(
            {
              to: email,
              sharerName,
              job,
              personalMessage,
              shareId,
              signupLink: `https://journeymanjobs.com/signup?share=${shareId}&job=${job.id}`,
            },
            context
          );
          return { email, success: true };
        } catch (error) {
          return { email, success: false, error };
        }
      });
      
      const batchResults = await Promise.all(batchPromises);
      results.push(...batchResults);
      
      // Delay between batches to avoid rate limits
      if (i + batchSize < emails.length) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
    
    return { success: true, results };
  }),
  
  /**
   * Send SMS notification (Twilio)
   */
  sendShareSMS: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { to, sharerName, job, shareId } = data;
    
    // Check if Twilio is configured
    const twilioSid = functions.config().twilio?.sid;
    const twilioAuth = functions.config().twilio?.auth;
    const twilioFrom = functions.config().twilio?.from;
    
    if (!twilioSid || !twilioAuth || !twilioFrom) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'SMS service not configured'
      );
    }
    
    const twilio = require('twilio')(twilioSid, twilioAuth);
    
    const message = `${sharerName} shared a job with you: ${job.title} at ${job.company} - $${job.hourlyRate}/hr. Sign up: https://jjobs.link/${shareId}`;
    
    try {
      const result = await twilio.messages.create({
        body: message,
        from: twilioFrom,
        to,
      });
      
      // Log SMS sent
      await admin.firestore().collection('sms_logs').add({
        to,
        type: 'job_share',
        shareId,
        messageId: result.sid,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'sent',
      });
      
      return { success: true, messageId: result.sid };
      
    } catch (error: any) {
      console.error('Error sending SMS:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send SMS'
      );
    }
  }),
};

/**
 * Generate HTML email content
 */
function generateShareEmailHTML(params: any): string {
  const { sharerName, job, personalMessage, signupLink } = params;
  
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Job Opportunity Shared With You</title>
      <style>
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 0;
          background-color: #f5f5f5;
        }
        .container {
          background-color: white;
          margin: 20px;
          border-radius: 8px;
          overflow: hidden;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header {
          background: linear-gradient(135deg, #2C3E50 0%, #34495E 100%);
          color: white;
          padding: 30px 20px;
          text-align: center;
        }
        .header h1 {
          margin: 0;
          font-size: 24px;
          font-weight: 600;
        }
        .header p {
          margin: 10px 0 0 0;
          opacity: 0.9;
          font-size: 16px;
        }
        .content {
          padding: 30px 20px;
        }
        .message-box {
          background: #FFF3CD;
          border-left: 4px solid #F39C12;
          padding: 15px;
          margin: 20px 0;
          border-radius: 4px;
        }
        .job-card {
          background: #f8f9fa;
          border: 1px solid #dee2e6;
          border-radius: 8px;
          padding: 20px;
          margin: 20px 0;
        }
        .job-title {
          font-size: 20px;
          font-weight: 600;
          color: #2C3E50;
          margin: 0 0 15px 0;
        }
        .job-company {
          font-size: 16px;
          color: #6c757d;
          margin: 0 0 15px 0;
        }
        .job-details {
          display: table;
          width: 100%;
          margin: 15px 0;
        }
        .job-detail {
          display: table-row;
        }
        .job-detail-label {
          display: table-cell;
          padding: 5px 10px 5px 0;
          font-weight: 600;
          color: #495057;
          white-space: nowrap;
        }
        .job-detail-value {
          display: table-cell;
          padding: 5px 0;
          color: #212529;
        }
        .highlight {
          color: #28a745;
          font-weight: 600;
        }
        .cta-button {
          display: inline-block;
          background: linear-gradient(135deg, #F39C12 0%, #E67E22 100%);
          color: white;
          padding: 14px 32px;
          text-decoration: none;
          border-radius: 6px;
          font-weight: 600;
          font-size: 16px;
          margin: 20px 0;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .cta-button:hover {
          background: linear-gradient(135deg, #E67E22 0%, #D35400 100%);
        }
        .center {
          text-align: center;
        }
        .footer {
          background: #f8f9fa;
          padding: 20px;
          text-align: center;
          color: #6c757d;
          font-size: 14px;
          border-top: 1px solid #dee2e6;
        }
        .footer a {
          color: #6c757d;
          text-decoration: underline;
        }
        .icon {
          display: inline-block;
          width: 20px;
          text-align: center;
          margin-right: 5px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>⚡ Journeyman Jobs</h1>
          <p>${sharerName} thinks you'd be perfect for this opportunity!</p>
        </div>
        
        <div class="content">
          ${personalMessage ? `
            <div class="message-box">
              <strong>Personal message from ${sharerName}:</strong><br>
              ${personalMessage}
            </div>
          ` : ''}
          
          <div class="job-card">
            <h2 class="job-title">${job.title}</h2>
            <p class="job-company">${job.company}</p>
            
            <div class="job-details">
              <div class="job-detail">
                <span class="job-detail-label">
                  <span class="icon">📍</span>Location:
                </span>
                <span class="job-detail-value">${job.location}</span>
              </div>
              
              <div class="job-detail">
                <span class="job-detail-label">
                  <span class="icon">💰</span>Hourly Rate:
                </span>
                <span class="job-detail-value highlight">$${job.hourlyRate}/hr</span>
              </div>
              
              ${job.perDiem ? `
                <div class="job-detail">
                  <span class="job-detail-label">
                    <span class="icon">🏨</span>Per Diem:
                  </span>
                  <span class="job-detail-value highlight">$${job.perDiem}/day</span>
                </div>
              ` : ''}
              
              <div class="job-detail">
                <span class="job-detail-label">
                  <span class="icon">⏱️</span>Duration:
                </span>
                <span class="job-detail-value">${job.duration}</span>
              </div>
            </div>
            
            ${job.description ? `
              <p style="margin-top: 15px; color: #495057;">
                ${job.description}
              </p>
            ` : ''}
          </div>
          
          <div class="center">
            <a href="${signupLink}" class="cta-button">
              Join & Apply in 2 Minutes →
            </a>
            
            <p style="color: #6c757d; margin: 20px 0;">
              Join thousands of skilled journeymen finding better opportunities through trusted referrals.
            </p>
          </div>
        </div>
        
        <div class="footer">
          <p>
            You received this email because ${sharerName} thought you'd be interested in this opportunity.
          </p>
          <p>
            <a href="${signupLink}&unsubscribe=true">Unsubscribe</a> | 
            <a href="https://journeymanjobs.com/privacy">Privacy Policy</a>
          </p>
          <p style="margin-top: 15px;">
            © 2024 Journeyman Jobs. All rights reserved.
          </p>
        </div>
      </div>
    </body>
    </html>
  `;
}

/**
 * Generate plain text email content
 */
function generateShareEmailText(params: any): string {
  const { sharerName, job, personalMessage, signupLink } = params;
  
  return `
${sharerName} shared a job opportunity with you!

${personalMessage ? `Message from ${sharerName}:\n${personalMessage}\n\n` : ''}

JOB DETAILS
-----------
Position: ${job.title}
Company: ${job.company}
Location: ${job.location}
Hourly Rate: $${job.hourlyRate}/hr
${job.perDiem ? `Per Diem: $${job.perDiem}/day\n` : ''}Duration: ${job.duration}

${job.description ? `\nDescription:\n${job.description}\n` : ''}

APPLY NOW
---------
Join and apply in just 2 minutes:
${signupLink}

Join thousands of skilled journeymen finding better opportunities through trusted referrals.

---
You received this email because ${sharerName} thought you'd be interested in this opportunity.
Unsubscribe: ${signupLink}&unsubscribe=true

© 2024 Journeyman Jobs. All rights reserved.
  `;
}
