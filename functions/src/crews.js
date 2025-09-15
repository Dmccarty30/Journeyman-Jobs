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
