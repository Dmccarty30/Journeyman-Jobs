import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const userFunctions = {
  /**
   * Trigger when a new user signs up
   */
  onUserSignup: functions.auth.user().onCreate(async (user) => {
    try {
      // Create user profile in Firestore
      await admin.firestore().collection('users').doc(user.uid).set({
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        emailVerified: user.emailVerified,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
        profile: {
          classification: '',
          yearsExperience: 0,
          preferredLocations: [],
          skills: [],
          certifications: [],
        },
        preferences: {
          jobNotifications: true,
          shareNotifications: true,
          emailUpdates: true,
          smsNotifications: false,
        },
        metrics: {
          sharesCreated: 0,
          sharesReceived: 0,
          jobsApplied: 0,
          conversionsGenerated: 0,
        },
        status: 'active',
      });
      
      // Send welcome notification
      await admin.firestore().collection('notifications').add({
        userId: user.uid,
        type: 'welcome',
        title: '⚡ Welcome to Journeyman Jobs!',
        body: 'Complete your profile to start finding better opportunities',
        data: {
          action: 'complete_profile',
        },
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      // Track signup event
      await admin.firestore().collection('analytics').add({
        event: 'user_signup',
        userId: user.uid,
        metadata: {
          provider: user.providerData[0]?.providerId || 'unknown',
          email: user.email,
        },
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log('User profile created:', user.uid);
      
    } catch (error) {
      console.error('Error creating user profile:', error);
    }
  }),
  
  /**
   * Process quick signup from share link
   */
  processQuickSignup: functions.https.onCall(async (data, context) => {
    const { email, name, phone, shareId, classification } = data;
    
    try {
      // Validate required fields
      if (!email || !name) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Email and name are required'
        );
      }
      
      // Check if user already exists
      let userRecord;
      try {
        userRecord = await admin.auth().getUserByEmail(email);
        // User exists, return existing user info
        return {
          success: true,
          userId: userRecord.uid,
          existing: true,
          message: 'User already exists',
        };
      } catch (error) {
        // User doesn't exist, create new one
      }
      
      // Create new user
      userRecord = await admin.auth().createUser({
        email,
        displayName: name,
        emailVerified: false,
      });
      
      // Create user profile
      await admin.firestore().collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        email,
        displayName: name,
        phone: phone || '',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
        profile: {
          classification: classification || '',
          yearsExperience: 0,
          preferredLocations: [],
          skills: [],
          certifications: [],
        },
        preferences: {
          jobNotifications: true,
          shareNotifications: true,
          emailUpdates: true,
          smsNotifications: !!phone,
        },
        metrics: {
          sharesCreated: 0,
          sharesReceived: 0,
          jobsApplied: 0,
          conversionsGenerated: 0,
        },
        status: 'active',
        signupSource: 'share_link',
        referralShareId: shareId,
      });
      
      // Process share conversion if shareId provided
      if (shareId) {
        // Update share metrics
        await admin.firestore()
          .collection('shares')
          .doc(shareId)
          .update({
            'metrics.signups': admin.firestore.FieldValue.increment(1),
            'metrics.lastActivity': admin.firestore.FieldValue.serverTimestamp(),
          });
        
        // Create conversion record
        await admin.firestore().collection('conversions').add({
          shareId,
          convertedUserId: userRecord.uid,
          conversionType: 'signup',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          source: 'quick_signup',
        });
      }
      
      // Generate custom token for immediate login
      const customToken = await admin.auth().createCustomToken(userRecord.uid);
      
      // Send welcome email
      // Note: This would integrate with the email functions
      
      return {
        success: true,
        userId: userRecord.uid,
        customToken,
        existing: false,
        message: 'Account created successfully',
      };
      
    } catch (error: any) {
      console.error('Error processing quick signup:', error);
      
      // Handle specific Firebase Auth errors
      if (error.code === 'auth/email-already-exists') {
        throw new functions.https.HttpsError(
          'already-exists',
          'An account with this email already exists'
        );
      }
      
      throw new functions.https.HttpsError(
        'internal',
        'Failed to create account'
      );
    }
  }),
  
  /**
   * Link a share to a user account
   */
  linkShareToUser: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { shareId } = data;
    const userId = context.auth.uid;
    
    try {
      // Get share document
      const shareDoc = await admin.firestore()
        .collection('shares')
        .doc(shareId)
        .get();
      
      if (!shareDoc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Share not found'
        );
      }
      
      const share = shareDoc.data();
      
      // Update user's received shares count
      await admin.firestore()
        .collection('users')
        .doc(userId)
        .update({
          'metrics.sharesReceived': admin.firestore.FieldValue.increment(1),
          lastActivity: admin.firestore.FieldValue.serverTimestamp(),
        });
      
      // Create share interaction record
      await admin.firestore().collection('share_interactions').add({
        shareId,
        userId,
        sharerId: share?.sharerId,
        jobId: share?.jobId,
        interactionType: 'linked',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      // Track the link event
      await admin.firestore().collection('analytics').add({
        event: 'share_linked',
        shareId,
        userId,
        jobId: share?.jobId,
        metadata: {
          sharerId: share?.sharerId,
        },
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return { success: true };
      
    } catch (error) {
      console.error('Error linking share to user:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to link share'
      );
    }
  }),
  
  /**
   * Update user profile
   */
  updateUserProfile: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { profile, preferences } = data;
    const userId = context.auth.uid;
    
    try {
      const updates: any = {
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      };
      
      if (profile) {
        updates.profile = profile;
      }
      
      if (preferences) {
        updates.preferences = preferences;
      }
      
      await admin.firestore()
        .collection('users')
        .doc(userId)
        .update(updates);
      
      return { success: true };
      
    } catch (error) {
      console.error('Error updating user profile:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to update profile'
      );
    }
  }),
  
  /**
   * Delete user account and associated data
   */
  onUserDeleted: functions.auth.user().onDelete(async (user) => {
    try {
      const userId = user.uid;
      
      // Delete user document
      await admin.firestore().collection('users').doc(userId).delete();
      
      // Delete user's shares
      const userShares = await admin.firestore()
        .collection('shares')
        .where('sharerId', '==', userId)
        .get();
      
      const batch = admin.firestore().batch();
      userShares.forEach(doc => {
        batch.delete(doc.ref);
      });
      
      // Delete user's notifications
      const userNotifications = await admin.firestore()
        .collection('notifications')
        .where('userId', '==', userId)
        .get();
      
      userNotifications.forEach(doc => {
        batch.delete(doc.ref);
      });
      
      await batch.commit();
      
      console.log('User data deleted:', userId);
      
    } catch (error) {
      console.error('Error deleting user data:', error);
    }
  }),
};
