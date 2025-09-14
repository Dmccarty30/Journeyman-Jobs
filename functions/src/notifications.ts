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
