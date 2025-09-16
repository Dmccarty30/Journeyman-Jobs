const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Note: Twilio is optional - only load if API key is configured
let twilioClient = null;
try {
  const twilio = require('twilio');
  const accountSid = functions.config().twilio?.account_sid;
  const authToken = functions.config().twilio?.auth_token;
  
  if (accountSid && authToken) {
    twilioClient = twilio(accountSid, authToken);
  }
} catch (error) {
  console.log('Twilio not configured - SMS functions will be disabled');
}

/**
 * Send job share SMS notification
 */
exports.sendJobShareSMS = functions.https.onCall(async (data, context) => {
  if (!twilioClient) {
    throw new functions.https.HttpsError('unavailable', 'SMS service not configured');
  }

  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { phoneNumber, jobId, shareId, message } = data;
  const senderId = context.auth.uid;

  try {
    // Get job details
    const jobDoc = await admin.firestore().collection('jobs').doc(jobId).get();
    if (!jobDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Job not found');
    }

    const jobData = jobDoc.data();
    
    // Get sender details
    const senderDoc = await admin.firestore().collection('users').doc(senderId).get();
    const senderData = senderDoc.data();
    const senderName = senderData?.displayName || senderData?.email || 'IBEW Member';

    // Create SMS message
    const deepLink = `https://journeymanjobs.app/job/${jobId}?utm_source=sms&utm_medium=sms&utm_campaign=job_share&share=${shareId}`;
    
    const baseMessage = `Job opportunity from ${senderName}: ${jobData.title} at ${jobData.union.local}`;
    const userMessage = message ? ` ${message}` : '';
    const linkText = ` View: ${deepLink}`;
    
    const smsText = jobData.isStormWork ?
      `🚨 STORM WORK ALERT from ${senderName}: ${jobData.title} at ${jobData.union.local}.${userMessage}${linkText}` :
      `⚡ ${baseMessage}.${userMessage}${linkText}`;

    // Send SMS
    const smsResponse = await twilioClient.messages.create({
      body: smsText,
      from: functions.config().twilio.phone_number,
      to: phoneNumber
    });

    // Log SMS for analytics
    await admin.firestore().collection('smsLogs').add({
      phoneNumber,
      jobId,
      shareId,
      senderId,
      messageSid: smsResponse.sid,
      status: smsResponse.status,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      type: 'job_share'
    });

    return { 
      success: true, 
      messageSid: smsResponse.sid,
      status: smsResponse.status 
    };

  } catch (error) {
    console.error('Error sending job share SMS:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send SMS');
  }
});

/**
 * Send invitation SMS to non-users
 */
exports.sendInvitationSMS = functions.https.onCall(async (data, context) => {
  if (!twilioClient) {
    throw new functions.https.HttpsError('unavailable', 'SMS service not configured');
  }

  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { phoneNumber, jobId, inviterName, message } = data;

  try {
    // Get job details
    const jobDoc = await admin.firestore().collection('jobs').doc(jobId).get();
    if (!jobDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Job not found');
    }

    const jobData = jobDoc.data();
    
    const signupLink = `https://journeymanjobs.app/signup?utm_source=sms_invitation&utm_medium=sms&job=${jobId}`;
    
    const userMessage = message ? ` ${message}` : '';
    const smsText = `⚡ ${inviterName} invited you to join IBEW's premier job network! Check out this opportunity: ${jobData.title} at ${jobData.union.local}.${userMessage} Join free: ${signupLink}`;

    // Send SMS
    const smsResponse = await twilioClient.messages.create({
      body: smsText,
      from: functions.config().twilio.phone_number,
      to: phoneNumber
    });

    // Log SMS for analytics
    await admin.firestore().collection('smsLogs').add({
      phoneNumber,
      jobId,
      inviterName,
      messageSid: smsResponse.sid,
      status: smsResponse.status,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      type: 'invitation'
    });

    return { 
      success: true, 
      messageSid: smsResponse.sid,
      status: smsResponse.status 
    };

  } catch (error) {
    console.error('Error sending invitation SMS:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send SMS');
  }
});

/**
 * Send emergency storm work SMS alert
 */
exports.sendEmergencyStormSMS = functions.https.onCall(async (data, context) => {
  if (!twilioClient) {
    throw new functions.https.HttpsError('unavailable', 'SMS service not configured');
  }

  // TODO: Add admin role verification
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { phoneNumbers, alertTitle, alertMessage, urgencyLevel = 'high' } = data;

  try {
    const smsText = `🚨 EMERGENCY STORM WORK ALERT: ${alertTitle}. ${alertMessage}. Respond immediately if available. - IBEW Jobs Network`;

    const smsPromises = phoneNumbers.map(async (phoneNumber) => {
      try {
        const smsResponse = await twilioClient.messages.create({
          body: smsText,
          from: functions.config().twilio.phone_number,
          to: phoneNumber
        });

        return { 
          phoneNumber, 
          success: true, 
          messageSid: smsResponse.sid,
          status: smsResponse.status 
        };
      } catch (error) {
        console.error(`Error sending emergency SMS to ${phoneNumber}:`, error);
        return { 
          phoneNumber, 
          success: false, 
          error: error.message 
        };
      }
    });

    const results = await Promise.all(smsPromises);
    const successCount = results.filter(r => r.success).length;
    const failureCount = results.filter(r => !r.success).length;

    // Log emergency SMS batch
    await admin.firestore().collection('emergencySMSLogs').add({
      alertTitle,
      targetCount: phoneNumbers.length,
      successCount,
      failureCount,
      urgencyLevel,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      results
    });

    return {
      success: true,
      totalSent: phoneNumbers.length,
      successCount,
      failureCount,
      results
    };

  } catch (error) {
    console.error('Error sending emergency storm SMS:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send emergency SMS');
  }
});
