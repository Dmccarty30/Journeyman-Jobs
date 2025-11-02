# Serverless Architecture

## Overview

Serverless Architecture is a cloud computing execution model where the cloud provider dynamically manages server resource allocation. In Firebase, this means building applications using Cloud Functions, Firebase services, and event-driven patterns without managing servers.

**Core Benefits**:
- Zero server management and automatic scaling
- Pay-per-execution pricing model (cost efficiency)
- Built-in high availability and fault tolerance
- Seamless integration with Firebase ecosystem
- Rapid development and deployment cycles

**Firebase Serverless Stack**:
- **Cloud Functions**: Backend logic triggered by events or HTTP requests
- **Firestore**: NoSQL database with real-time capabilities
- **Firebase Auth**: User authentication and authorization
- **Cloud Storage**: File storage with event triggers
- **Cloud Messaging**: Push notifications
- **Analytics**: Usage tracking and insights

## Firebase Integration

### Cloud Functions Setup

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export Firestore and Auth references
export const db = admin.firestore();
export const auth = admin.auth();
export const storage = admin.storage();
```

### Function Types

```typescript
// 1. HTTP Functions (REST API endpoints)
export const api = functions.https.onRequest((req, res) => {
  res.json({ message: 'Hello from Cloud Functions' });
});

// 2. Callable Functions (Client SDK integration)
export const getUserProfile = functions.https.onCall(async (data, context) => {
  // Automatic auth validation
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const userId = context.auth.uid;
  const userDoc = await db.collection('users').doc(userId).get();

  return userDoc.data();
});

// 3. Firestore Triggers (Database events)
export const onJobCreated = functions.firestore
  .document('jobs/{jobId}')
  .onCreate(async (snapshot, context) => {
    const job = snapshot.data();
    console.log('New job created:', job.title);
  });

// 4. Auth Triggers (User lifecycle events)
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  console.log('New user registered:', user.email);
});

// 5. Scheduled Functions (Cron jobs)
export const dailyCleanup = functions.pubsub
  .schedule('0 2 * * *')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    console.log('Running daily cleanup');
  });

// 6. Storage Triggers (File events)
export const onImageUploaded = functions.storage
  .object()
  .onFinalize(async (object) => {
    console.log('File uploaded:', object.name);
  });
```

## Implementation Patterns

### 1. Microservices Architecture

**Purpose**: Organize functions into domain-specific services

```typescript
// Job Service
export const jobService = {
  // Create job
  createJob: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { title, description, location, tradeType } = data;

    // Validation
    if (!title || !description || !location) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    const jobRef = db.collection('jobs').doc();

    const jobData = {
      id: jobRef.id,
      title,
      description,
      location,
      tradeType,
      employerId: context.auth.uid,
      status: 'active',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    await jobRef.set(jobData);

    return { jobId: jobRef.id };
  }),

  // Update job
  updateJob: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { jobId, updates } = data;

    // Verify ownership
    const jobDoc = await db.collection('jobs').doc(jobId).get();
    if (!jobDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Job not found');
    }

    if (jobDoc.data()?.employerId !== context.auth.uid) {
      throw new functions.https.HttpsError('permission-denied', 'Not job owner');
    }

    await jobDoc.ref.update({
      ...updates,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { success: true };
  }),

  // Search jobs
  searchJobs: functions.https.onCall(async (data, context) => {
    const { location, tradeType, limit = 20 } = data;

    let query = db.collection('jobs')
      .where('status', '==', 'active');

    if (location) {
      query = query.where('location', '==', location);
    }

    if (tradeType) {
      query = query.where('tradeType', '==', tradeType);
    }

    const snapshot = await query
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    const jobs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    return { jobs };
  })
};

// Worker Service
export const workerService = {
  // Update worker profile
  updateProfile: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const userId = context.auth.uid;
    const { updates } = data;

    await db.collection('workers').doc(userId).set({
      ...updates,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return { success: true };
  }),

  // Search workers
  searchWorkers: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { skills, location, availability } = data;

    let query = db.collection('workers');

    if (skills && skills.length > 0) {
      query = query.where('skills', 'array-contains-any', skills.slice(0, 10));
    }

    if (location) {
      query = query.where('location', '==', location);
    }

    if (availability) {
      query = query.where('availability', '==', availability);
    }

    const snapshot = await query.limit(50).get();

    const workers = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    return { workers };
  })
};

// Notification Service
export const notificationService = {
  // Send notification
  sendNotification: functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { userId, title, message, type } = data;

    const notificationRef = db.collection('notifications').doc();

    await notificationRef.set({
      userId,
      title,
      message,
      type,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Send push notification if user has FCM token
    const userDoc = await db.collection('users').doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (fcmToken) {
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title,
          body: message
        }
      });
    }

    return { success: true };
  })
};
```

### 2. Event-Driven Architecture

**Purpose**: React to system events automatically

```typescript
// Job lifecycle events
export const onJobCreated = functions.firestore
  .document('jobs/{jobId}')
  .onCreate(async (snapshot, context) => {
    const job = snapshot.data();
    const jobId = context.params.jobId;

    // 1. Create search index tokens
    const searchTokens = generateSearchTokens(job);
    await snapshot.ref.update({ searchTokens });

    // 2. Find matching workers
    const matchingWorkers = await findMatchingWorkers(job);

    // 3. Send notifications
    const batch = db.batch();

    matchingWorkers.forEach(worker => {
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        userId: worker.id,
        type: 'new_job_match',
        jobId,
        jobTitle: job.title,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    });

    await batch.commit();

    // 4. Update analytics
    await db.collection('analytics').doc('jobStats').set({
      totalJobs: admin.firestore.FieldValue.increment(1),
      lastJobCreated: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
  });

export const onJobUpdated = functions.firestore
  .document('jobs/{jobId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Status changed to filled
    if (before.status !== 'filled' && after.status === 'filled') {
      // Notify assigned worker
      if (after.assignedWorkerId) {
        await createNotification({
          userId: after.assignedWorkerId,
          type: 'job_assigned',
          jobId: context.params.jobId,
          message: `You've been assigned to: ${after.title}`
        });
      }

      // Notify employer
      await createNotification({
        userId: after.employerId,
        type: 'job_filled',
        jobId: context.params.jobId,
        message: `Your job posting has been filled: ${after.title}`
      });
    }
  });

export const onJobDeleted = functions.firestore
  .document('jobs/{jobId}')
  .onDelete(async (snapshot, context) => {
    const job = snapshot.data();

    // Clean up related data
    const batch = db.batch();

    // Delete notifications
    const notificationsSnapshot = await db.collection('notifications')
      .where('jobId', '==', context.params.jobId)
      .get();

    notificationsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    // Delete applications
    const applicationsSnapshot = await db.collection('applications')
      .where('jobId', '==', context.params.jobId)
      .get();

    applicationsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
  });

// User lifecycle events
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  // Create user profile document
  await db.collection('users').doc(user.uid).set({
    email: user.email,
    displayName: user.displayName || '',
    photoURL: user.photoURL || '',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastLogin: admin.firestore.FieldValue.serverTimestamp()
  });

  // Send welcome email
  await sendWelcomeEmail(user.email!);

  // Update analytics
  await db.collection('analytics').doc('userStats').set({
    totalUsers: admin.firestore.FieldValue.increment(1)
  }, { merge: true });
});

export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  // Clean up user data
  const batch = db.batch();

  // Delete user profile
  batch.delete(db.collection('users').doc(user.uid));

  // Delete notifications
  const notificationsSnapshot = await db.collection('notifications')
    .where('userId', '==', user.uid)
    .get();

  notificationsSnapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });

  await batch.commit();
});

// Helper functions
function generateSearchTokens(job: any): string[] {
  const tokens = new Set<string>();

  job.title.toLowerCase().split(/\s+/).forEach((token: string) => tokens.add(token));
  if (job.location) {
    job.location.toLowerCase().split(/\s+/).forEach((token: string) => tokens.add(token));
  }

  return Array.from(tokens);
}

async function findMatchingWorkers(job: any): Promise<any[]> {
  const snapshot = await db.collection('workers')
    .where('location', '==', job.location)
    .where('availability', '==', 'available')
    .limit(50)
    .get();

  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}

async function createNotification(data: any): Promise<void> {
  await db.collection('notifications').add({
    ...data,
    read: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
}

async function sendWelcomeEmail(email: string): Promise<void> {
  // Implementation depends on email service (SendGrid, Mailgun, etc.)
  console.log('Sending welcome email to:', email);
}
```

### 3. API Gateway Pattern

**Purpose**: Unified REST API with Cloud Functions

```typescript
import * as express from 'express';
import * as cors from 'cors';

const app = express();

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());

// Authentication middleware
const authenticate = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);

    req.user = decodedToken;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// Jobs API
app.post('/jobs', authenticate, async (req, res) => {
  try {
    const { title, description, location, tradeType } = req.body;

    const jobRef = db.collection('jobs').doc();

    await jobRef.set({
      title,
      description,
      location,
      tradeType,
      employerId: req.user.uid,
      status: 'active',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    res.status(201).json({ jobId: jobRef.id });
  } catch (error) {
    console.error('Error creating job:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/jobs', async (req, res) => {
  try {
    const { location, tradeType, limit = '20' } = req.query;

    let query = db.collection('jobs').where('status', '==', 'active');

    if (location) {
      query = query.where('location', '==', location);
    }

    if (tradeType) {
      query = query.where('tradeType', '==', tradeType);
    }

    const snapshot = await query
      .orderBy('createdAt', 'desc')
      .limit(parseInt(limit as string))
      .get();

    const jobs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json({ jobs });
  } catch (error) {
    console.error('Error fetching jobs:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/jobs/:jobId', async (req, res) => {
  try {
    const jobDoc = await db.collection('jobs').doc(req.params.jobId).get();

    if (!jobDoc.exists) {
      return res.status(404).json({ error: 'Job not found' });
    }

    res.json({
      id: jobDoc.id,
      ...jobDoc.data()
    });
  } catch (error) {
    console.error('Error fetching job:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.put('/jobs/:jobId', authenticate, async (req, res) => {
  try {
    const jobDoc = await db.collection('jobs').doc(req.params.jobId).get();

    if (!jobDoc.exists) {
      return res.status(404).json({ error: 'Job not found' });
    }

    if (jobDoc.data()?.employerId !== req.user.uid) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    await jobDoc.ref.update({
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Error updating job:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.delete('/jobs/:jobId', authenticate, async (req, res) => {
  try {
    const jobDoc = await db.collection('jobs').doc(req.params.jobId).get();

    if (!jobDoc.exists) {
      return res.status(404).json({ error: 'Job not found' });
    }

    if (jobDoc.data()?.employerId !== req.user.uid) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    await jobDoc.ref.delete();

    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting job:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Export Express app as Cloud Function
export const api = functions.https.onRequest(app);
```

## JJ-Specific Examples

### Job Matching System

```typescript
// Automated job matching when worker updates profile
export const onWorkerProfileUpdated = functions.firestore
  .document('workers/{workerId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Skills changed
    if (JSON.stringify(before.skills) !== JSON.stringify(after.skills)) {
      const workerId = context.params.workerId;

      // Find matching jobs
      const jobsSnapshot = await db.collection('jobs')
        .where('status', '==', 'active')
        .where('location', '==', after.location)
        .limit(50)
        .get();

      const matchingJobs = jobsSnapshot.docs
        .map(doc => ({ id: doc.id, ...doc.data() }))
        .filter(job => {
          // Check skill overlap
          const workerSkills = after.skills.map((s: any) => s.name);
          const requiredSkills = job.requiredSkills || [];
          const overlap = requiredSkills.filter((skill: string) =>
            workerSkills.includes(skill)
          );

          return overlap.length >= requiredSkills.length * 0.7; // 70% match
        });

      // Create notifications for matching jobs
      const batch = db.batch();

      matchingJobs.forEach(job => {
        const notificationRef = db.collection('notifications').doc();
        batch.set(notificationRef, {
          userId: workerId,
          type: 'job_match',
          jobId: job.id,
          jobTitle: job.title,
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
      });

      await batch.commit();
    }
  });

// Application submission handler
export const submitApplication = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { jobId, coverLetter } = data;
  const workerId = context.auth.uid;

  // Verify job exists and is active
  const jobDoc = await db.collection('jobs').doc(jobId).get();

  if (!jobDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Job not found');
  }

  if (jobDoc.data()?.status !== 'active') {
    throw new functions.https.HttpsError('failed-precondition', 'Job is not active');
  }

  // Check if already applied
  const existingApplication = await db.collection('applications')
    .where('jobId', '==', jobId)
    .where('workerId', '==', workerId)
    .get();

  if (!existingApplication.empty) {
    throw new functions.https.HttpsError('already-exists', 'Already applied');
  }

  // Create application
  const applicationRef = db.collection('applications').doc();

  await applicationRef.set({
    jobId,
    workerId,
    coverLetter,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });

  // Notify employer
  await db.collection('notifications').add({
    userId: jobDoc.data()?.employerId,
    type: 'new_application',
    jobId,
    workerId,
    applicationId: applicationRef.id,
    read: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });

  return { applicationId: applicationRef.id };
});
```

### Analytics and Reporting

```typescript
// Daily analytics aggregation
export const dailyAnalytics = functions.pubsub
  .schedule('0 1 * * *') // 1 AM daily
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    // Count new jobs
    const newJobsSnapshot = await db.collection('jobs')
      .where('createdAt', '>=', admin.firestore.Timestamp.fromDate(yesterday))
      .where('createdAt', '<', admin.firestore.Timestamp.fromDate(today))
      .get();

    // Count new workers
    const newWorkersSnapshot = await db.collection('workers')
      .where('createdAt', '>=', admin.firestore.Timestamp.fromDate(yesterday))
      .where('createdAt', '<', admin.firestore.Timestamp.fromDate(today))
      .get();

    // Count applications
    const newApplicationsSnapshot = await db.collection('applications')
      .where('createdAt', '>=', admin.firestore.Timestamp.fromDate(yesterday))
      .where('createdAt', '<', admin.firestore.Timestamp.fromDate(today))
      .get();

    // Save analytics
    await db.collection('analytics').doc(yesterday.toISOString().split('T')[0]).set({
      date: admin.firestore.Timestamp.fromDate(yesterday),
      newJobs: newJobsSnapshot.size,
      newWorkers: newWorkersSnapshot.size,
      newApplications: newApplicationsSnapshot.size
    });

    console.log('Daily analytics completed');
  });

// Generate monthly report
export const monthlyReport = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  // Verify admin role
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (userDoc.data()?.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin only');
  }

  const { month, year } = data;

  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 1);

  // Aggregate data
  const analyticsSnapshot = await db.collection('analytics')
    .where('date', '>=', admin.firestore.Timestamp.fromDate(startDate))
    .where('date', '<', admin.firestore.Timestamp.fromDate(endDate))
    .get();

  const report = {
    month,
    year,
    totalJobs: 0,
    totalWorkers: 0,
    totalApplications: 0,
    dailyBreakdown: [] as any[]
  };

  analyticsSnapshot.docs.forEach(doc => {
    const data = doc.data();
    report.totalJobs += data.newJobs || 0;
    report.totalWorkers += data.newWorkers || 0;
    report.totalApplications += data.newApplications || 0;
    report.dailyBreakdown.push(data);
  });

  return report;
});
```

## Security Considerations

### Authentication and Authorization

```typescript
// Role-based access control
const checkRole = async (userId: string, requiredRole: string): Promise<boolean> => {
  const userDoc = await db.collection('users').doc(userId).get();
  const userRole = userDoc.data()?.role || 'user';

  const roleHierarchy: { [key: string]: number } = {
    user: 1,
    worker: 2,
    employer: 2,
    admin: 3
  };

  return roleHierarchy[userRole] >= roleHierarchy[requiredRole];
};

// Secure callable function
export const adminOnlyFunction = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const isAdmin = await checkRole(context.auth.uid, 'admin');

  if (!isAdmin) {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }

  // Admin operation
  return { success: true };
});
```

### Input Validation

```typescript
// Input sanitization
import * as validator from 'validator';

const sanitizeJobInput = (data: any): any => {
  return {
    title: validator.escape(data.title?.trim() || ''),
    description: validator.escape(data.description?.trim() || ''),
    location: validator.escape(data.location?.trim() || ''),
    tradeType: validator.escape(data.tradeType?.trim() || ''),
    payRate: parseFloat(data.payRate) || 0
  };
};

export const createJobSecure = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  // Validate input
  if (!data.title || data.title.length < 5 || data.title.length > 100) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid title');
  }

  // Sanitize
  const sanitized = sanitizeJobInput(data);

  // Create job with sanitized data
  const jobRef = db.collection('jobs').doc();

  await jobRef.set({
    ...sanitized,
    employerId: context.auth.uid,
    status: 'active',
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });

  return { jobId: jobRef.id };
});
```

## Performance Optimization

### Cold Start Reduction

```typescript
// Keep functions warm with scheduled pings
export const keepWarm = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    console.log('Keeping functions warm');
    return null;
  });

// Global connection reuse
let cachedConnection: any = null;

export const optimizedFunction = functions.https.onCall(async (data, context) => {
  if (!cachedConnection) {
    cachedConnection = await initializeConnection();
  }

  // Use cached connection
  return performOperation(cachedConnection);
});
```

### Batch Operations

```typescript
// Process multiple operations in single function call
export const batchUpdateJobs = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { operations } = data;

  const batch = db.batch();

  operations.forEach((op: any) => {
    const jobRef = db.collection('jobs').doc(op.jobId);

    if (op.type === 'update') {
      batch.update(jobRef, op.data);
    } else if (op.type === 'delete') {
      batch.delete(jobRef);
    }
  });

  await batch.commit();

  return { success: true };
});
```

## Error Handling

```typescript
// Centralized error handling
class FunctionError extends Error {
  constructor(
    public code: functions.https.FunctionsErrorCode,
    message: string,
    public details?: any
  ) {
    super(message);
    this.name = 'FunctionError';
  }
}

const handleError = (error: any): never => {
  console.error('Function error:', error);

  if (error instanceof FunctionError) {
    throw new functions.https.HttpsError(error.code, error.message, error.details);
  }

  if (error.code === 'permission-denied') {
    throw new functions.https.HttpsError('permission-denied', 'Access denied');
  }

  throw new functions.https.HttpsError('internal', 'An error occurred');
};

export const robustFunction = functions.https.onCall(async (data, context) => {
  try {
    // Function logic
    return { success: true };
  } catch (error) {
    handleError(error);
  }
});
```

## Cloud Functions Examples

### Background Processing

```typescript
// Process job expiration in background
export const processExpiredJobs = functions.pubsub
  .schedule('0 * * * *') // Hourly
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const expiredJobsSnapshot = await db.collection('jobs')
      .where('status', '==', 'active')
      .where('createdAt', '<', admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
      .get();

    const batch = db.batch();

    expiredJobsSnapshot.docs.forEach(doc => {
      batch.update(doc.ref, {
        status: 'expired',
        expiredAt: admin.firestore.FieldValue.serverTimestamp()
      });
    });

    await batch.commit();

    console.log(`Expired ${expiredJobsSnapshot.size} jobs`);
  });
```

## Best Practices

1. **Keep functions focused**: One function, one responsibility
2. **Use TypeScript**: Type safety prevents runtime errors
3. **Optimize cold starts**: Reuse connections and minimize dependencies
4. **Implement proper error handling**: Use structured error responses
5. **Validate all inputs**: Never trust client data
6. **Use batch operations**: Reduce function invocations
7. **Monitor performance**: Use Firebase Performance Monitoring
8. **Secure endpoints**: Always authenticate and authorize
9. **Design for idempotency**: Functions should handle duplicate calls
10. **Test thoroughly**: Unit test all business logic

## Deployment

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:createJob

# Set environment variables
firebase functions:config:set service.api_key="your-key"

# View logs
firebase functions:log
```
