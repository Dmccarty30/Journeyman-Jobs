import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const shareFunctions = {
  /**
   * Trigger when a new share is created
   */
  onShareCreated: functions.firestore
    .document('shares/{shareId}')
    .onCreate(async (snap, context) => {
      const share = snap.data();
      const shareId = context.params.shareId;
      
      try {
        // Initialize metrics
        await snap.ref.update({
          'metrics.views': 0,
          'metrics.clicks': 0,
          'metrics.signups': 0,
          'metrics.applies': 0,
          'metrics.lastActivity': admin.firestore.FieldValue.serverTimestamp(),
        });
        
        // Create notifications for recipients who are already users
        const userRecipients = share.recipients?.filter((r: any) => r.type === 'user') || [];
        
        for (const recipient of userRecipients) {
          await admin.firestore().collection('notifications').add({
            userId: recipient.value,
            type: 'job_share',
            title: `${share.sharerName} shared a job with you`,
            body: `${share.job.title} at ${share.job.company} - $${share.job.hourlyRate}/hr`,
            data: {
              shareId,
              jobId: share.jobId,
              sharerId: share.sharerId,
            },
            read: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        
        // Track the share creation event
        await admin.firestore().collection('analytics').add({
          event: 'share_created',
          shareId,
          jobId: share.jobId,
          userId: share.sharerId,
          metadata: {
            recipientCount: share.recipients?.length || 0,
            recipientTypes: share.recipients?.map((r: any) => r.type) || [],
          },
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        console.log(`Share created successfully: ${shareId}`);
        
      } catch (error) {
        console.error('Error processing new share:', error);
      }
    }),
  
  /**
   * Update share status
   */
  updateShareStatus: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { shareId, status, metadata } = data;
    
    try {
      const updates: any = {
        status,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      };
      
      if (metadata) {
        updates.metadata = metadata;
      }
      
      await admin.firestore()
        .collection('shares')
        .doc(shareId)
        .update(updates);
      
      // Track status change
      await admin.firestore().collection('analytics').add({
        event: 'share_status_changed',
        shareId,
        userId: context.auth.uid,
        metadata: { newStatus: status, ...metadata },
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return { success: true };
      
    } catch (error) {
      console.error('Error updating share status:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to update share status'
      );
    }
  }),
  
  /**
   * Process share conversion (signup from shared link)
   */
  processShareConversion: functions.https.onCall(async (data, context) => {
    const { shareId, userId, conversionType } = data;
    
    try {
      // Get the share document
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
      
      // Update share metrics
      const metricField = `metrics.${conversionType}s`;
      await shareDoc.ref.update({
        [metricField]: admin.firestore.FieldValue.increment(1),
        'metrics.lastActivity': admin.firestore.FieldValue.serverTimestamp(),
      });
      
      // Create conversion record
      await admin.firestore().collection('conversions').add({
        shareId,
        sharerId: share?.sharerId,
        convertedUserId: userId,
        jobId: share?.jobId,
        conversionType,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        metadata: {
          sharerName: share?.sharerName,
          jobTitle: share?.job?.title,
          jobCompany: share?.job?.company,
        },
      });
      
      // Track conversion event
      await admin.firestore().collection('analytics').add({
        event: `share_${conversionType}`,
        shareId,
        userId,
        jobId: share?.jobId,
        metadata: {
          sharerId: share?.sharerId,
          conversionType,
        },
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      // Send notification to sharer
      if (share?.sharerId && conversionType === 'signup') {
        await admin.firestore().collection('notifications').add({
          userId: share.sharerId,
          type: 'share_conversion',
          title: 'Someone signed up from your share!',
          body: `A new user joined through your ${share.job?.title} share`,
          data: {
            shareId,
            jobId: share.jobId,
            conversionType,
          },
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      
      return { success: true, conversionId: shareId };
      
    } catch (error) {
      console.error('Error processing conversion:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to process conversion'
      );
    }
  }),
  
  /**
   * Clean up expired shares (scheduled function)
   */
  cleanupExpiredShares: functions.pubsub
    .schedule('every 24 hours')
    .onRun(async (context) => {
      try {
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        
        // Find expired shares
        const expiredShares = await admin.firestore()
          .collection('shares')
          .where('createdAt', '<', thirtyDaysAgo)
          .where('status', '==', 'active')
          .get();
        
        // Update expired shares
        const batch = admin.firestore().batch();
        
        expiredShares.forEach(doc => {
          batch.update(doc.ref, {
            status: 'expired',
            expiredAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        });
        
        if (!expiredShares.empty) {
          await batch.commit();
          console.log(`Marked ${expiredShares.size} shares as expired`);
        }
        
      } catch (error) {
        console.error('Error cleaning up expired shares:', error);
      }
    }),
};
