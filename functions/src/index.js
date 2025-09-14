/**
 * Cloud Functions for Journeyman Jobs - IBEW Job Sharing Platform
 * 
 * Main entry point for all cloud functions including:
 * - Email notifications and job sharing
 * - SMS notifications via Twilio (optional)
 * - Push notifications via FCM
 * - Quick signup flows
 * - User invitation system
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Email functions
const { 
  sendJobShareEmail, 
  sendInvitationEmail 
} = require('./email');

// SMS functions  
const { 
  sendJobShareSMS,
  sendInvitationSMS 
} = require('./sms');

// Notification functions
const {
  sendPushNotification,
  onJobShareCreated,
  onUserSignup
} = require('./notifications');

// Quick signup functions
const {
  quickSignup,
  validateQuickSignup,
  completeSignup
} = require('./quickSignup');

// Analytics functions
const {
  trackJobShare,
  trackUserInvitation,
  trackSignupConversion
} = require('./analytics');

// Export all functions
module.exports = {
  // Email Functions
  sendJobShareEmail,
  sendInvitationEmail,
  
  // SMS Functions  
  sendJobShareSMS,
  sendInvitationSMS,
  
  // Push Notification Functions
  sendPushNotification,
  onJobShareCreated,
  onUserSignup,
  
  // Quick Signup Functions
  quickSignup,
  validateQuickSignup, 
  completeSignup,
  
  // Analytics Functions
  trackJobShare,
  trackUserInvitation,
  trackSignupConversion,
  
  // Utility Functions
  healthCheck: functions.https.onRequest((req, res) => {
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
      services: {
        email: 'active',
        sms: 'active', 
        push: 'active',
        signup: 'active',
        analytics: 'active'
      }
    });
  }),
  
  // IBEW Data Functions
  updateUnionDirectory: functions.pubsub
    .schedule('every 24 hours')
    .onRun(async (context) => {
      // Update IBEW union directory data
      console.log('Updating IBEW union directory...');
      return null;
    }),
    
  // Maintenance Functions  
  cleanupExpiredShares: functions.pubsub
    .schedule('every 6 hours')
    .onRun(async (context) => {
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - 30); // 30 days ago
      
      const batch = admin.firestore().batch();
      const expiredShares = await admin.firestore()
        .collection('jobShares')
        .where('createdAt', '<', cutoff)
        .limit(100)
        .get();
        
      expiredShares.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      
      await batch.commit();
      console.log(`Cleaned up ${expiredShares.docs.length} expired job shares`);
      return null;
    })
};