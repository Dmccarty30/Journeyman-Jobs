import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const analyticsFunctions = {
  /**
   * Track share events
   */
  trackShareEvent: functions.https.onCall(async (data, context) => {
    const { event, shareId, jobId, userId, metadata } = data;
    
    try {
      // Create analytics event
      await admin.firestore().collection('analytics').add({
        event,
        shareId,
        jobId,
        userId: userId || context.auth?.uid,
        metadata: metadata || {},
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        platform: 'web',
        version: '1.0.0',
      });
      
      // Update share metrics
      if (shareId) {
        const shareRef = admin.firestore()
          .collection('shares')
          .doc(shareId);
        
        const updates: any = {};
        
        switch (event) {
          case 'share_viewed':
            updates['metrics.views'] = admin.firestore.FieldValue.increment(1);
            break;
          case 'share_clicked':
            updates['metrics.clicks'] = admin.firestore.FieldValue.increment(1);
            break;
          case 'share_signup':
            updates['metrics.signups'] = admin.firestore.FieldValue.increment(1);
            break;
          case 'share_applied':
            updates['metrics.applies'] = admin.firestore.FieldValue.increment(1);
            break;
        }
        
        if (Object.keys(updates).length > 0) {
          await shareRef.update(updates);
        }
      }
      
      return { success: true };
      
    } catch (error) {
      console.error('Error tracking event:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to track event'
      );
    }
  }),
  
  /**
   * Generate share report
   */
  generateShareReport: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { startDate, endDate, userId } = data;
    
    try {
      // Query shares
      let query = admin.firestore()
        .collection('shares')
        .where('createdAt', '>=', new Date(startDate))
        .where('createdAt', '<=', new Date(endDate));
      
      if (userId) {
        query = query.where('sharerId', '==', userId);
      }
      
      const sharesSnapshot = await query.get();
      
      // Calculate metrics
      let totalShares = 0;
      let totalRecipients = 0;
      let totalViews = 0;
      let totalSignups = 0;
      let totalApplies = 0;
      
      const jobStats: { [key: string]: number } = {};
      const recipientTypes: { [key: string]: number } = {
        user: 0,
        email: 0,
        phone: 0,
      };
      
      sharesSnapshot.forEach(doc => {
        const share = doc.data();
        totalShares++;
        totalRecipients += share.recipients?.length || 0;
        totalViews += share.metrics?.views || 0;
        totalSignups += share.metrics?.signups || 0;
        totalApplies += share.metrics?.applies || 0;
        
        // Count by job
        const jobId = share.jobId;
        jobStats[jobId] = (jobStats[jobId] || 0) + 1;
        
        // Count recipient types
        share.recipients?.forEach((recipient: any) => {
          recipientTypes[recipient.type]++;
        });
      });
      
      // Calculate conversion rates
      const viewRate = totalRecipients > 0 
        ? (totalViews / totalRecipients * 100).toFixed(2) 
        : '0';
      const signupRate = totalViews > 0 
        ? (totalSignups / totalViews * 100).toFixed(2) 
        : '0';
      const applyRate = totalSignups > 0 
        ? (totalApplies / totalSignups * 100).toFixed(2) 
        : '0';
      
      // Get top shared jobs
      const topJobs = Object.entries(jobStats)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10)
        .map(([jobId, count]) => ({ jobId, shareCount: count }));
      
      return {
        period: { startDate, endDate },
        summary: {
          totalShares,
          totalRecipients,
          totalViews,
          totalSignups,
          totalApplies,
        },
        conversionRates: {
          viewRate: `${viewRate}%`,
          signupRate: `${signupRate}%`,
          applyRate: `${applyRate}%`,
        },
        recipientBreakdown: recipientTypes,
        topSharedJobs: topJobs,
        averageRecipientsPerShare: totalShares > 0 
          ? (totalRecipients / totalShares).toFixed(1) 
          : '0',
      };
      
    } catch (error) {
      console.error('Error generating report:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to generate report'
      );
    }
  }),
  
  /**
   * Calculate share metrics for dashboard
   */
  calculateShareMetrics: functions.pubsub
    .schedule('every 1 hours')
    .onRun(async (context) => {
      try {
        const now = new Date();
        const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        
        // Calculate daily metrics
        const dailyShares = await admin.firestore()
          .collection('shares')
          .where('createdAt', '>=', oneDayAgo)
          .get();
        
        // Calculate weekly metrics
        const weeklyShares = await admin.firestore()
          .collection('shares')
          .where('createdAt', '>=', oneWeekAgo)
          .get();
        
        // Store metrics
        await admin.firestore()
          .collection('metrics')
          .doc('shares')
          .set({
            daily: {
              shares: dailyShares.size,
              updated: admin.firestore.FieldValue.serverTimestamp(),
            },
            weekly: {
              shares: weeklyShares.size,
              updated: admin.firestore.FieldValue.serverTimestamp(),
            },
          }, { merge: true });
        
        console.log('Share metrics calculated successfully');
        
      } catch (error) {
        console.error('Error calculating metrics:', error);
      }
    }),
};
