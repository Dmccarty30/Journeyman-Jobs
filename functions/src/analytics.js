const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * Track job share analytics
 */
exports.trackJobShare = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { 
    shareId, 
    jobId, 
    shareMethod, 
    recipientCount, 
    hasMessage, 
    isStormWork 
  } = data;
  const userId = context.auth.uid;

  try {
    await admin.firestore().collection('analytics/jobSharing/events').add({
      eventType: 'job_shared',
      userId,
      shareId,
      jobId,
      shareMethod, // 'email', 'sms', 'crew', 'direct'
      recipientCount,
      hasMessage,
      isStormWork,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });

    // Update daily aggregates
    const today = new Date().toISOString().split('T')[0];
    const aggregateRef = admin.firestore()
      .collection('analytics/jobSharing/daily')
      .doc(today);

    await aggregateRef.set({
      date: today,
      totalShares: admin.firestore.FieldValue.increment(1),
      totalRecipients: admin.firestore.FieldValue.increment(recipientCount),
      stormWorkShares: admin.firestore.FieldValue.increment(isStormWork ? 1 : 0),
      sharesWithMessage: admin.firestore.FieldValue.increment(hasMessage ? 1 : 0),
      [`sharesByMethod.${shareMethod}`]: admin.firestore.FieldValue.increment(1),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return { success: true };

  } catch (error) {
    console.error('Error tracking job share:', error);
    throw new functions.https.HttpsError('internal', 'Failed to track analytics');
  }
});

/**
 * Track user invitation analytics
 */
exports.trackUserInvitation = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { 
    invitationId, 
    invitationMethod, 
    targetEmail, 
    jobId, 
    isCrewInvitation 
  } = data;
  const inviterId = context.auth.uid;

  try {
    await admin.firestore().collection('analytics/invitations/events').add({
      eventType: 'invitation_sent',
      inviterId,
      invitationId,
      invitationMethod, // 'email', 'sms', 'in_app'
      targetEmail,
      jobId: jobId || null,
      isCrewInvitation: isCrewInvitation || false,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });

    // Update daily aggregates
    const today = new Date().toISOString().split('T')[0];
    await admin.firestore()
      .collection('analytics/invitations/daily')
      .doc(today)
      .set({
        date: today,
        totalInvitations: admin.firestore.FieldValue.increment(1),
        crewInvitations: admin.firestore.FieldValue.increment(isCrewInvitation ? 1 : 0),
        jobInvitations: admin.firestore.FieldValue.increment(jobId ? 1 : 0),
        [`invitationsByMethod.${invitationMethod}`]: admin.firestore.FieldValue.increment(1),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

    return { success: true };

  } catch (error) {
    console.error('Error tracking user invitation:', error);
    throw new functions.https.HttpsError('internal', 'Failed to track invitation analytics');
  }
});

/**
 * Track signup conversion analytics
 */
exports.trackSignupConversion = functions.https.onCall(async (data, context) => {
  const { 
    userId, 
    signupSource, 
    invitationId, 
    timeToConvert, 
    isProfileComplete 
  } = data;

  try {
    await admin.firestore().collection('analytics/conversions/events').add({
      eventType: 'user_signup',
      userId,
      signupSource, // 'organic', 'job_invitation', 'crew_invitation', 'referral'
      invitationId: invitationId || null,
      timeToConvertHours: timeToConvert || null,
      isProfileComplete,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });

    // Update conversion tracking if from invitation
    if (invitationId) {
      await admin.firestore()
        .collection('invitations')
        .doc(invitationId)
        .update({
          convertedToSignup: true,
          convertedUserId: userId,
          convertedAt: admin.firestore.FieldValue.serverTimestamp(),
          timeToConvertHours: timeToConvert
        });
    }

    // Update daily conversion aggregates
    const today = new Date().toISOString().split('T')[0];
    await admin.firestore()
      .collection('analytics/conversions/daily')
      .doc(today)
      .set({
        date: today,
        totalSignups: admin.firestore.FieldValue.increment(1),
        profileCompleteSignups: admin.firestore.FieldValue.increment(isProfileComplete ? 1 : 0),
        [`signupsBySource.${signupSource}`]: admin.firestore.FieldValue.increment(1),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

    return { success: true };

  } catch (error) {
    console.error('Error tracking signup conversion:', error);
    throw new functions.https.HttpsError('internal', 'Failed to track conversion analytics');
  }
});

/**
 * Calculate viral coefficient and sharing metrics
 */
exports.calculateViralMetrics = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      // Get sharing data from last 30 days
      const sharingSnapshot = await admin.firestore()
        .collection('analytics/jobSharing/events')
        .where('timestamp', '>=', thirtyDaysAgo)
        .get();

      // Get conversion data from last 30 days
      const conversionSnapshot = await admin.firestore()
        .collection('analytics/conversions/events')
        .where('timestamp', '>=', thirtyDaysAgo)
        .where('signupSource', 'in', ['job_invitation', 'crew_invitation'])
        .get();

      // Calculate metrics
      const totalShares = sharingSnapshot.size;
      const totalRecipients = sharingSnapshot.docs.reduce(
        (sum, doc) => sum + (doc.data().recipientCount || 0), 0
      );
      const totalConversions = conversionSnapshot.size;

      const viralCoefficient = totalShares > 0 ? totalConversions / totalShares : 0;
      const conversionRate = totalRecipients > 0 ? totalConversions / totalRecipients : 0;

      // Store metrics
      await admin.firestore()
        .collection('analytics/viralMetrics')
        .doc('latest')
        .set({
          calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
          period: '30_days',
          totalShares,
          totalRecipients,
          totalConversions,
          viralCoefficient,
          conversionRate,
          periodStart: thirtyDaysAgo,
          periodEnd: new Date()
        });

      const viralCoefficientFormatted = viralCoefficient.toFixed(3);
      const conversionRateFormatted = conversionRate.toFixed(3);
      console.log(`Viral metrics calculated: VC=${viralCoefficientFormatted}, CR=${conversionRateFormatted}`);

    } catch (error) {
      console.error('Error calculating viral metrics:', error);
    }
  });

/**
 * Generate analytics dashboard data
 */
exports.getAnalyticsDashboard = functions.https.onCall(async (data, context) => {
  // TODO: Add admin role verification
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { period = '7_days' } = data;

  try {
    const daysBack = period === '30_days' ? 30 : 7;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysBack);

    // Get daily aggregates
    const sharingQuery = admin.firestore()
      .collection('analytics/jobSharing/daily')
      .where('date', '>=', startDate.toISOString().split('T')[0])
      .orderBy('date');

    const conversionQuery = admin.firestore()
      .collection('analytics/conversions/daily')
      .where('date', '>=', startDate.toISOString().split('T')[0])
      .orderBy('date');

    const [sharingSnapshot, conversionSnapshot] = await Promise.all([
      sharingQuery.get(),
      conversionQuery.get()
    ]);

    // Get latest viral metrics
    const viralMetricsDoc = await admin.firestore()
      .collection('analytics/viralMetrics')
      .doc('latest')
      .get();

    const dashboard = {
      period,
      generatedAt: new Date().toISOString(),
      sharing: {
        dailyData: sharingSnapshot.docs.map(doc => ({
          date: doc.data().date,
          shares: doc.data().totalShares || 0,
          recipients: doc.data().totalRecipients || 0,
          stormWork: doc.data().stormWorkShares || 0
        })),
        totals: sharingSnapshot.docs.reduce((acc, doc) => {
          const data = doc.data();
          acc.shares += data.totalShares || 0;
          acc.recipients += data.totalRecipients || 0;
          acc.stormWork += data.stormWorkShares || 0;
          return acc;
        }, { shares: 0, recipients: 0, stormWork: 0 })
      },
      conversions: {
        dailyData: conversionSnapshot.docs.map(doc => ({
          date: doc.data().date,
          signups: doc.data().totalSignups || 0,
          profileComplete: doc.data().profileCompleteSignups || 0
        })),
        totals: conversionSnapshot.docs.reduce((acc, doc) => {
          const data = doc.data();
          acc.signups += data.totalSignups || 0;
          acc.profileComplete += data.profileCompleteSignups || 0;
          return acc;
        }, { signups: 0, profileComplete: 0 })
      },
      viralMetrics: viralMetricsDoc.exists ? viralMetricsDoc.data() : null
    };

    return dashboard;

  } catch (error) {
    console.error('Error generating analytics dashboard:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate dashboard');
  }
});
