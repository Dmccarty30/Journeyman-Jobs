import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Cloud Function: onCrewJobShare
 * Triggers when a job is shared to a crew
 * Sends push notifications to crew members
 */
export const onCrewJobShare = functions.firestore
  .document('crews/{crewId}/sharedJobs/{jobId}')
  .onCreate(async (snap, context) => {
    const { crewId, jobId } = context.params;
    const jobData = snap.data();
    
    try {
      // Get crew details
      const crewDoc = await db.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) {
        console.log(`Crew ${crewId} not found`);
        return null;
      }
      
      const crew = crewDoc.data();
      const memberIds = crew?.memberIds || [];
      
      // Get the user who shared the job
      const sharedBy = jobData.sharedBy || jobData.sharedByUserId;
      if (!sharedBy) {
        console.log('No sharedBy user found in job data');
        return null;
      }
      
      // Get job details
      const jobDoc = await db.collection('jobs').doc(jobId).get();
      const job = jobDoc.exists ? jobDoc.data() : null;
      
      // Get FCM tokens for all crew members except the sharer
      const tokens: string[] = [];
      const notificationPromises = [];
      
      for (const memberId of memberIds) {
        if (memberId === sharedBy) continue; // Don't notify the sharer
        
        // Get user's FCM tokens
        const userDoc = await db.collection('users').doc(memberId).get();
        const userData = userDoc.data();
        const userTokens = userData?.fcmTokens || [];
        
        if (userTokens.length > 0) {
          tokens.push(...userTokens);
        }
        
        // Create in-app notification
        const notification = {
          userId: memberId,
          type: 'job_shared',
          title: `New Job Shared in ${crew?.name || 'Crew'}`,
          body: `${job?.title || 'A job'} was shared by ${jobData.sharedByName || 'a crew member'}`,
          data: {
            crewId,
            jobId,
            sharedBy,
            notificationType: 'job_shared',
            clickAction: 'VIEW_JOB'
          },
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        };
        
        notificationPromises.push(
          db.collection('notifications').add(notification)
        );
      }
      
      // Send push notifications if we have tokens
      if (tokens.length > 0) {
        const message = {
          notification: {
            title: `New Job Shared in ${crew?.name || 'Crew'}`,
            body: `${job?.title || 'A job'} was shared by ${jobData.sharedByName || 'a crew member'}`
          },
          data: {
            crewId,
            jobId,
            sharedBy,
            notificationType: 'job_shared',
            clickAction: 'VIEW_JOB'
          },
          tokens
        };
        
        try {
          const response = await messaging.sendMulticast(message);
          console.log(`Sent notifications to ${response.successCount} users`);
        } catch (error) {
          console.error('Error sending push notifications:', error);
        }
      }
      
      // Create in-app notifications
      await Promise.all(notificationPromises);
      
      console.log(`Successfully processed job share for crew ${crewId}`);
      return null;
      
    } catch (error) {
      console.error('Error in onCrewJobShare:', error);
      return null;
    }
  });

/**
 * Cloud Function: onNewMessage
 * Triggers when a new message is sent in a crew chat
 * Sends push notifications to crew members
 */
export const onNewMessage = functions.firestore
  .document('crews/{crewId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const { crewId, messageId } = context.params;
    const messageData = snap.data();
    
    try {
      // Get crew details
      const crewDoc = await db.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) {
        console.log(`Crew ${crewId} not found`);
        return null;
      }
      
      const crew = crewDoc.data();
      const memberIds = crew?.memberIds || [];
      
      // Get the sender
      const senderId = messageData.senderId;
      if (!senderId) {
        console.log('No senderId found in message data');
        return null;
      }
      
      // Get sender details for notification
      const senderDoc = await db.collection('users').doc(senderId).get();
      const sender = senderDoc.data();
      
      // Get FCM tokens for all crew members except the sender
      const tokens: string[] = [];
      const notificationPromises = [];
      
      for (const memberId of memberIds) {
        if (memberId === senderId) continue; // Don't notify the sender
        
        // Get user's FCM tokens
        const userDoc = await db.collection('users').doc(memberId).get();
        const userData = userDoc.data();
        const userTokens = userData?.fcmTokens || [];
        
        if (userTokens.length > 0) {
          tokens.push(...userTokens);
        }
        
        // Create in-app notification
        const notification = {
          userId: memberId,
          type: 'new_message',
          title: `New message in ${crew?.name || 'Crew'}`,
          body: `${sender?.displayName || 'Someone'}: ${messageData.content}`,
          data: {
            crewId,
            messageId,
            senderId,
            notificationType: 'new_message',
            clickAction: 'VIEW_CHAT'
          },
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        };
        
        notificationPromises.push(
          db.collection('notifications').add(notification)
        );
      }
      
      // Send push notifications if we have tokens
      if (tokens.length > 0) {
        const message = {
          notification: {
            title: `New message in ${crew?.name || 'Crew'}`,
            body: `${sender?.displayName || 'Someone'}: ${messageData.content}`
          },
          data: {
            crewId,
            messageId,
            senderId,
            notificationType: 'new_message',
            clickAction: 'VIEW_CHAT'
          },
          tokens
        };
        
        try {
          const response = await messaging.sendMulticast(message);
          console.log(`Sent message notifications to ${response.successCount} users`);
        } catch (error) {
          console.error('Error sending message push notifications:', error);
        }
      }
      
      // Create in-app notifications
      await Promise.all(notificationPromises);
      
      console.log(`Successfully processed new message for crew ${crewId}`);
      return null;
      
    } catch (error) {
      console.error('Error in onNewMessage:', error);
      return null;
    }
  });

/**
 * Cloud Function: onMemberInvited
 * Triggers when a member is invited to a crew
 * Sends invitation notification
 */
export const onMemberInvited = functions.firestore
  .document('crews/{crewId}/members/{userId}')
  .onCreate(async (snap, context) => {
    const { crewId, userId } = context.params;
    const memberData = snap.data();
    
    try {
      // Get crew details
      const crewDoc = await db.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) {
        console.log(`Crew ${crewId} not found`);
        return null;
      }
      
      const crew = crewDoc.data();
      
      // Get inviter details
      const inviterId = memberData.invitedBy;
      if (!inviterId) {
        console.log('No inviter found in member data');
        return null;
      }
      
      const inviterDoc = await db.collection('users').doc(inviterId).get();
      const inviter = inviterDoc.data();
      
      // Get user's FCM tokens
      const userDoc = await db.collection('users').doc(userId).get();
      const userData = userDoc.data();
      const tokens = userData?.fcmTokens || [];
      
      // Create in-app notification
      const notification = {
        userId,
        type: 'crew_invitation',
        title: `Invitation to join ${crew?.name || 'Crew'}`,
        body: `${inviter?.displayName || 'Someone'} invited you to join their crew`,
        data: {
          crewId,
          inviterId,
          notificationType: 'crew_invitation',
          clickAction: 'VIEW_INVITATION'
        },
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      };
      
      await db.collection('notifications').add(notification);
      
      // Send push notification if we have tokens
      if (tokens.length > 0) {
        const message = {
          notification: {
            title: `Invitation to join ${crew?.name || 'Crew'}`,
            body: `${inviter?.displayName || 'Someone'} invited you to join their crew`
          },
          data: {
            crewId,
            inviterId,
            notificationType: 'crew_invitation',
            clickAction: 'VIEW_INVITATION'
          },
          tokens
        };
        
        try {
          const response = await messaging.sendMulticast(message);
          console.log(`Sent invitation notification to ${response.successCount} users`);
        } catch (error) {
          console.error('Error sending invitation push notification:', error);
        }
      }
      
      console.log(`Successfully processed member invitation for crew ${crewId}`);
      return null;
      
    } catch (error) {
      console.error('Error in onMemberInvited:', error);
      return null;
    }
  });

/**
 * Cloud Function: onActivityItemCreated
 * Triggers when a new activity item is created
 * Sends notifications for important activities
 */
export const onActivityItemCreated = functions.firestore
  .document('crews/{crewId}/tailboard/activity/{activityId}')
  .onCreate(async (snap, context) => {
    const { crewId, activityId } = context.params;
    const activityData = snap.data();
    
    try {
      // Only send notifications for certain activity types
      const notificationTypes = ['memberJoined', 'milestoneReached', 'jobApplied'];
      if (!notificationTypes.includes(activityData.type)) {
        return null;
      }
      
      // Get crew details
      const crewDoc = await db.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) {
        console.log(`Crew ${crewId} not found`);
        return null;
      }
      
      const crew = crewDoc.data();
      const memberIds = crew?.memberIds || [];
      
      // Get actor details
      const actorId = activityData.actorId;
      if (!actorId) {
        console.log('No actorId found in activity data');
        return null;
      }
      
      const actorDoc = await db.collection('users').doc(actorId).get();
      const actor = actorDoc.data();
      
      // Prepare notification based on activity type
      let title = '';
      let body = '';
      
      switch (activityData.type) {
        case 'memberJoined':
          title = `New member joined ${crew?.name || 'Crew'}`;
          body = `${actor?.displayName || 'Someone'} joined the crew`;
          break;
        case 'milestoneReached':
          title = `Milestone reached in ${crew?.name || 'Crew'}`;
          body = activityData.data?.milestoneDescription || 'A milestone was reached';
          break;
        case 'jobApplied':
          title = `Job application in ${crew?.name || 'Crew'}`;
          body = `${actor?.displayName || 'Someone'} applied to a shared job`;
          break;
      }
      
      // Get FCM tokens for all crew members except the actor
      const tokens: string[] = [];
      const notificationPromises = [];
      
      for (const memberId of memberIds) {
        if (memberId === actorId) continue; // Don't notify the actor
        
        // Get user's FCM tokens
        const userDoc = await db.collection('users').doc(memberId).get();
        const userData = userDoc.data();
        const userTokens = userData?.fcmTokens || [];
        
        if (userTokens.length > 0) {
          tokens.push(...userTokens);
        }
        
        // Create in-app notification
        const notification = {
          userId: memberId,
          type: 'activity_item',
          title,
          body,
          data: {
            crewId,
            activityId,
            activityType: activityData.type,
            notificationType: 'activity_item',
            clickAction: 'VIEW_ACTIVITY'
          },
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        };
        
        notificationPromises.push(
          db.collection('notifications').add(notification)
        );
      }
      
      // Send push notifications if we have tokens
      if (tokens.length > 0) {
        const message = {
          notification: { title, body },
          data: {
            crewId,
            activityId,
            activityType: activityData.type,
            notificationType: 'activity_item',
            clickAction: 'VIEW_ACTIVITY'
          },
          tokens
        };
        
        try {
          const response = await messaging.sendMulticast(message);
          console.log(`Sent activity notifications to ${response.successCount} users`);
        } catch (error) {
          console.error('Error sending activity push notifications:', error);
        }
      }
      
      // Create in-app notifications
      await Promise.all(notificationPromises);
      
      console.log(`Successfully processed activity item for crew ${crewId}`);
      return null;
      
    } catch (error) {
      console.error('Error in onActivityItemCreated:', error);
      return null;
    }
  });

/**
 * Scheduled function to clean up old notifications
 * Runs daily to remove notifications older than 30 days
 */
export const cleanupOldNotifications = functions.pubsub
  .schedule('0 2 * * *') // Run daily at 2 AM
  .timeZone('America/New_York')
  .onRun(async (context) => {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      const snapshot = await db.collection('notifications')
        .where('createdAt', '<', thirtyDaysAgo)
        .get();
      
      const batch = db.batch();
      let deletedCount = 0;
      
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        deletedCount++;
      });
      
      await batch.commit();
      
      console.log(`Deleted ${deletedCount} old notifications`);
      return null;

    } catch (error) {
      console.error('Error cleaning up old notifications:', error);
      return null;
    }
  });

// Stream Chat integration functions
export { getStreamUserToken, updateUserTeam } from './streamChat';