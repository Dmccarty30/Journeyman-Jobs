const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * Quick signup for invited users
 */
exports.quickSignup = functions.https.onCall(async (data, context) => {
  const { email, phoneNumber, displayName, classification, localNumber, invitationToken } = data;

  try {
    // Validate invitation token if provided
    if (invitationToken) {
      const inviteDoc = await admin.firestore()
        .collection('invitations')
        .doc(invitationToken)
        .get();
      
      if (!inviteDoc.exists || inviteDoc.data().email !== email) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid invitation token');
      }
    }

    // Create user account
    const userRecord = await admin.auth().createUser({
      email,
      phoneNumber,
      displayName,
      emailVerified: false
    });

    // Create user profile
    const userProfile = {
      email,
      phoneNumber: phoneNumber || null,
      displayName,
      classification: classification || 'Inside Wireman',
      ibewLocal: localNumber || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      profileComplete: false,
      quickSignup: true,
      invitationToken: invitationToken || null,
      notificationPreferences: {
        jobShares: true,
        crewInvitations: true,
        stormAlerts: true,
        appUpdates: true
      }
    };

    await admin.firestore().collection('users').doc(userRecord.uid).set(userProfile);

    // Mark invitation as used
    if (invitationToken) {
      await admin.firestore()
        .collection('invitations')
        .doc(invitationToken)
        .update({
          status: 'accepted',
          acceptedBy: userRecord.uid,
          acceptedAt: admin.firestore.FieldValue.serverTimestamp()
        });
    }

    // Generate custom token for immediate login
    const customToken = await admin.auth().createCustomToken(userRecord.uid);

    return {
      success: true,
      userId: userRecord.uid,
      customToken,
      profileComplete: false
    };

  } catch (error) {
    console.error('Error in quickSignup:', error);
    throw new functions.https.HttpsError('internal', 'Failed to create account');
  }
});

/**
 * Validate quick signup data
 */
exports.validateQuickSignup = functions.https.onCall(async (data, context) => {
  const { email, phoneNumber, localNumber } = data;
  const validationErrors = [];

  try {
    // Check if email already exists
    try {
      await admin.auth().getUserByEmail(email);
      validationErrors.push('Email already registered');
    } catch (error) {
      // Email doesn't exist - this is good
    }

    // Check if phone number already exists
    if (phoneNumber) {
      try {
        await admin.auth().getUserByPhoneNumber(phoneNumber);
        validationErrors.push('Phone number already registered');
      } catch (error) {
        // Phone doesn't exist - this is good
      }
    }

    // Validate IBEW local number
    if (localNumber) {
      const localDoc = await admin.firestore()
        .collection('ibewLocals')
        .doc(localNumber.toString())
        .get();
      
      if (!localDoc.exists) {
        validationErrors.push('IBEW local number not found in directory');
      }
    }

    return {
      valid: validationErrors.length === 0,
      errors: validationErrors
    };

  } catch (error) {
    console.error('Error in validateQuickSignup:', error);
    throw new functions.https.HttpsError('internal', 'Validation failed');
  }
});

/**
 * Complete user profile after quick signup
 */
exports.completeSignup = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const userId = context.auth.uid;
  const { 
    location, 
    experienceYears, 
    certifications, 
    bio, 
    availability,
    fcmToken 
  } = data;

  try {
    const updateData = {
      location: location || null,
      experienceYears: experienceYears || 0,
      certifications: certifications || [],
      bio: bio || '',
      availability: availability || 'available',
      profileComplete: true,
      profileCompletedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    // Add FCM token if provided
    if (fcmToken) {
      updateData.fcmToken = fcmToken;
      updateData.fcmTokenUpdatedAt = admin.firestore.FieldValue.serverTimestamp();
    }

    await admin.firestore().collection('users').doc(userId).update(updateData);

    // Subscribe to general notifications if FCM token provided
    if (fcmToken) {
      try {
        await admin.messaging().subscribeToTopic(fcmToken, 'general_notifications');
        await admin.messaging().subscribeToTopic(fcmToken, 'storm_alerts');
        console.log(`Subscribed user ${userId} to general topics`);
      } catch (error) {
        console.error('Error subscribing to topics:', error);
      }
    }

    // Track signup completion for analytics
    await admin.firestore().collection('analytics/signups/events').add({
      userId,
      eventType: 'profile_completed',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      metadata: {
        experienceYears: experienceYears || 0,
        certificationsCount: (certifications || []).length,
        hasLocation: !!location,
        hasBio: !!bio,
        fcmTokenProvided: !!fcmToken
      }
    });

    return {
      success: true,
      profileComplete: true
    };

  } catch (error) {
    console.error('Error in completeSignup:', error);
    throw new functions.https.HttpsError('internal', 'Failed to complete profile');
  }
});

/**
 * Handle crew invitation signup flow
 */
exports.signupWithCrewInvitation = functions.https.onCall(async (data, context) => {
  const { invitationId, email, displayName, classification, localNumber, fcmToken } = data;

  try {
    // Get crew invitation
    const inviteDoc = await admin.firestore()
      .collection('crewInvitations')
      .doc(invitationId)
      .get();

    if (!inviteDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Invitation not found');
    }

    const inviteData = inviteDoc.data();

    if (inviteData.email !== email) {
      throw new functions.https.HttpsError('permission-denied', 'Email mismatch');
    }

    if (inviteData.status !== 'pending') {
      throw new functions.https.HttpsError('failed-precondition', 'Invitation already used or expired');
    }

    // Create user account
    const userRecord = await admin.auth().createUser({
      email,
      displayName,
      emailVerified: false
    });

    // Create user profile
    const userProfile = {
      email,
      displayName,
      classification: classification || 'Inside Wireman',
      ibewLocal: localNumber || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      profileComplete: false,
      signupSource: 'crew_invitation',
      crewInvitationId: invitationId,
      fcmToken: fcmToken || null,
      notificationPreferences: {
        jobShares: true,
        crewInvitations: true,
        crewMessages: true,
        stormAlerts: true
      }
    };

    await admin.firestore().collection('users').doc(userRecord.uid).set(userProfile);

    // Update invitation with user ID
    await admin.firestore()
      .collection('crewInvitations')
      .doc(invitationId)
      .update({
        acceptedByUserId: userRecord.uid,
        acceptedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    // Subscribe to FCM topics if token provided
    if (fcmToken) {
      try {
        await admin.messaging().subscribeToTopic(fcmToken, 'general_notifications');
        await admin.messaging().subscribeToTopic(fcmToken, `crew_${inviteData.crewId}`);
        console.log(`Subscribed new user ${userRecord.uid} to crew and general topics`);
      } catch (error) {
        console.error('Error subscribing to topics:', error);
      }
    }

    // Generate custom token for immediate login
    const customToken = await admin.auth().createCustomToken(userRecord.uid);

    return {
      success: true,
      userId: userRecord.uid,
      customToken,
      crewId: inviteData.crewId,
      crewName: inviteData.crewName
    };

  } catch (error) {
    console.error('Error in signupWithCrewInvitation:', error);
    throw new functions.https.HttpsError('internal', 'Failed to signup with crew invitation');
  }
});
