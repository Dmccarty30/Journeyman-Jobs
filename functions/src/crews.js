const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// IBEW Protocol Configuration
const IBEW_LOCALS = {
  // Key IBEW locals for validation - subset for performance
  1: { name: 'Local 1', jurisdiction: 'St. Louis, MO', territory: 'Missouri' },
  3: { name: 'Local 3', jurisdiction: 'New York, NY', territory: 'New York City' },
  11: { name: 'Local 11', jurisdiction: 'Los Angeles, CA', territory: 'Los Angeles County' },
  26: { name: 'Local 26', jurisdiction: 'Washington, DC', territory: 'Washington Metro' },
  46: { name: 'Local 46', jurisdiction: 'Seattle, WA', territory: 'Seattle Metro' },
  58: { name: 'Local 58', jurisdiction: 'Detroit, MI', territory: 'Detroit Metro' },
  98: { name: 'Local 98', jurisdiction: 'Philadelphia, PA', territory: 'Philadelphia Metro' },
  134: { name: 'Local 134', jurisdiction: 'Chicago, IL', territory: 'Chicago Metro' },
  145: { name: 'Local 145', jurisdiction: 'Rock Island, IL', territory: 'Quad Cities' },
  177: { name: 'Local 177', jurisdiction: 'Jacksonville, FL', territory: 'Northeast Florida' },
  // Add more as needed - this is a subset for validation
};

const VALID_CLASSIFICATIONS = [
  'Inside Wireman',
  'Journeyman Lineman',
  'Tree Trimmer',
  'Equipment Operator',
  'Inside Journeyman Electrician',
  'Apprentice Electrician',
  'Maintenance Electrician',
  'Telecommunications Technician'
];

const CONSTRUCTION_TYPES = [
  'Commercial',
  'Industrial',
  'Residential',
  'Utility',
  'Maintenance',
  'Storm Restoration',
  'Emergency Work'
];

/**
 * IBEW PROTOCOL VALIDATION FUNCTIONS
 */

// HTTP function to validate IBEW local number
exports.validateUnionLocal = functions.https.onCall(async (data, context) => {
  const { localNumber } = data;

  try {
    // First check our static list for common locals
    if (IBEW_LOCALS[localNumber]) {
      return {
        valid: true,
        local: IBEW_LOCALS[localNumber],
        source: 'verified'
      };
    }

    // For other locals, check Firestore directory if available
    const localDoc = await db.collection('ibewLocals').doc(localNumber.toString()).get();
    if (localDoc.exists) {
      return {
        valid: true,
        local: localDoc.data(),
        source: 'directory'
      };
    }

    // If not found, return invalid but allow with warning
    return {
      valid: false,
      warning: `Local ${localNumber} not found in directory. Please verify this is a valid IBEW local.`,
      allowWithWarning: true
    };

  } catch (error) {
    console.error('Error validating union local:', error);
    throw new functions.https.HttpsError('internal', 'Failed to validate union local');
  }
});

// Check if member classification matches job requirements
exports.checkClassificationMatch = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { jobId, memberId } = data;

  try {
    // Get job requirements
    const jobDoc = await db.collection('jobs').doc(jobId).get();
    if (!jobDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Job not found');
    }

    const jobData = jobDoc.data();

    // Get member profile
    const memberDoc = await db.collection('users').doc(memberId).get();
    if (!memberDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Member not found');
    }

    const memberData = memberDoc.data();

    // Check classification match
    const jobClassifications = Array.isArray(jobData.classification) ?
      jobData.classification : [jobData.classification];
    const memberClassifications = Array.isArray(memberData.classification) ?
      memberData.classification : [memberData.classification];

    const hasMatch = jobClassifications.some(jobClass =>
      memberClassifications.includes(jobClass)
    );

    // Additional checks for special requirements
    const checks = {
      classificationMatch: hasMatch,
      stormWorkQualified: memberData.stormWorkCertified || false,
      territoryValid: true, // TODO: Implement territory checking
      experienceLevel: memberData.experienceYears || 0,
      certifications: memberData.certifications || []
    };

    // Determine overall eligibility
    let eligible = checks.classificationMatch;
    let warnings = [];

    if (jobData.isStormWork && !checks.stormWorkQualified) {
      eligible = false;
      warnings.push('Storm work certification required');
    }

    if (jobData.minExperience && checks.experienceLevel < jobData.minExperience) {
      warnings.push(`Minimum ${jobData.minExperience} years experience required`);
    }

    return {
      eligible,
      checks,
      warnings,
      jobRequirements: {
        classifications: jobClassifications,
        isStormWork: jobData.isStormWork || false,
        minExperience: jobData.minExperience || 0
      }
    };

  } catch (error) {
    console.error('Error checking classification match:', error);
    throw error;
  }
});

// Prioritize storm work notifications
exports.prioritizeStormWork = functions.https.onCall(async (data, context) => {
  const { notification, recipients } = data;

  try {
    if (!notification.isStormWork) {
      return { priority: 'normal', urgencyLevel: 1 };
    }

    // Determine storm work priority based on severity and location
    let urgencyLevel = 2; // Default storm work priority
    let priority = 'high';

    // Check for emergency keywords
    const emergencyKeywords = ['hurricane', 'tornado', 'major outage', 'emergency', 'critical'];
    const hasEmergencyKeywords = emergencyKeywords.some(keyword =>
      notification.title.toLowerCase().includes(keyword) ||
      notification.description.toLowerCase().includes(keyword)
    );

    if (hasEmergencyKeywords) {
      urgencyLevel = 3;
      priority = 'urgent';
    }

    // Enhanced notification for storm work
    const enhancedNotification = {
      ...notification,
      title: `🚨 STORM WORK: ${notification.title}`,
      priority,
      urgencyLevel,
      isEmergency: urgencyLevel === 3,
      stormWorkBadge: true,
      expandedAlert: true
    };

    return {
      notification: enhancedNotification,
      priority,
      urgencyLevel,
      deliveryMethod: urgencyLevel === 3 ? 'immediate' : 'priority'
    };

  } catch (error) {
    console.error('Error prioritizing storm work:', error);
    throw new functions.https.HttpsError('internal', 'Failed to prioritize storm work');
  }
});

// Coordinate group bid submissions
exports.coordinateGroupBid = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { crewId, jobId, bidDetails } = data;
  const userId = context.auth.uid;

  try {
    // Verify user is crew member with bidding permission
    const memberDoc = await db.collection(`crews/${crewId}/members`).doc(userId).get();
    if (!memberDoc.exists) {
      throw new functions.https.HttpsError('permission-denied', 'Not a crew member');
    }

    const memberData = memberDoc.data();
    if (memberData.role !== 'leader' && !memberData.permissions?.canBid) {
      throw new functions.https.HttpsError('permission-denied', 'No bidding permission');
    }

    // Create group bid record
    const groupBidId = db.collection('groupBids').doc().id;
    const groupBid = {
      id: groupBidId,
      crewId,
      jobId,
      submittedBy: userId,
      submittedAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'submitted',
      bidDetails: {
        ...bidDetails,
        bidType: 'crew_bid',
        memberCount: bidDetails.memberCount || 1
      },
      crewMembers: bidDetails.participatingMembers || [userId]
    };

    await db.collection('groupBids').doc(groupBidId).set(groupBid);

    // Create crew activity log
    await db.collection(`crews/${crewId}/activity`).add({
      type: 'group_bid_submitted',
      actorId: userId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      data: {
        jobId,
        groupBidId,
        memberCount: bidDetails.memberCount
      },
      visibility: 'all'
    });

    // Notify crew members about bid submission
    await sendCrewNotification(crewId, {
      title: '🤝 Group Bid Submitted',
      body: `Crew bid submitted for job opportunity`,
      data: {
        type: 'group_bid_submitted',
        crewId,
        jobId,
        groupBidId
      }
    }, userId);

    return {
      success: true,
      groupBidId,
      status: 'submitted'
    };

  } catch (error) {
    console.error('Error coordinating group bid:', error);
    throw error;
  }
});

/**
 * NEW CREW NOTIFICATION TRIGGER FUNCTIONS
 */

// Trigger when crew invitation is sent
exports.onCrewInvitationSent = functions.firestore
  .document('crewInvitations/{invitationId}')
  .onCreate(async (snap, context) => {
    const invitation = snap.data();
    const { invitationId } = context.params;

    try {
      // Get crew details
      const crewDoc = await db.collection('crews').doc(invitation.crewId).get();
      if (!crewDoc.exists) {
        console.error(`Crew ${invitation.crewId} not found`);
        return;
      }
      const crewData = crewDoc.data();

      // Get inviter details
      const inviterDoc = await db.collection('users').doc(invitation.inviterUserId).get();
      const inviterData = inviterDoc.data();
      const inviterName = inviterData?.displayName || inviterData?.email || 'Crew Leader';

      // Send invitation email using existing email service
      const { sendInvitationEmail } = require('./email');

      // Check if invited user already exists
      const usersQuery = await db.collection('users')
        .where('email', '==', invitation.email)
        .limit(1)
        .get();

      if (!usersQuery.empty) {
        // Existing user - send crew invitation notification
        const existingUser = usersQuery.docs[0];
        const userData = existingUser.data();

        if (userData.fcmToken) {
          await admin.messaging().send({
            notification: {
              title: '⚡ Crew Invitation',
              body: `${inviterName} invited you to join ${crewData.name}`,
            },
            data: {
              type: 'crew_invitation',
              crewId: invitation.crewId,
              invitationId,
              click_action: 'FLUTTER_NOTIFICATION_CLICK'
            },
            token: userData.fcmToken
          });
        }

        // Also send email for important crew invitations
        await sendCrewInvitationEmail({
          email: invitation.email,
          crewName: crewData.name,
          inviterName,
          message: invitation.message,
          invitationId,
          isExistingUser: true
        });
      } else {
        // New user - send signup invitation email
        await sendCrewInvitationEmail({
          email: invitation.email,
          crewName: crewData.name,
          inviterName,
          message: invitation.message,
          invitationId,
          isExistingUser: false
        });
      }

      console.log(`Crew invitation sent: ${invitationId} to ${invitation.email}`);

    } catch (error) {
      console.error('Error in onCrewInvitationSent:', error);

      // Update invitation status to failed
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });

// Trigger for emergency alerts (storm work, urgent notifications)
exports.onEmergencyAlert = functions.firestore
  .document('emergencyAlerts/{alertId}')
  .onCreate(async (snap, context) => {
    const alert = snap.data();
    const { alertId } = context.params;

    try {
      // Determine affected areas and classifications
      const affectedRegions = alert.affectedRegions || [];
      const requiredClassifications = alert.requiredClassifications || [];

      // Query users in affected areas with required classifications
      let usersQuery = db.collection('users');

      if (affectedRegions.length > 0) {
        usersQuery = usersQuery.where('location.state', 'in', affectedRegions);
      }

      const eligibleUsers = await usersQuery.get();

      // Filter users by classification and availability
      const targetUsers = [];
      for (const userDoc of eligibleUsers.docs) {
        const userData = userDoc.data();

        // Check if user has required classification
        const userClassifications = Array.isArray(userData.classification) ?
          userData.classification : [userData.classification];

        const hasRequiredClassification = requiredClassifications.length === 0 ||
          requiredClassifications.some(req => userClassifications.includes(req));

        if (hasRequiredClassification && userData.fcmToken && userData.emergencyAlerts !== false) {
          targetUsers.push({
            userId: userDoc.id,
            fcmToken: userData.fcmToken,
            email: userData.email,
            classification: userClassifications
          });
        }
      }

      // Send high-priority notifications
      const notificationPromises = targetUsers.map(async (user) => {
        const message = {
          notification: {
            title: `🚨 ${alert.type.toUpperCase()}: ${alert.title}`,
            body: alert.description,
            icon: 'emergency_alert_icon',
          },
          data: {
            type: 'emergency_alert',
            alertId,
            urgencyLevel: '3',
            alertType: alert.type,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          },
          token: user.fcmToken,
          android: {
            priority: 'high',
            notification: {
              channelId: 'emergency_alerts',
              priority: 'high',
              sound: 'emergency_alert',
              vibrationPattern: [1000, 1000, 1000]
            }
          },
          apns: {
            payload: {
              aps: {
                priority: 10,
                sound: 'emergency_alert.caf',
                category: 'emergency_alert'
              }
            }
          }
        };

        try {
          await admin.messaging().send(message);
          return { userId: user.userId, status: 'sent' };
        } catch (error) {
          console.error(`Failed to send emergency alert to ${user.userId}:`, error);
          return { userId: user.userId, status: 'failed', error: error.message };
        }
      });

      const results = await Promise.all(notificationPromises);

      // Update alert with delivery statistics
      const successCount = results.filter(r => r.status === 'sent').length;
      const failureCount = results.filter(r => r.status === 'failed').length;

      await snap.ref.update({
        status: 'delivered',
        deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
        deliveryStats: {
          targetCount: targetUsers.length,
          successCount,
          failureCount,
          deliveryResults: results
        }
      });

      console.log(`Emergency alert ${alertId} sent to ${successCount}/${targetUsers.length} users`);

    } catch (error) {
      console.error('Error in onEmergencyAlert:', error);

      // Update alert status to failed
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });

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

/**
 * ENHANCED FCM NOTIFICATION FUNCTIONS
 */

// Enhanced crew notification function with retry logic and better error handling
async function sendCrewNotificationWithRetry(crewId, notification, excludeUserId = null, priority = 'normal', retries = 3) {
  try {
    // Get all crew members for targeted notifications
    const membersSnapshot = await db.collection(`crews/${crewId}/members`).get();
    const memberIds = membersSnapshot.docs
      .map(doc => doc.id)
      .filter(id => id !== excludeUserId);

    if (memberIds.length === 0) {
      console.log(`No members to notify in crew ${crewId}`);
      return { success: true, sentCount: 0 };
    }

    // Get user FCM tokens
    const usersSnapshot = await db.collection('users')
      .where(admin.firestore.FieldPath.documentId(), 'in', memberIds.slice(0, 10))
      .get();

    const tokens = [];
    const userTokenMap = {};
    
    usersSnapshot.docs.forEach(doc => {
      const userData = doc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
        userTokenMap[userData.fcmToken] = doc.id;
      }
    });

    if (tokens.length === 0) {
      console.log(`No valid FCM tokens found for crew ${crewId}`);
      return { success: true, sentCount: 0 };
    }

    // Create multicast message for better performance
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
        icon: 'crew_notification_icon',
      },
      data: {
        ...notification.data,
        timestamp: Date.now().toString()
      },
      android: {
        priority: priority === 'high' ? 'high' : 'normal',
        notification: {
          channelId: 'crew_notifications',
          priority: priority === 'high' ? 'high' : 'default',
          sound: priority === 'high' ? 'crew_urgent' : 'crew_default',
          tag: `crew_${crewId}_${notification.data.type || 'general'}`
        }
      },
      apns: {
        payload: {
          aps: {
            priority: priority === 'high' ? 10 : 5,
            category: 'crew_notification',
            sound: priority === 'high' ? 'crew_urgent.caf' : 'crew_default.caf',
            badge: 1
          }
        }
      },
      tokens: tokens
    };

    // Send multicast message
    const response = await admin.messaging().sendMulticast(message);
    
    // Handle failed tokens
    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const token = tokens[idx];
          const userId = userTokenMap[token];
          failedTokens.push({ token, userId, error: resp.error });
          
          // If token is invalid, remove it from user document
          if (resp.error?.code === 'messaging/invalid-registration-token' ||
              resp.error?.code === 'messaging/registration-token-not-registered') {
            db.collection('users').doc(userId).update({
              fcmToken: admin.firestore.FieldValue.delete()
            }).catch(err => console.error(`Error removing invalid token for user ${userId}:`, err));
          }
        }
      });
      
      console.error(`${response.failureCount} notifications failed for crew ${crewId}:`, failedTokens);
      
      // Retry with exponential backoff for retriable errors
      if (retries > 0 && response.failureCount < tokens.length) {
        await new Promise(resolve => setTimeout(resolve, (4 - retries) * 1000));
        return sendCrewNotificationWithRetry(crewId, notification, excludeUserId, priority, retries - 1);
      }
    }

    console.log(`Crew notification sent to ${response.successCount}/${tokens.length} members in crew ${crewId}`);
    
    // Log notification activity
    await db.collection(`crews/${crewId}/notifications`).add({
      type: notification.data.type || 'general',
      title: notification.title,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      targetCount: tokens.length,
      successCount: response.successCount,
      failureCount: response.failureCount,
      priority
    });

    return {
      success: true,
      sentCount: response.successCount,
      failedCount: response.failureCount,
      totalTargets: tokens.length
    };

  } catch (error) {
    console.error('Error sending crew notification with retry:', error);
    
    // Log error for debugging
    await db.collection(`crews/${crewId}/notifications`).add({
      type: 'error',
      error: error.message,
      failedAt: admin.firestore.FieldValue.serverTimestamp(),
      retryAttempt: 4 - retries
    }).catch(err => console.error('Error logging notification failure:', err));
    
    throw error;
  }
}

// Enhanced job shared to crew trigger
exports.onJobSharedToCrewEnhanced = functions.firestore
  .document('crews/{crewId}/jobNotifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const { crewId, notificationId } = context.params;

    try {
      // Get crew details
      const crewDoc = await db.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) {
        console.error(`Crew ${crewId} not found`);
        return;
      }
      const crewData = crewDoc.data();

      // Get job details
      const jobDoc = await db.collection('jobs').doc(notification.jobId).get();
      if (!jobDoc.exists) {
        console.error(`Job ${notification.jobId} not found`);
        return;
      }
      const jobData = jobDoc.data();

      // Get sharer details
      const sharerDoc = await db.collection('users').doc(notification.sharedByUserId).get();
      const sharerData = sharerDoc.data();
      const sharerName = sharerData?.displayName || sharerData?.email || 'A crew member';

      // Determine notification priority
      const isStormWork = jobData.isStormWork || false;
      const isUrgent = jobData.isUrgent || false;
      const priority = (isStormWork || isUrgent) ? 'high' : 'normal';

      // Create enhanced notification title and body
      const title = isStormWork ? 
        `🚨 STORM WORK: New Job Shared` : 
        `⚡ New Job Opportunity`;
      
      const body = notification.message ? 
        `${sharerName}: ${notification.message}` : 
        `${sharerName} shared "${jobData.title}" with your crew`;

      // Send enhanced push notification
      await sendCrewNotificationWithRetry(crewId, {
        title,
        body,
        data: {
          type: 'crew_job_share',
          crewId,
          crewName: crewData.name,
          jobId: notification.jobId,
          notificationId,
          sharedByUserId: notification.sharedByUserId,
          sharedByName: sharerName,
          isStormWork: isStormWork.toString(),
          isUrgent: isUrgent.toString(),
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
      }, notification.sharedByUserId, priority);

      // Create detailed activity log
      await db.collection(`crews/${crewId}/activity`).add({
        type: 'job_shared',
        actorId: notification.sharedByUserId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        data: {
          jobId: notification.jobId,
          jobTitle: jobData.title,
          jobLocation: `${jobData.location.city}, ${jobData.location.state}`,
          jobUnion: jobData.union.local,
          notificationId,
          message: notification.message,
          isStormWork,
          isUrgent,
          classification: jobData.classification
        },
        visibility: 'all'
      });

      // Track job sharing analytics
      await db.collection('analytics/jobSharing/events').add({
        eventType: 'crew_job_share',
        crewId,
        jobId: notification.jobId,
        sharedByUserId: notification.sharedByUserId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        metadata: {
          crewSize: crewData.memberCount || 0,
          jobType: jobData.constructionType,
          isStormWork,
          hasMessage: !!notification.message
        }
      });

      console.log(`Enhanced job ${notification.jobId} shared to crew ${crewId} with priority ${priority}`);

    } catch (error) {
      console.error('Error in onJobSharedToCrewEnhanced:', error);
      
      // Update notification with error status
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp()
      }).catch(err => console.error('Error updating notification status:', err));
    }
  });

// Enhanced crew member added trigger
exports.onCrewMemberAddedEnhanced = functions.firestore
  .document('crews/{crewId}/members/{userId}')
  .onCreate(async (snap, context) => {
    const memberData = snap.data();
    const { crewId, userId } = context.params;

    try {
      // Get crew details
      const crewDoc = await db.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) {
        console.error(`Crew ${crewId} not found`);
        return;
      }
      const crewData = crewDoc.data();

      // Get new member details
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        console.error(`User ${userId} not found`);
        return;
      }
      const userData = userDoc.data();
      const memberName = userData.displayName || userData.email || 'New Member';

      // Subscribe user to crew notifications
      if (userData.fcmToken) {
        try {
          await admin.messaging().subscribeToTopic(userData.fcmToken, `crew_${crewId}`);
          console.log(`Subscribed user ${userId} to crew_${crewId} topic`);
        } catch (error) {
          console.error(`Error subscribing user ${userId} to crew topic:`, error);
        }
      }

      // Send welcome notification to new member
      if (userData.fcmToken) {
        const welcomeMessage = {
          notification: {
            title: `Welcome to ${crewData.name}! ⚡`,
            body: `You've successfully joined the crew. Start collaborating on job opportunities!`
          },
          data: {
            type: 'crew_welcome',
            crewId,
            crewName: crewData.name,
            role: memberData.role,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          },
          token: userData.fcmToken,
          android: {
            notification: {
              channelId: 'crew_notifications',
              sound: 'crew_welcome',
              icon: 'crew_welcome_icon'
            }
          },
          apns: {
            payload: {
              aps: {
                category: 'crew_welcome',
                sound: 'crew_welcome.caf'
              }
            }
          }
        };

        await admin.messaging().send(welcomeMessage);
        console.log(`Welcome notification sent to new member ${userId}`);
      }

      // Notify existing crew members about new member
      await sendCrewNotificationWithRetry(crewId, {
        title: 'New Crew Member Joined! 🤝',
        body: `${memberName} has joined your crew`,
        data: {
          type: 'member_joined',
          crewId,
          crewName: crewData.name,
          newMemberId: userId,
          newMemberName: memberName,
          newMemberRole: memberData.role,
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
      }, userId); // Exclude the new member

      // Create detailed activity log
      await db.collection(`crews/${crewId}/activity`).add({
        type: 'member_joined',
        actorId: userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        data: {
          userId,
          memberName,
          role: memberData.role,
          invitedBy: memberData.invitedBy,
          classification: userData.classification,
          location: userData.location
        },
        visibility: 'all'
      });

      // Update crew member count
      await db.collection('crews').doc(crewId).update({
        memberCount: admin.firestore.FieldValue.increment(1),
        lastActivity: admin.firestore.FieldValue.serverTimestamp()
      });

      // Add crew to user's membership list
      await db.collection(`users/${userId}/crewMemberships`).doc(crewId).set({
        role: memberData.role,
        joinedAt: memberData.joinedAt,
        crewName: crewData.name,
        crewDescription: crewData.description,
        notifications: true
      });

      console.log(`Enhanced member ${userId} (${memberName}) joined crew ${crewId}`);

    } catch (error) {
      console.error('Error in onCrewMemberAddedEnhanced:', error);
    }
  });

// Enhanced crew message trigger
exports.onCrewMessageSentEnhanced = functions.firestore
  .document('crews/{crewId}/communications/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const { crewId, messageId } = context.params;

    try {
      // Get crew details
      const crewDoc = await db.collection('crews').doc(crewId).get();
      if (!crewDoc.exists) {
        console.error(`Crew ${crewId} not found`);
        return;
      }
      const crewData = crewDoc.data();

      // Get sender details
      const senderDoc = await db.collection('users').doc(message.senderId).get();
      if (!senderDoc.exists) {
        console.error(`Sender ${message.senderId} not found`);
        return;
      }
      const senderData = senderDoc.data();
      const senderName = senderData.displayName || senderData.email || 'Crew Member';

      // Determine notification priority and whether to send push notifications
      const shouldNotify = message.messageType === 'urgent' || 
                          message.messageType === 'announcement' ||
                          message.mentionedUsers?.length > 0;

      if (!shouldNotify) {
        console.log(`Message ${messageId} in crew ${crewId} doesn't require push notification`);
        return;
      }

      const priority = message.messageType === 'urgent' ? 'high' : 'normal';
      
      // Create notification title and body based on message type
      let title, body;
      if (message.messageType === 'urgent') {
        title = `🚨 Urgent Message from ${senderName}`;
        body = message.content;
      } else if (message.messageType === 'announcement') {
        title = `📢 Announcement from ${senderName}`;
        body = message.content;
      } else if (message.mentionedUsers?.length > 0) {
        title = `${senderName} mentioned you`;
        body = message.content;
      }

      // Send notification to crew members (or specific mentioned users)
      const targetUsers = message.mentionedUsers?.length > 0 ? 
        message.mentionedUsers : 
        null; // null means all crew members

      if (targetUsers) {
        // Send individual notifications to mentioned users
        for (const userId of targetUsers) {
          if (userId !== message.senderId) {
            await sendUserNotification(userId, {
              title,
              body,
              data: {
                type: 'crew_mention',
                crewId,
                crewName: crewData.name,
                messageId,
                senderId: message.senderId,
                senderName,
                messageType: message.messageType,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
              }
            });
          }
        }
      } else {
        // Send to all crew members
        await sendCrewNotificationWithRetry(crewId, {
          title,
          body,
          data: {
            type: 'crew_message',
            crewId,
            crewName: crewData.name,
            messageId,
            senderId: message.senderId,
            senderName,
            messageType: message.messageType,
            threadId: message.threadId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          }
        }, message.senderId, priority);
      }

      // Create activity log for important messages
      if (message.messageType === 'announcement' || message.messageType === 'urgent') {
        await db.collection(`crews/${crewId}/activity`).add({
          type: 'crew_message',
          actorId: message.senderId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          data: {
            messageId,
            messageType: message.messageType,
            content: message.content.substring(0, 100), // First 100 chars
            hasAttachment: message.attachments?.length > 0,
            mentionCount: message.mentionedUsers?.length || 0
          },
          visibility: 'all'
        });
      }

      // Update crew last activity
      await db.collection('crews').doc(crewId).update({
        lastActivity: admin.firestore.FieldValue.serverTimestamp(),
        lastMessage: {
          senderId: message.senderId,
          senderName,
          content: message.content.substring(0, 50),
          type: message.messageType,
          timestamp: message.timestamp
        }
      });

      console.log(`Enhanced message notification sent for ${messageId} in crew ${crewId} (type: ${message.messageType})`);

    } catch (error) {
      console.error('Error in onCrewMessageSentEnhanced:', error);
    }
  });

/**
 * CREW INVITATION EMAIL FUNCTION
 */

// Send crew invitation email (referenced in crew functions but was missing)
async function sendCrewInvitationEmail({ email, crewName, inviterName, message, invitationId, isExistingUser }) {
  try {
    const sgMail = require('@sendgrid/mail');
    
    const acceptLink = isExistingUser ?
      `https://journeymanjobs.app/crew/accept?invitation=${invitationId}` :
      `https://journeymanjobs.app/signup?invitation=${invitationId}&utm_source=crew_invitation&utm_medium=email`;

    const emailTemplate = createCrewInvitationEmailTemplate({
      crewName,
      inviterName,
      message,
      acceptLink,
      isExistingUser
    });

    const msg = {
      to: email,
      from: {
        email: 'crews@journeymanjobs.app',
        name: 'Journeyman Jobs - IBEW Crews'
      },
      subject: `⚡ You're invited to join ${crewName} on Journeyman Jobs`,
      html: emailTemplate,
      categories: ['crew-invitation', isExistingUser ? 'existing-user' : 'new-user']
    };

    await sgMail.send(msg);
    console.log(`Crew invitation email sent to ${email}`);

  } catch (error) {
    console.error('Error sending crew invitation email:', error);
    throw error;
  }
}

function createCrewInvitationEmailTemplate({ crewName, inviterName, message, acceptLink, isExistingUser }) {
  return `
    <!DOCTYPE html>
    <html>
    <body style="font-family: 'Inter', Arial, sans-serif; background-color: #f8fafc; margin: 0; padding: 0;">
      <div style="max-width: 600px; margin: 0 auto; background: white;">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%); padding: 32px 24px; text-align: center;">
          <div style="color: #b45309; font-size: 28px; font-weight: bold; margin-bottom: 8px;">⚡ Journeyman Jobs</div>
          <div style="color: white; font-size: 18px;">IBEW Crew Invitation</div>
        </div>
        
        <div style="padding: 40px 24px;">
          <h1 style="color: #1a202c; font-size: 24px; margin: 0 0 20px 0;">You're Invited to Join a Crew!</h1>
          
          <p style="color: #4a5568; font-size: 16px; line-height: 1.6; margin-bottom: 24px;">
            ${inviterName} has invited you to join <strong style="color: #b45309;">${crewName}</strong> on Journeyman Jobs.
          </p>
          
          ${message ? `
            <div style="background: #edf2f7; padding: 20px; border-radius: 8px; margin-bottom: 24px; border-left: 4px solid #b45309;">
              <p style="margin: 0; color: #2d3748; font-style: italic;">"${message}"</p>
              <p style="margin: 8px 0 0 0; color: #718096; font-size: 14px;">- ${inviterName}</p>
            </div>
          ` : ''}
          
          <!-- Benefits -->
          <div style="margin-bottom: 32px;">
            <h3 style="color: #1a202c; margin: 0 0 16px 0;">What are IBEW Crews?</h3>
            <ul style="color: #4a5568; padding-left: 20px; line-height: 1.6;">
              <li>Collaborate with trusted electrical professionals</li>
              <li>Share job opportunities within your crew</li>
              <li>Coordinate group bids and team applications</li>
              <li>Stay connected for storm work and emergency calls</li>
              <li>Build your professional network in the brotherhood</li>
            </ul>
          </div>
          
          <!-- CTA -->
          <div style="text-align: center; margin: 32px 0;">
            <a href="${acceptLink}" style="background: linear-gradient(135deg, #b45309 0%, #d69e2e 100%); color: white; padding: 18px 36px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 18px; display: inline-block; box-shadow: 0 4px 16px rgba(180, 83, 9, 0.4);">
              ${isExistingUser ? '🤝 Accept Invitation' : '⚡ Join Crew & Network'}
            </a>
          </div>
          
          <div style="text-align: center; color: #718096; font-size: 14px;">
            <p>${isExistingUser ? 'Click above to join the crew' : 'Joining creates your free account and adds you to the crew'}</p>
          </div>
        </div>
        
        <!-- Footer -->
        <div style="background: #f7fafc; padding: 24px; text-align: center; border-top: 1px solid #e2e8f0;">
          <div style="color: #718096; font-size: 12px; margin-bottom: 8px;">
            Journeyman Jobs - IBEW Professional Network
          </div>
          <div style="color: #a0aec0; font-size: 10px;">
            This invitation was sent by ${inviterName}. Questions? Reply to this email.
          </div>
        </div>
      </div>
    </body>
    </html>
  `;
}

// Export the email function for use in other modules
module.exports.sendCrewInvitationEmail = sendCrewInvitationEmail;
