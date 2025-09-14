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
    await analyticsFunctions.trackShareEvent.handler({
      data: {
        event: 'share_viewed',
        shareId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      }
    } as any, {} as any);
    
    res.json({ success: true, data: shareDoc.data() });
  } catch (error) {
    console.error('Error fetching share:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Export Express app as Cloud Function
export const api = functions.https.onRequest(app);
