/**
 * Production Configuration for Journeyman Jobs Cloud Functions
 * Contains all production-specific settings and security configurations
 */

export const productionConfig = {
  // Firebase Configuration
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || 'journeyman-jobs-prod',
    region: 'us-central1',
    databaseURL: `https://${process.env.FIREBASE_PROJECT_ID || 'journeyman-jobs-prod'}-default-rtdb.firebaseio.com`,
  },

  // Email Configuration
  email: {
    sendgrid: {
      apiKey: process.env.SENDGRID_API_KEY || '',
      fromEmail: process.env.SENDGRID_FROM_EMAIL || 'no-reply@journeymanjobs.com',
      fromName: process.env.SENDGRID_FROM_NAME || 'Journeyman Jobs',
      templates: {
        jobShare: 'd-abc123def456789',
        quickSignup: 'd-def456ghi789123',
        crewInvitation: 'd-ghi789jkl123456',
        notification: 'd-jkl123mno456789',
      },
    },
  },

  // SMS Configuration
  sms: {
    twilio: {
      accountSid: process.env.TWILIO_ACCOUNT_SID || '',
      authToken: process.env.TWILIO_AUTH_TOKEN || '',
      phoneNumber: process.env.TWILIO_PHONE_NUMBER || '+15551234567',
    },
  },

  // Deep Linking
  deepLink: {
    scheme: process.env.DEEP_LINK_SCHEME || 'journeymanjobs',
    host: process.env.DEEP_LINK_HOST || 'share',
    webUrl: 'https://journeymanjobs.com',
    appStoreId: process.env.APP_STORE_ID || '123456789',
    googlePlayId: process.env.GOOGLE_PLAY_ID || 'com.journeymanjobs.app',
  },

  // Security Settings
  security: {
    corsOrigins: [
      'https://journeymanjobs.com',
      'https://www.journeymanjobs.com',
      'https://journeyman-jobs-prod.firebaseapp.com',
      'https://journeyman-jobs-prod.web.app',
    ],
    rateLimits: {
      maxRequestsPerMinute: parseInt(process.env.MAX_REQUESTS_PER_MINUTE || '60'),
      maxSharesPerDay: parseInt(process.env.MAX_SHARES_PER_DAY || '100'),
      maxRecipientsPerShare: parseInt(process.env.MAX_SHARE_RECIPIENTS || '25'),
      shareCooldownMinutes: parseInt(process.env.SHARE_COOLDOWN_MINUTES || '1'),
    },
    encryption: {
      algorithm: 'aes-256-gcm',
      keyLength: 32,
    },
  },

  // Performance Settings
  performance: {
    cacheTtlSeconds: parseInt(process.env.CACHE_TTL_SECONDS || '3600'),
    maxConcurrentFunctions: parseInt(process.env.MAX_CONCURRENT_FUNCTIONS || '100'),
    memoryLimitMB: parseInt(process.env.MEMORY_LIMIT_MB || '512'),
    timeoutSeconds: parseInt(process.env.TIMEOUT_SECONDS || '60'),
  },

  // Analytics Configuration
  analytics: {
    mixpanel: {
      token: process.env.MIXPANEL_TOKEN || '',
      enabled: process.env.ENABLE_ANALYTICS === 'true',
    },
    sentry: {
      dsn: process.env.SENTRY_DSN || '',
      environment: 'production',
      enabled: process.env.ENABLE_ANALYTICS === 'true',
    },
  },

  // Feature Flags
  features: {
    emailSharing: process.env.ENABLE_EMAIL_SHARING === 'true',
    smsSharing: process.env.ENABLE_SMS_SHARING === 'true',
    contactPicker: process.env.ENABLE_CONTACT_PICKER === 'true',
    crewManagement: process.env.ENABLE_CREW_MANAGEMENT === 'true',
    auditLogging: process.env.ENABLE_AUDIT_LOGGING === 'true',
    rateLimiting: process.env.ENABLE_RATE_LIMITING === 'true',
  },

  // Logging Configuration
  logging: {
    level: process.env.LOG_LEVEL || 'warn',
    debugMode: process.env.DEBUG_MODE === 'true',
    enableStackTrace: false, // Disabled in production for security
    enableFunctionNames: true,
  },

  // Validation Rules
  validation: {
    email: {
      maxLength: 320,
      requireVerification: true,
    },
    share: {
      maxRecipients: 25,
      maxMessageLength: 500,
      allowedTypes: ['email', 'sms', 'link'],
    },
    crew: {
      maxMembers: 50,
      maxNameLength: 100,
      maxDescriptionLength: 500,
    },
  },

  // Monitoring and Health Checks
  monitoring: {
    healthCheckPath: '/health',
    metricsPath: '/metrics',
    enableDetailedMetrics: true,
    alertThresholds: {
      errorRate: 0.05, // 5%
      responseTime: 2000, // 2 seconds
      memoryUsage: 0.8, // 80%
    },
  },
};

// Function runtime options for production
export const runtimeOptions = {
  timeoutSeconds: productionConfig.performance.timeoutSeconds,
  memory: `${productionConfig.performance.memoryLimitMB}MB` as const,
  maxInstances: productionConfig.performance.maxConcurrentFunctions,
  minInstances: 1, // Keep at least 1 instance warm
  concurrency: 10,
  vpc: {
    connector: undefined, // Configure if using VPC
    egressSettings: 'ALLOW_ALL' as const,
  },
  invoker: 'public', // For HTTP functions
  region: productionConfig.firebase.region,
};

// Validate critical environment variables
export function validateProductionConfig(): { isValid: boolean; errors: string[] } {
  const errors: string[] = [];

  if (!productionConfig.email.sendgrid.apiKey) {
    errors.push('SENDGRID_API_KEY is required for email functionality');
  }

  if (productionConfig.features.smsSharing && !productionConfig.sms.twilio.accountSid) {
    errors.push('TWILIO_ACCOUNT_SID is required when SMS sharing is enabled');
  }

  if (productionConfig.features.smsSharing && !productionConfig.sms.twilio.authToken) {
    errors.push('TWILIO_AUTH_TOKEN is required when SMS sharing is enabled');
  }

  if (!process.env.FIREBASE_PROJECT_ID) {
    errors.push('FIREBASE_PROJECT_ID is required');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}

export default productionConfig;