# Firebase Cloud Functions Implementation

## Backend Services for Job Sharing Feature

---

## 📋 Overview

This file contains the complete Cloud Functions implementation for the job sharing feature, including email services, notifications, analytics, and webhook handlers.

---

## 🚀 Setup Instructions

```bash
# Navigate to functions directory
cd functions

# Initialize if not already done
firebase init functions

# Install dependencies
npm install --save nodemailer @sendgrid/mail twilio firebase-admin firebase-functions cors express

# Install dev dependencies
npm install --save-dev @types/node typescript eslint

# Deploy functions
firebase deploy --only functions
```

---

## 📦 Package.json

```json
{
  "name": "journeyman-jobs-functions",
  "version": "1.0.0",
  "description": "Cloud Functions for Journeyman Jobs",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "shell": "npm run build && firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log",
    "test": "jest"
  },
  "engines": {
    "node": "18"
  },
  "main": "lib/index.js",
  "dependencies": {
    "@sendgrid/mail": "^7.7.0",
    "cors": "^2.8.5",
    "express": "^4.18.2",
    "firebase-admin": "^11.11.0",
    "firebase-functions": "^4.5.0",
    "nodemailer": "^6.9.7",
    "twilio": "^4.19.0"
  },
  "devDependencies": {
    "@types/cors": "^2.8.15",
    "@types/express": "^4.17.20",
    "@types/node": "^20.8.10",
    "@typescript-eslint/eslint-plugin": "^6.9.1",
    "@typescript-eslint/parser": "^6.9.1",
    "eslint": "^8.52.0",
    "eslint-config-google": "^0.14.0",
    "eslint-plugin-import": "^2.29.0",
    "jest": "^29.7.0",
    "typescript": "^5.2.2"
  },
  "private": true
}
```

---

## 📝 Main Index File

**File: `functions/src/index.ts`**

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as express from 'express';
import * as cors from 'cors';

// Initialize Firebase Admin
admin.initializeApp();

// Import function modules
import { emailFunctions } from './email';
import { notificationFunctions } from './notifications';
import { analyticsFunctions } from './analytics';
import { shareFunctions } from './shares';
import { userFunctions } from './users';
import { webhookFunctions } from './webhooks';

// Initialize Express app for HTTP endpoints
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Export all functions
export const sendJobShareEmail = emailFunctions.sendJobShareEmail;
export const sendBulkShareEmails = emailFunctions.sendBulkShareEmails;
export const sendShareSMS = emailFunctions.sendShareSMS;

export const onNotificationCreated = notificationFunctions.onNotificationCreated;
export const sendPushNotification = notificationFunctions.sendPushNotification;
export const sendBulkNotifications = notificationFunctions.sendBulkNotifications;

export const trackShareEvent = analyticsFunctions.trackShareEvent;
export const generateShareReport = analyticsFunctions.generateShareReport;
export const calculateShareMetrics = analyticsFunctions.calculateShareMetrics;

export const onShareCreated = shareFunctions.onShareCreated;
export const updateShareStatus = shareFunctions.updateShareStatus;
export const processShareConversion = shareFunctions.processShareConversion;

export const onUserSignup = userFunctions.onUserSignup;
export const processQuickSignup = userFunctions.processQuickSignup;
export const linkShareToUser = userFunctions.linkShareToUser;

export const handleShareWebhook = webhookFunctions.handleShareWebhook;
export const handleEmailWebhook = webhookFunctions.handleEmailWebhook;

// HTTP API endpoints
app.get('/share/:shareId', async (req, res) => {
  try {
    const shareId = req.params.shareId;
    const shareDoc = await admin.firestore()
      .collection('shares')
      .doc(shareId)
      .get();
    
    if (!shareDoc.exists) {
      return res.status(404).json({ error: 'Share not found' });
    }
    
    // Track view
    await trackShareEvent({
      event: 'share_viewed',
      shareId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    res.json({ success: true, data: shareDoc.data() });
  } catch (error) {
    console.error('Error fetching share:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Export Express app as Cloud Function
export const api = functions.https.onRequest(app);
```

---

## 📧 Email Functions

**File: `functions/src/email.ts`**

```typescript
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
const transporter = nodemailer.createTransport({
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
          await emailFunctions.sendJobShareEmail(
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
```

---

## 🔔 Notification Functions

**File: `functions/src/notifications.ts`**

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const notificationFunctions = {
  /**
   * Trigger when notification is created
   */
  onNotificationCreated: functions.firestore
    .document('notifications/{notificationId}')
    .onCreate(async (snap, context) => {
      const notification = snap.data();
      const notificationId = context.params.notificationId;
      
      try {
        // Get user's FCM token
        const userDoc = await admin.firestore()
          .collection('users')
          .doc(notification.userId)
          .get();
        
        if (!userDoc.exists) {
          console.log('User not found:', notification.userId);
          return;
        }
        
        const userData = userDoc.data();
        const fcmToken = userData?.fcmToken;
        
        if (!fcmToken) {
          console.log('No FCM token for user:', notification.userId);
          return;
        }
        
        // Check user's notification preferences
        const preferences = userData?.notificationPreferences || {};
        
        // Check if this type of notification is enabled
        if (notification.type === 'job_share' && preferences.jobShares === false) {
          return;
        }
        
        // Send push notification
        const message: admin.messaging.Message = {
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: {
            notificationId,
            type: notification.type,
            ...notification.data,
          },
          token: fcmToken,
          android: {
            priority: 'high',
            notification: {
              channelId: 'job_shares',
              clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
          apns: {
            payload: {
              aps: {
                badge: 1,
                sound: 'default',
              },
            },
          },
        };
        
        const response = await admin.messaging().send(message);
        console.log('Successfully sent push notification:', response);
        
        // Update notification with push status
        await snap.ref.update({
          pushSent: true,
          pushSentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        
      } catch (error) {
        console.error('Error sending push notification:', error);
        
        // Update notification with error
        await snap.ref.update({
          pushError: true,
          pushErrorMessage: (error as Error).message,
        });
      }
    }),
  
  /**
   * Send push notification manually
   */
  sendPushNotification: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { userId, title, body, data: notificationData } = data;
    
    try {
      // Get user's FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();
      
      if (!userDoc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'User not found'
        );
      }
      
      const fcmToken = userDoc.data()?.fcmToken;
      
      if (!fcmToken) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'User has no FCM token'
        );
      }
      
      const message: admin.messaging.Message = {
        notification: { title, body },
        data: notificationData || {},
        token: fcmToken,
      };
      
      const response = await admin.messaging().send(message);
      
      return { success: true, messageId: response };
      
    } catch (error) {
      console.error('Error sending push notification:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send push notification'
      );
    }
  }),
  
  /**
   * Send bulk notifications
   */
  sendBulkNotifications: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { userIds, title, body, data: notificationData } = data;
    
    // Get all user tokens
    const userDocs = await admin.firestore()
      .collection('users')
      .where(admin.firestore.FieldPath.documentId(), 'in', userIds)
      .get();
    
    const tokens: string[] = [];
    userDocs.forEach(doc => {
      const token = doc.data().fcmToken;
      if (token) tokens.push(token);
    });
    
    if (tokens.length === 0) {
      return { success: false, message: 'No valid tokens found' };
    }
    
    // Send multicast message
    const message: admin.messaging.MulticastMessage = {
      notification: { title, body },
      data: notificationData || {},
      tokens,
    };
    
    try {
      const response = await admin.messaging().sendMulticast(message);
      
      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
        responses: response.responses,
      };
      
    } catch (error) {
      console.error('Error sending bulk notifications:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send bulk notifications'
      );
    }
  }),
};
```

---

## 📊 Analytics Functions

**File: `functions/src/analytics.ts`**

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const analyticsFunctions = {
  /**
   * Track share events
   */
  trackShareEvent: functions.https.onCall(async (data, context) => {
    const { event, shareId, jobId, userId, metadata } = data;
    
    try {
      // Create analytics event
      await admin.firestore().collection('analytics').add({
        event,
        shareId,
        jobId,
        userId: userId || context.auth?.uid,
        metadata: metadata || {},
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        platform: 'web',
        version: '1.0.0',
      });
      
      // Update share metrics
      if (shareId) {
        const shareRef = admin.firestore()
          .collection('shares')
          .doc(shareId);
        
        const updates: any = {};
        
        switch (event) {
          case 'share_viewed':
            updates['metrics.views'] = admin.firestore.FieldValue.increment(1);
            break;
          case 'share_clicked':
            updates['metrics.clicks'] = admin.firestore.FieldValue.increment(1);
            break;
          case 'share_signup':
            updates['metrics.signups'] = admin.firestore.FieldValue.increment(1);
            break;
          case 'share_applied':
            updates['metrics.applies'] = admin.firestore.FieldValue.increment(1);
            break;
        }
        
        if (Object.keys(updates).length > 0) {
          await shareRef.update(updates);
        }
      }
      
      return { success: true };
      
    } catch (error) {
      console.error('Error tracking event:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to track event'
      );
    }
  }),
  
  /**
   * Generate share report
   */
  generateShareReport: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { startDate, endDate, userId } = data;
    
    try {
      // Query shares
      let query = admin.firestore()
        .collection('shares')
        .where('createdAt', '>=', new Date(startDate))
        .where('createdAt', '<=', new Date(endDate));
      
      if (userId) {
        query = query.where('sharerId', '==', userId);
      }
      
      const sharesSnapshot = await query.get();
      
      // Calculate metrics
      let totalShares = 0;
      let totalRecipients = 0;
      let totalViews = 0;
      let totalSignups = 0;
      let totalApplies = 0;
      
      const jobStats: { [key: string]: number } = {};
      const recipientTypes: { [key: string]: number } = {
        user: 0,
        email: 0,
        phone: 0,
      };
      
      sharesSnapshot.forEach(doc => {
        const share = doc.data();
        totalShares++;
        totalRecipients += share.recipients?.length || 0;
        totalViews += share.metrics?.views || 0;
        totalSignups += share.metrics?.signups || 0;
        totalApplies += share.metrics?.applies || 0;
        
        // Count by job
        const jobId = share.jobId;
        jobStats[jobId] = (jobStats[jobId] || 0) + 1;
        
        // Count recipient types
        share.recipients?.forEach((recipient: any) => {
          recipientTypes[recipient.type]++;
        });
      });
      
      // Calculate conversion rates
      const viewRate = totalRecipients > 0 
        ? (totalViews / totalRecipients * 100).toFixed(2) 
        : '0';
      const signupRate = totalViews > 0 
        ? (totalSignups / totalViews * 100).toFixed(2) 
        : '0';
      const applyRate = totalSignups > 0 
        ? (totalApplies / totalSignups * 100).toFixed(2) 
        : '0';
      
      // Get top shared jobs
      const topJobs = Object.entries(jobStats)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10)
        .map(([jobId, count]) => ({ jobId, shareCount: count }));
      
      return {
        period: { startDate, endDate },
        summary: {
          totalShares,
          totalRecipients,
          totalViews,
          totalSignups,
          totalApplies,
        },
        conversionRates: {
          viewRate: `${viewRate}%`,
          signupRate: `${signupRate}%`,
          applyRate: `${applyRate}%`,
        },
        recipientBreakdown: recipientTypes,
        topSharedJobs: topJobs,
        averageRecipientsPerShare: totalShares > 0 
          ? (totalRecipients / totalShares).toFixed(1) 
          : '0',
      };
      
    } catch (error) {
      console.error('Error generating report:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to generate report'
      );
    }
  }),
  
  /**
   * Calculate share metrics for dashboard
   */
  calculateShareMetrics: functions.pubsub
    .schedule('every 1 hours')
    .onRun(async (context) => {
      try {
        const now = new Date();
        const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        
        // Calculate daily metrics
        const dailyShares = await admin.firestore()
          .collection('shares')
          .where('createdAt', '>=', oneDayAgo)
          .get();
        
        // Calculate weekly metrics
        const weeklyShares = await admin.firestore()
          .collection('shares')
          .where('createdAt', '>=', oneWeekAgo)
          .get();
        
        // Store metrics
        await admin.firestore()
          .collection('metrics')
          .doc('shares')
          .set({
            daily: {
              shares: dailyShares.size,
              updated: admin.firestore.FieldValue.serverTimestamp(),
            },
            weekly: {
              shares: weeklyShares.size,
              updated: admin.firestore.FieldValue.serverTimestamp(),
            },
          }, { merge: true });
        
        console.log('Share metrics calculated successfully');
        
      } catch (error) {
        console.error('Error calculating metrics:', error);
      }
    }),
};
```

---

## 🔄 Share Processing Functions

**File: `functions/src/shares.ts`**

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const shareFunctions = {
  /**
   * Process new share creation
   */
  onShareCreated: functions.firestore
    .document('shares/{shareId}')
    .onCreate(async (snap, context) => {
      const share = snap.data();
      const shareId = context.params.shareId;
      
      try {
        // Process each recipient
        const promises = share.recipients.map(async (recipient: any) => {
          if (recipient.type === 'user' && recipient.userId) {
            // Create in-app notification for existing users
            await admin.firestore().collection('notifications').add({
              userId: recipient.userId,
              type: 'job_share',
              title: `${share.sharerName} shared a job with you`,
              body: `${share.jobSnapshot.title} at ${share.jobSnapshot.company}`,
              data: {
                shareId,
                jobId: share.jobId,
                sharerId: share.sharerId,
              },
              isRead: false,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
        });
        
        await Promise.all(promises);
        
        // Update sharer's stats
        await admin.firestore()
          .collection('users')
          .doc(share.sharerId)
          .update({
            'stats.totalShares': admin.firestore.FieldValue.increment(1),
            'stats.lastShareAt': admin.firestore.FieldValue.serverTimestamp(),
          });
        
        // Track share creation
        await admin.firestore().collection('analytics').add({
          event: 'share_created',
          shareId,
          jobId: share.jobId,
          sharerId: share.sharerId,
          recipientCount: share.recipients.length,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        
      } catch (error) {
        console.error('Error processing share creation:', error);
      }
    }),
  
  /**
   * Update share status
   */
  updateShareStatus: functions.https.onCall(async (data, context) => {
    const { shareId, recipientIdentifier, status, metadata } = data;
    
    try {
      const shareRef = admin.firestore()
        .collection('shares')
        .doc(shareId);
      
      const shareDoc = await shareRef.get();
      
      if (!shareDoc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Share not found'
        );
      }
      
      const share = shareDoc.data()!;
      const recipients = share.recipients || [];
      
      // Find and update recipient
      const recipientIndex = recipients.findIndex(
        (r: any) => r.identifier === recipientIdentifier
      );
      
      if (recipientIndex === -1) {
        throw new functions.https.HttpsError(
          'not-found',
          'Recipient not found'
        );
      }
      
      recipients[recipientIndex].status = status;
      recipients[recipientIndex][`${status}At`] = 
        admin.firestore.Timestamp.now();
      
      if (metadata) {
        recipients[recipientIndex].metadata = metadata;
      }
      
      // Update share document
      await shareRef.update({ recipients });
      
      // Track status change
      await admin.firestore().collection('analytics').add({
        event: `share_${status}`,
        shareId,
        recipientIdentifier,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return { success: true };
      
    } catch (error) {
      console.error('Error updating share status:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to update share status'
      );
    }
  }),
  
  /**
   * Process share conversion (signup/apply)
   */
  processShareConversion: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { shareId, conversionType } = data;
    const userId = context.auth.uid;
    
    try {
      // Update share metrics
      const shareRef = admin.firestore()
        .collection('shares')
        .doc(shareId);
      
      const updates: any = {};
      
      switch (conversionType) {
        case 'signup':
          updates['metrics.signups'] = admin.firestore.FieldValue.increment(1);
          updates['conversions.signups'] = admin.firestore.FieldValue.arrayUnion({
            userId,
            timestamp: admin.firestore.Timestamp.now(),
          });
          break;
          
        case 'apply':
          updates['metrics.applies'] = admin.firestore.FieldValue.increment(1);
          updates['conversions.applies'] = admin.firestore.FieldValue.arrayUnion({
            userId,
            timestamp: admin.firestore.Timestamp.now(),
          });
          break;
          
        case 'view':
          updates['metrics.views'] = admin.firestore.FieldValue.increment(1);
          break;
      }
      
      await shareRef.update(updates);
      
      // Track conversion
      await admin.firestore().collection('analytics').add({
        event: `share_conversion_${conversionType}`,
        shareId,
        userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      // Notify sharer of conversion (optional)
      if (conversionType === 'signup' || conversionType === 'apply') {
        const shareDoc = await shareRef.get();
        if (shareDoc.exists) {
          const share = shareDoc.data()!;
          
          await admin.firestore().collection('notifications').add({
            userId: share.sharerId,
            type: 'share_conversion',
            title: 'Your job share was successful!',
            body: `Someone ${conversionType === 'signup' ? 'signed up' : 'applied'} through your share`,
            data: { shareId, conversionType },
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
      
      return { success: true };
      
    } catch (error) {
      console.error('Error processing conversion:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to process conversion'
      );
    }
  }),
};
```

---

## 🧪 Function Tests

**File: `functions/src/__tests__/email.test.ts`**

```typescript
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions-test';
import { emailFunctions } from '../email';

const test = functions();

describe('Email Functions', () => {
  beforeAll(() => {
    admin.initializeApp();
  });
  
  afterAll(() => {
    test.cleanup();
  });
  
  describe('sendJobShareEmail', () => {
    it('should send email successfully', async () => {
      const wrapped = test.wrap(emailFunctions.sendJobShareEmail);
      
      const data = {
        to: 'test@example.com',
        sharerName: 'John Doe',
        job: {
          id: 'job123',
          title: 'Journeyman Lineman',
          company: 'Duke Energy',
          location: 'Charlotte, NC',
          hourlyRate: 48,
          perDiem: 150,
          duration: '3-6 months',
        },
        personalMessage: 'Check this out!',
        shareId: 'share123',
        signupLink: 'https://example.com/signup',
      };
      
      const context = {
        auth: { uid: 'user123' },
      };
      
      const result = await wrapped(data, context);
      expect(result.success).toBe(true);
    });
    
    it('should fail without authentication', async () => {
      const wrapped = test.wrap(emailFunctions.sendJobShareEmail);
      
      const data = { to: 'test@example.com' };
      const context = {};
      
      await expect(wrapped(data, context)).rejects.toThrow('unauthenticated');
    });
  });
});
```

---

## 🚀 Deployment Configuration

**File: `firebase.json`**

```json
{
  "functions": {
    "predeploy": [
      "npm --prefix \"$RESOURCE_DIR\" run build"
    ],
    "source": "functions",
    "runtime": "nodejs18"
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "/api/**",
        "function": "api"
      },
      {
        "source": "/share/**",
        "function": "api"
      },
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

---

## 📊 Firestore Indexes

**File: `firestore.indexes.json`**

```json
{
  "indexes": [
    {
      "collectionGroup": "shares",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "sharerId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "shares",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "jobId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "isRead", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "analytics",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "event", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## 🔐 Environment Configuration

**Set environment variables:**

```bash
# Set SendGrid API key
firebase functions:config:set sendgrid.api_key="YOUR_SENDGRID_API_KEY"

# Set email credentials (fallback)
firebase functions:config:set email.user="your-email@gmail.com"
firebase functions:config:set email.pass="your-app-password"

# Set Twilio credentials (optional)
firebase functions:config:set twilio.sid="YOUR_TWILIO_SID"
firebase functions:config:set twilio.auth="YOUR_TWILIO_AUTH"
firebase functions:config:set twilio.from="+1234567890"

# View configuration
firebase functions:config:get

# Deploy with configuration
firebase deploy --only functions
```

---

## 📋 Deployment Checklist

```dart
Pre-Deployment:
☐ All tests passing
☐ Environment variables set
☐ SendGrid account configured
☐ Firebase project selected
☐ Indexes created

Deployment:
☐ Run `npm run build` in functions directory
☐ Run `firebase deploy --only functions`
☐ Verify functions in Firebase Console
☐ Test each function endpoint
☐ Monitor logs for errors

Post-Deployment:
☐ Test email delivery
☐ Test push notifications
☐ Verify analytics tracking
☐ Check error reporting
☐ Set up monitoring alerts
```

---

*This completes the Firebase Cloud Functions implementation for the job sharing feature.*
