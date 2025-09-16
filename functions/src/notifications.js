const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * Send push notification to specific user
 */
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { userId, title, body, data: notificationData, priority = 'normal' } = data;
  
  try {
    // Get user's FCM token
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }
    
    const userData = userDoc.data();
    const fcmToken = userData?.fcmToken;
    
    if (!fcmToken) {
      throw new functions.https.HttpsError('failed-precondition', 'User has no FCM token');
    }
    
    // Check notification preferences
    const preferences = userData?.notificationPreferences || {};
    const notificationType = notificationData?.type || 'general';
    
    if (notificationType === 'job_share' && preferences.jobShares === false) {
      return { success: false, reason: 'User has disabled job share notifications' };
    }
    
    const message = {
      notification: { title, body },
      data: {
        timestamp: Date.now().toString(),
        ...notificationData
      },
      token: fcmToken,
      android: {
        priority: priority === 'high' ? 'high' : 'normal',
        notification: {
          channelId: getChannelId(notificationType),
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          priority: priority === 'high' ? 'high' : 'default',
          sound: getSoundForType(notificationType)
        }
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: getSoundForType(notificationType, 'ios'),
            priority: priority === 'high' ? 10 : 5,
            category: getChannelId(notificationType)
          }
        }
      }
    };
    
    const response = await admin.messaging().send(message);
    
    // Log notification for analytics
    await admin.firestore().collection('notificationLogs').add({
      userId,
      type: notificationType,
      title,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      messageId: response,
      success: true
    });
    
    return { success: true, messageId: response };
    
  } catch (error) {
    console.error('Error sending push notification:', error);
    
    // Log failed notification
    await admin.firestore().collection('notificationLogs').add({
      userId,
      type: notificationData?.type || 'general',
      title,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      success: false,
      error: error.message
    });
    
    throw new functions.https.HttpsError('internal', 'Failed to send push notification');
  }
});

/**
 * Trigger when a job share is created
 */
exports.onJobShareCreated = functions.firestore
  .document('jobShares/{shareId}')
  .onCreate(async (snap, context) => {
    const shareData = snap.data();
    const shareId = context.params.shareId;
    
    try {
      // Get job details
      const jobDoc = await admin.firestore().collection('jobs').doc(shareData.jobId).get();
      if (!jobDoc.exists) {
        console.error(`Job ${shareData.jobId} not found for share ${shareId}`);
        return;
      }
      
      const jobData = jobDoc.data();
      
      // Get sharer details
      const sharerDoc = await admin.firestore().collection('users').doc(shareData.sharedBy).get();
      const sharerData = sharerDoc.exists ? sharerDoc.data() : { displayName: 'IBEW Member' };
      
      // Send push notifications to recipients
      const notificationPromises = shareData.recipients.map(async (recipient) => {
        // Check if recipient is an existing user
        const recipientQuery = await admin.firestore()
          .collection('users')
          .where('email', '==', recipient.email)
          .limit(1)
          .get();
        
        if (!recipientQuery.empty) {
          const recipientDoc = recipientQuery.docs[0];
          const recipientData = recipientDoc.data();
          
          if (recipientData.fcmToken) {
            const title = jobData.isStormWork ? 
              `🚨 STORM WORK: ${jobData.title}` : 
              `⚡ New Job Shared: ${jobData.title}`;
            
            const body = shareData.message ? 
              `${sharerData.displayName}: ${shareData.message}` : 
              `${sharerData.displayName} shared a job opportunity with you`;
            
            const message = {
              notification: { title, body },
              data: {
                type: 'job_share',
                jobId: shareData.jobId,
                shareId,
                sharedBy: shareData.sharedBy,
                isStormWork: (jobData.isStormWork || false).toString(),
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
              },
              token: recipientData.fcmToken,
              android: {
                priority: jobData.isStormWork ? 'high' : 'normal',
                notification: {
                  channelId: jobData.isStormWork ? 'storm_alerts' : 'job_shares',
                  sound: jobData.isStormWork ? 'storm_alert' : 'job_share',
                  priority: jobData.isStormWork ? 'high' : 'default'
                }
              },
              apns: {
                payload: {
                  aps: {
                    badge: 1,
                    sound: jobData.isStormWork ? 'storm_alert.caf' : 'job_share.caf',
                    priority: jobData.isStormWork ? 10 : 5
                  }
                }
              }
            };
            
            await admin.messaging().send(message);
            console.log(`Job share notification sent to user ${recipientDoc.id}`);
          }
        }
      });
      
      await Promise.all(notificationPromises);
      
    } catch (error) {
      console.error('Error in onJobShareCreated:', error);
    }
  });

/**
 * Trigger when a user signs up
 */
exports.onUserSignup = functions.auth.user().onCreate(async (user) => {
  try {
    // Send welcome notification if user provides FCM token during signup
    const userDoc = await admin.firestore().collection('users').doc(user.uid).get();
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      
      if (userData.fcmToken) {
        const welcomeMessage = {
          notification: {
            title: 'Welcome to Journeyman Jobs! ⚡',
            body: 'You\'re now connected to IBEW\'s premier job network. Start exploring opportunities!'
          },
          data: {
            type: 'welcome',
            userId: user.uid,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          },
          token: userData.fcmToken,
          android: {
            notification: {
              channelId: 'user_updates',
              sound: 'welcome',
              icon: 'welcome_icon'
            }
          },
          apns: {
            payload: {
              aps: {
                sound: 'welcome.caf',
                category: 'welcome'
              }
            }
          }
        };
        
        await admin.messaging().send(welcomeMessage);
        console.log(`Welcome notification sent to new user ${user.uid}`);
      }
    }
    
  } catch (error) {
    console.error('Error in onUserSignup:', error);
  }
});

// Helper functions
function getChannelId(notificationType) {
  const channelMap = {
    'job_share': 'job_shares',
    'crew_job_share': 'crew_notifications',
    'crew_message': 'crew_notifications',
    'crew_welcome': 'crew_notifications',
    'member_joined': 'crew_notifications',
    'storm_work': 'storm_alerts',
    'emergency_alert': 'emergency_alerts',
    'welcome': 'user_updates',
    'general': 'general_notifications'
  };
  
  return channelMap[notificationType] || 'general_notifications';
}

function getSoundForType(notificationType, platform = 'android') {
  const soundMap = {
    android: {
      'job_share': 'job_share',
      'crew_job_share': 'crew_default',
      'crew_message': 'crew_default',
      'crew_welcome': 'crew_welcome',
      'storm_work': 'storm_alert',
      'emergency_alert': 'emergency_alert',
      'welcome': 'welcome',
      'general': 'default'
    },
    ios: {
      'job_share': 'job_share.caf',
      'crew_job_share': 'crew_default.caf',
      'crew_message': 'crew_default.caf',
      'crew_welcome': 'crew_welcome.caf',
      'storm_work': 'storm_alert.caf',
      'emergency_alert': 'emergency_alert.caf',
      'welcome': 'welcome.caf',
      'general': 'default'
    }
  };
  
  return soundMap[platform][notificationType] || soundMap[platform]['general'];
}
