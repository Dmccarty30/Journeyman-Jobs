const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * CREW CREATION AND MANAGEMENT FUNCTIONS
 */

// Create crew activity log when crew is created
exports.onCrewCreated = functions.firestore
  .document('crews/{crewId}')
  .onCreate(async (snap, context) => {
    const crewData = snap.data();
    const { crewId } = context.params;

    try {
      // Create initial activity log
      await db.collection(`crews/${crewId}/activity`).add({
        type: 'crew_created',
        actorId: crewData.leaderId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        data: {
          crewName: crewData.name,
          leaderId: crewData.leaderId
        },
        visibility: 'all'
      });

      // Add leader as first member
      await db.collection(`crews/${crewId}/members`).doc(crewData.leaderId).set({
        role: 'leader',
        joinedAt: admin.firestore.FieldValue.serverTimestamp(),
        lastActive: admin.firestore.FieldValue.serverTimestamp(),
        notificationPrefs: {
          jobShares: true,
          directMessages: true,
          crewUpdates: true
        }
      });

      // Add crew to user's membership list
      await db.collection(`users/${crewData.leaderId}/crewMemberships`).doc(crewId).set({
        role: 'leader',
        joinedAt: admin.firestore.FieldValue.serverTimestamp(),
        crewName: crewData.name
      });

      console.log(`Crew created: ${crewId} by ${crewData.leaderId}`);
    } catch (error) {
      console.error('Error in onCrewCreated:', error);
    }
  });

// Handle member joins
exports.onMemberJoined = functions.firestore
  .document('crews/{crewId}/members/{userId}')
  .onCreate(async (snap, context) => {
    const memberData = snap.data();
    const { crewId, userId } = context.params;

    try {
      // Get crew info
      const crewDoc = await db.collection('crews').doc(crewId).get();
      const crewData = crewDoc.data();

      // Create activity log
      await db.collection(`crews/${crewId}/activity`).add({
        type: 'member_joined',
        actorId: userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        data: {
          userId,
          role: memberData.role
        },
        visibility: 'all'
      });

      // Add crew to user's membership list
      await db.collection(`users/${userId}/crewMemberships`).doc(crewId).set({
        role: memberData.role,
        joinedAt: memberData.joinedAt,
        crewName: crewData.name
      });

      // Subscribe user to crew notifications
      const userDoc = await db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        if (userData.fcmToken) {
          await admin.messaging().subscribeToTopic(userData.fcmToken, `crew_${crewId}`);
          console.log(`Subscribed user ${userId} to crew_${crewId} notifications`);
        }
      }

      // Notify crew members about new member
      await sendCrewNotification(crewId, {
        title: 'New Crew Member',
        body: `A new member has joined your crew`,
        data: {
          type: 'member_joined',
          crewId,
          userId
        }
      }, userId); // Exclude the new member from notification

    } catch (error) {
      console.error('Error in onMemberJoined:', error);
    }
  });

// Handle member leaves
exports.onMemberLeft = functions.firestore
  .document('crews/{crewId}/members/{userId}')
  .onDelete(async (snap, context) => {
    const memberData = snap.data();
    const { crewId, userId } = context.params;

    try {
      // Create activity log
      await db.collection(`crews/${crewId}/activity`).add({
        type: 'member_left',
        actorId: userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        data: {
          userId,
          role: memberData.role
        },
        visibility: 'all'
      });

      // Remove crew from user's membership list
      await db.collection(`users/${userId}/crewMemberships`).doc(crewId).delete();

      // Unsubscribe user from crew notifications
      const userDoc = await db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        if (userData.fcmToken) {
          await admin.messaging().unsubscribeFromTopic(userData.fcmToken, `crew_${crewId}`);
          console.log(`Unsubscribed user ${userId} from crew_${crewId} notifications`);
        }
      }

      // Notify remaining crew members
      await sendCrewNotification(crewId, {
        title: 'Member Left Crew',
        body: `A crew member has left the crew`,
        data: {
          type: 'member_left',
          crewId,
          userId
        }
      });

    } catch (error) {
      console.error('Error in onMemberLeft:', error);
    }
  });

/**
 * JOB SHARING FUNCTIONS
 */

// Handle job notifications to crew
exports.onJobSharedToCrew = functions.firestore
  .document('crews/{crewId}/jobNotifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const { crewId, notificationId } = context.params;

    try {
      // Get crew info
      const crewDoc = await db.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) {
        console.error(`Crew ${crewId} not found`);
        return;
      }

      // Get sharer info
      const sharerDoc = await db.collection('users').doc(notification.sharedByUserId).get();
      const sharerData = sharerDoc.data();
      const sharerName = sharerData?.displayName || sharerData?.email || 'A crew member';

      // Create activity log
      await db.collection(`crews/${crewId}/activity`).add({
        type: 'job_shared',
        actorId: notification.sharedByUserId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        data: {
          jobId: notification.jobId,
          notificationId,
          message: notification.message
        },
        visibility: 'all'
      });

      // Send push notification to crew members
      await sendCrewNotification(crewId, {
        title: '⚡ New Job Opportunity',
        body: notification.message ? 
          `${sharerName}: ${notification.message}` : 
          `${sharerName} shared a job with the crew`,
        data: {
          type: 'crew_job_share',
          crewId,
          jobId: notification.jobId,
          notificationId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
      }, notification.sharedByUserId); // Exclude sharer

      console.log(`Job ${notification.jobId} shared to crew ${crewId}`);
    } catch (error) {
      console.error('Error in onJobSharedToCrew:', error);
    }
  });

// Handle member responses to job notifications
exports.onJobResponseUpdated = functions.firestore
  .document('crews/{crewId}/jobNotifications/{notificationId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const { crewId, notificationId } = context.params;

    try {
      // Check if member responses changed
      const beforeResponses = beforeData.memberResponses || {};
      const afterResponses = afterData.memberResponses || {};

      // Find new responses
      for (const userId in afterResponses) {
        if (!beforeResponses[userId] || beforeResponses[userId] !== afterResponses[userId]) {
          const response = afterResponses[userId];
          
          // Create activity log for response
          await db.collection(`crews/${crewId}/activity`).add({
            type: 'job_response',
            actorId: userId,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            data: {
              jobId: afterData.jobId,
              notificationId,
              response,
              sharedByUserId: afterData.sharedByUserId
            },
            visibility: 'all'
          });

          // Notify job sharer about response (if they want notifications)
          if (response === 'interested' || response === 'applied') {
            const responderDoc = await db.collection('users').doc(userId).get();
            const responderData = responderDoc.data();
            const responderName = responderData?.displayName || responderData?.email || 'A crew member';

            await sendUserNotification(afterData.sharedByUserId, {
              title: `Crew Response: ${response}`,
              body: `${responderName} is ${response} in the job you shared`,
              data: {
                type: 'job_response',
                crewId,
                jobId: afterData.jobId,
                responderId: userId,
                response
              }
            });
          }
        }
      }

    } catch (error) {
      console.error('Error in onJobResponseUpdated:', error);
    }
  });

/**
 * COMMUNICATION FUNCTIONS
 */

// Handle new crew messages
exports.onCrewMessage = functions.firestore
  .document('crews/{crewId}/communications/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const { crewId, messageId } = context.params;

    try {
      // Get sender info
      const senderDoc = await db.collection('users').doc(message.senderId).get();
      const senderData = senderDoc.data();
      const senderName = senderData?.displayName || senderData?.email || 'Crew Member';

      // Create activity log for important messages (not for every chat message to avoid spam)
      if (message.messageType === 'announcement' || message.messageType === 'urgent') {
        await db.collection(`crews/${crewId}/activity`).add({
          type: 'crew_message',
          actorId: message.senderId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          data: {
            messageId,
            messageType: message.messageType,
            content: message.content.substring(0, 100) // First 100 chars
          },
          visibility: 'all'
        });
      }

      // Send push notification for direct messages and urgent messages
      if (message.messageType === 'urgent' || message.messageType === 'announcement') {
        const priority = message.messageType === 'urgent' ? 'high' : 'normal';
        
        await sendCrewNotification(crewId, {
          title: message.messageType === 'urgent' ? 
            `🚨 Urgent: ${senderName}` : 
            `📢 ${senderName}`,
          body: message.content,
          data: {
            type: 'crew_message',
            crewId,
            messageId,
            senderId: message.senderId,
            messageType: message.messageType
          }
        }, message.senderId, priority);
      }

      console.log(`Message sent to crew ${crewId}: ${message.messageType}`);
    } catch (error) {
      console.error('Error in onCrewMessage:', error);
    }
  });

/**
 * UTILITY FUNCTIONS
 */

// Send notification to all crew members
async function sendCrewNotification(crewId, notification, excludeUserId = null, priority = 'normal') {
  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
        icon: 'crew_notification_icon',
      },
      data: notification.data,
      topic: `crew_${crewId}`,
      android: {
        priority: priority === 'high' ? 'high' : 'normal',
        notification: {
          channelId: 'crew_notifications',
          priority: priority === 'high' ? 'high' : 'default'
        }
      },
      apns: {
        payload: {
          aps: {
            priority: priority === 'high' ? 10 : 5,
            category: 'crew_notification'
          }
        }
      }
    };

    const response = await admin.messaging().send(message);
    console.log(`Crew notification sent successfully: ${response}`);
    
    return response;
  } catch (error) {
    console.error('Error sending crew notification:', error);
    throw error;
  }
}

// Send notification to specific user
async function sendUserNotification(userId, notification) {
  try {
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      console.log(`User ${userId} not found`);
      return;
    }

    const userData = userDoc.data();
    if (!userData.fcmToken) {
      console.log(`No FCM token for user ${userId}`);
      return;
    }

    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data,
      token: userData.fcmToken
    };

    const response = await admin.messaging().send(message);
    console.log(`User notification sent successfully: ${response}`);
    
    return response;
  } catch (error) {
    console.error('Error sending user notification:', error);
    throw error;
  }
}

/**
 * CREW INVITATION FUNCTIONS
 */

// HTTP function to invite members to crew (called from client)
exports.inviteCrewMembers = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated to invite members');
  }

  const { crewId, emails, inviteMessage } = data;
  const inviterId = context.auth.uid;

  try {
    // Verify inviter is crew leader
    const memberDoc = await db.collection(`crews/${crewId}/members`).doc(inviterId).get();
    if (!memberDoc.exists || memberDoc.data().role !== 'leader') {
      throw new functions.https.HttpsError('permission-denied', 'Only crew leaders can invite members');
    }

    // Get crew info
    const crewDoc = await db.collection('crews').doc(crewId).get();
    if (!crewDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Crew not found');
    }
    const crewData = crewDoc.data();

    // Send invitation emails (integrate with existing email service)
    const invitations = [];
    for (const email of emails) {
      const invitationId = db.collection('crewInvitations').doc().id;
      
      // Create invitation record
      await db.collection('crewInvitations').doc(invitationId).set({
        crewId,
        crewName: crewData.name,
        inviterUserId: inviterId,
        email,
        status: 'pending',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
        ),
        message: inviteMessage
      });

      invitations.push({
        email,
        invitationId,
        status: 'sent'
      });
    }

    // Create activity log
    await db.collection(`crews/${crewId}/activity`).add({
      type: 'members_invited',
      actorId: inviterId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      data: {
        emails,
        count: emails.length
      },
      visibility: 'leaders'
    });

    return {
      success: true,
      invitations
    };

  } catch (error) {
    console.error('Error in inviteCrewMembers:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send invitations');
  }
});

// HTTP function to accept crew invitation
exports.acceptCrewInvitation = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { invitationId } = data;
  const userId = context.auth.uid;

  try {
    // Get invitation
    const inviteDoc = await db.collection('crewInvitations').doc(invitationId).get();
    if (!inviteDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Invitation not found');
    }

    const inviteData = inviteDoc.data();
    
    // Check if invitation is still valid
    if (inviteData.status !== 'pending' || inviteData.expiresAt.toDate() < new Date()) {
      throw new functions.https.HttpsError('failed-precondition', 'Invitation expired or already used');
    }

    // Verify user email matches invitation
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    if (userData.email !== inviteData.email) {
      throw new functions.https.HttpsError('permission-denied', 'Email mismatch');
    }

    // Add user to crew
    await db.collection(`crews/${inviteData.crewId}/members`).doc(userId).set({
      role: 'member',
      joinedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastActive: admin.firestore.FieldValue.serverTimestamp(),
      invitedBy: inviteData.inviterUserId,
      notificationPrefs: {
        jobShares: true,
        directMessages: true,
        crewUpdates: true
      }
    });

    // Update invitation status
    await db.collection('crewInvitations').doc(invitationId).update({
      status: 'accepted',
      acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
      acceptedByUserId: userId
    });

    return {
      success: true,
      crewId: inviteData.crewId,
      crewName: inviteData.crewName
    };

  } catch (error) {
    console.error('Error in acceptCrewInvitation:', error);
    throw error;
  }
});
