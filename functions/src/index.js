/**
 * Cloud Functions for Journeyman Jobs - IBEW Job Sharing Platform
 * 
 * Main entry point for all cloud functions including:
 * - Email notifications and job sharing
 * - SMS notifications via Twilio (optional)
 * - Push notifications via FCM
 * - Quick signup flows
 * - User invitation system
 * - Crew communication and management
 * - Enhanced FCM notifications for crews
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

// Crew functions - Enhanced with FCM notifications
const {
  onCrewCreated,
  onMemberJoined,
  onMemberLeft,
  onJobSharedToCrew,
  onJobResponseUpdated,
  onCrewMessage,
  inviteCrewMembers,
  acceptCrewInvitation,
  validateUnionLocal,
  checkClassificationMatch,
  prioritizeStormWork,
  coordinateGroupBid,
  onCrewInvitationSent,
  onEmergencyAlert,
  // Enhanced FCM notification functions
  onJobSharedToCrewEnhanced,
  onCrewMemberAddedEnhanced,
  onCrewMessageSentEnhanced,
  sendCrewInvitationEmail
} = require('./crews');

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
  
  // Basic Crew Management Functions
  onCrewCreated,
  onMemberJoined,
  onMemberLeft,
  onJobSharedToCrew,
  onJobResponseUpdated,
  onCrewMessage,
  inviteCrewMembers,
  acceptCrewInvitation,
  
  // IBEW Protocol Functions
  validateUnionLocal,
  checkClassificationMatch,
  prioritizeStormWork,
  coordinateGroupBid,
  onCrewInvitationSent,
  onEmergencyAlert,
  
  // Enhanced FCM Notification Functions for Crew Features
  onJobSharedToCrewEnhanced,
  onCrewMemberAddedEnhanced,  
  onCrewMessageSentEnhanced,
  sendCrewInvitationEmail,
  
  // Utility Functions
  healthCheck: functions.https.onRequest((req, res) => {
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: '1.1.0',
      services: {
        email: 'active',
        sms: 'active', 
        push: 'active',
        signup: 'active',
        analytics: 'active',
        crews: 'active',
        fcm_enhanced: 'active'
      }
    });
  }),
  
  // FCM Token Management
  updateFCMToken: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
    }

    const { fcmToken } = data;
    const userId = context.auth.uid;

    try {
      // Update user's FCM token
      await admin.firestore().collection('users').doc(userId).update({
        fcmToken: fcmToken,
        fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      // Subscribe to relevant crew topics
      const userCrewsSnapshot = await admin.firestore()
        .collection(`users/${userId}/crewMemberships`)
        .get();

      const subscriptionPromises = userCrewsSnapshot.docs.map(async (crewDoc) => {
        const crewId = crewDoc.id;
        try {
          await admin.messaging().subscribeToTopic(fcmToken, `crew_${crewId}`);
          console.log(`Subscribed user ${userId} to crew_${crewId} topic`);
        } catch (error) {
          console.error(`Error subscribing to crew_${crewId}:`, error);
        }
      });

      await Promise.all(subscriptionPromises);

      return { 
        success: true, 
        subscribedToCrews: userCrewsSnapshot.docs.length,
        message: 'FCM token updated and crew subscriptions renewed'
      };

    } catch (error) {
      console.error('Error updating FCM token:', error);
      throw new functions.https.HttpsError('internal', 'Failed to update FCM token');
    }
  }),

  // Emergency Storm Work Notifications
  sendEmergencyStormAlert: functions.https.onCall(async (data, context) => {
    // Verify admin privileges
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
    }

    // TODO: Add admin role verification
    const { title, message, affectedStates, urgencyLevel = 'high' } = data;

    try {
      // Create emergency alert document (triggers onEmergencyAlert)
      const alertDoc = await admin.firestore().collection('emergencyAlerts').add({
        type: 'storm_work',
        title,
        description: message,
        affectedRegions: affectedStates,
        requiredClassifications: ['Journeyman Lineman', 'Tree Trimmer'],
        urgencyLevel,
        createdBy: context.auth.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'pending'
      });

      return { 
        success: true, 
        alertId: alertDoc.id,
        message: 'Emergency storm alert created and will be sent to eligible workers'
      };

    } catch (error) {
      console.error('Error creating emergency storm alert:', error);
      throw new functions.https.HttpsError('internal', 'Failed to create emergency alert');
    }
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
    }),

  // FCM Token Cleanup
  cleanupInvalidFCMTokens: functions.pubsub
    .schedule('every 7 days')
    .onRun(async (context) => {
      console.log('Starting FCM token cleanup...');
      
      const usersSnapshot = await admin.firestore()
        .collection('users')
        .where('fcmToken', '!=', null)
        .limit(1000)
        .get();

      let cleanedTokens = 0;
      const batch = admin.firestore().batch();

      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        if (userData.fcmToken) {
          try {
            // Test token validity by sending a dry run message
            await admin.messaging().send({
              token: userData.fcmToken,
              notification: { title: 'Test', body: 'Test' }
            }, true); // dry run
          } catch (error) {
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
              // Remove invalid token
              batch.update(userDoc.ref, {
                fcmToken: admin.firestore.FieldValue.delete(),
                fcmTokenInvalidatedAt: admin.firestore.FieldValue.serverTimestamp()
              });
              cleanedTokens++;
            }
          }
        }
      }

      if (cleanedTokens > 0) {
        await batch.commit();
      }

      console.log(`Cleaned up ${cleanedTokens} invalid FCM tokens`);
      return null;
    })
};
