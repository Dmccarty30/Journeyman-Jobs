# Security Layer Documentation

Comprehensive security implementation for Journeyman Jobs Flutter app.

## Overview

This security layer provides defense-in-depth protection for the application through:

1. **Input Validation** - Prevent injection attacks and ensure data integrity
2. **Rate Limiting** - Prevent abuse and resource exhaustion
3. **Secure Service Wrappers** - Safe Firestore operations with automatic validation

## Components

### 1. Input Validator (`input_validator.dart`)

Comprehensive validation and sanitization for all user inputs and Firestore operations.

#### Features

- **Email Validation**: RFC 5322 compliance, length limits, format checking
- **Password Validation**: Strength requirements (8+ chars, upper/lower/number/special)
- **Firestore Injection Prevention**: Field name, document ID, and collection path sanitization
- **String Validation**: Length bounds, character filtering
- **Number Range Validation**: Min/max bounds with NaN/Infinity checks
- **IBEW-Specific Validation**: Local numbers, classifications, wages

#### Usage Examples

```dart
// Email validation
try {
  final email = InputValidator.sanitizeEmail('  User@Example.COM  ');
  // Returns: 'user@example.com'
} on ValidationException catch (e) {
  print(e.message); // 'Invalid email format'
}

// Password validation
try {
  InputValidator.validatePassword('SecurePass123!');
  // Valid password
} on ValidationException catch (e) {
  print(e.message); // 'Password must contain at least one uppercase letter'
}

// Firestore field sanitization (injection prevention)
try {
  final field = InputValidator.sanitizeFirestoreField('userName');
  // Returns: 'userName'

  InputValidator.sanitizeFirestoreField('user.name');
  // Throws: ValidationException - prevents injection
} on ValidationException catch (e) {
  print(e.message);
}

// IBEW-specific validation
try {
  InputValidator.validateLocalNumber(123); // Valid: 1-9999
  InputValidator.validateClassification('Inside Wireman'); // Valid
  InputValidator.validateWage(45.50); // Valid: $1-$999.99
} on ValidationException catch (e) {
  print(e.message);
}
```

#### Security Guarantees

- **No SQL/NoSQL Injection**: All Firestore field names sanitized
- **Email Format Safety**: RFC 5322 compliance prevents malformed addresses
- **Strong Passwords**: Enforces industry-standard password requirements
- **Safe String Handling**: Removes control characters and zero-width chars

### 2. Rate Limiter (`rate_limiter.dart`)

Token bucket algorithm implementation for rate limiting with exponential backoff.

#### Features

- **Per-User Limits**: Track requests per user ID
- **Per-IP Limits**: Track unauthenticated requests by IP
- **Configurable Rates**: Different limits for different operation types
- **Exponential Backoff**: Automatic backoff for repeat violations
- **Automatic Cleanup**: Idle bucket removal to prevent memory leaks

#### Default Configurations

| Operation | Max Requests | Window | Notes |
|-----------|--------------|--------|-------|
| auth | 5 | 60s | Login/signup attempts per user |
| firestore_read | 100 | 60s | Read operations per user |
| firestore_write | 50 | 60s | Write operations (cost: 2 tokens) |
| api | 100 | 60s | General API calls |
| default | 100 | 60s | Fallback for unknown operations |

#### IP-Based Rate Limiting

| Operation | Max Requests | Window | Notes |
|-----------|--------------|--------|-------|
| auth | 10 | 300s (5min) | More restrictive for IPs |
| api | 50 | 60s | Limit unauthenticated API access |

#### Usage Examples

```dart
// Basic rate limiting
final rateLimiter = RateLimiter();

if (await rateLimiter.isAllowed('user123', operation: 'auth')) {
  // Proceed with authentication
  await authService.signIn(email, password);
} else {
  // Show rate limit error
  final retryAfter = rateLimiter.getRetryAfter('user123', operation: 'auth');
  showError('Too many attempts. Please wait ${retryAfter.inSeconds} seconds');
}

// Check remaining tokens
final remaining = rateLimiter.getRemainingTokens('user123', operation: 'auth');
print('You have $remaining login attempts remaining');

// Reset rate limit (use sparingly - e.g., after successful 2FA)
rateLimiter.reset('user123', operation: 'auth');

// Custom configuration
final customRateLimiter = RateLimiter(
  customConfigs: {
    'custom_operation': RateLimitConfig(
      maxRequests: 20,
      windowSeconds: 30,
      costPerRequest: 1,
    ),
  },
);

// IP-based rate limiting
final ipRateLimiter = IpRateLimiter();

if (await ipRateLimiter.isAllowed('192.168.1.1', operation: 'auth')) {
  // Allow login attempt from this IP
}
```

#### Exponential Backoff

Rate limiter automatically applies exponential backoff for repeat violations:

| Violations | Backoff Multiplier | Example Wait Time |
|------------|-------------------|-------------------|
| 1 | 1x | 10 seconds |
| 2 | 2x | 20 seconds |
| 3 | 4x | 40 seconds |
| 4 | 8x | 80 seconds |
| 5+ | 16-32x | 160-320 seconds |

### 3. Secure Firestore Service (`secure_firestore_service.dart`)

Secure wrapper for Firestore operations with automatic validation and rate limiting.

#### Features

- **Automatic Input Validation**: All parameters validated before Firestore calls
- **Rate Limiting**: Write operations automatically rate limited
- **IBEW Field Validation**: Job-specific field validation
- **Injection Prevention**: Sanitizes all field names and document IDs
- **Safe Queries**: Validated field names in where clauses

#### Usage Examples

```dart
final secureFirestore = SecureFirestoreService();

// Safe document operations
try {
  // Get document (validates collection path and document ID)
  final doc = await secureFirestore.getDocument(
    collection: 'users',
    documentId: userId,
  );

  // Set document (validates all field names)
  await secureFirestore.setDocument(
    collection: 'users',
    documentId: userId,
    data: {
      'name': 'John Doe',
      'email': 'john@example.com',
      'preferences': {
        'theme': 'dark',  // Nested fields also validated
      },
    },
    userId: userId,
  );

  // Update document
  await secureFirestore.updateDocument(
    collection: 'users',
    documentId: userId,
    data: {'name': 'Jane Doe'},
    userId: userId,
  );

  // Delete document
  await secureFirestore.deleteDocument(
    collection: 'users',
    documentId: userId,
    userId: userId,
  );
} on ValidationException catch (e) {
  print('Validation error: ${e.message}');
} on RateLimitException catch (e) {
  print('Rate limit exceeded: retry after ${e.retryAfter.inSeconds}s');
}

// Safe queries
try {
  // Simple query (validates field name)
  final jobs = await secureFirestore.query(
    collection: 'jobs',
    field: 'local',
    value: 123,
    limit: 50,
  );

  // Multiple conditions (all fields validated)
  final filteredJobs = await secureFirestore.queryMultiple(
    collection: 'jobs',
    conditions: {
      'local': 123,
      'classification': 'Inside Wireman',
    },
  );

  // Collection with pagination
  final page1 = await secureFirestore.getCollection(
    collection: 'jobs',
    limit: 20,
  );

  final page2 = await secureFirestore.getCollection(
    collection: 'jobs',
    limit: 20,
    startAfter: page1.docs.last,
  );
} on ValidationException catch (e) {
  print('Invalid query: ${e.message}');
}

// IBEW-specific job creation
try {
  await secureFirestore.createJobDocument(
    documentId: jobId,
    jobData: {
      'company': 'ABC Electric',
      'local': 123,              // Validated: 1-9999
      'classification': 'Inside Wireman',  // Validated against allowed list
      'wage': 45.50,             // Validated: $1-$999.99
      'location': 'Seattle, WA',
    },
    userId: userId,
  );
} on ValidationException catch (e) {
  print('Invalid job data: ${e.message}');
}
```

## Integration with Existing Services

### Auth Service Integration

The `AuthService` has been updated with comprehensive security:

```dart
// Email/Password Sign Up
try {
  await authService.signUpWithEmailAndPassword(
    email: 'user@example.com',  // Auto-sanitized and validated
    password: 'SecurePass123!',  // Strength validated
  );
} on ValidationException catch (e) {
  showError('Invalid input: $e');
} on RateLimitException catch (e) {
  showError('Too many attempts: retry after ${e.retryAfter.inSeconds}s');
} catch (e) {
  showError('Sign up failed: $e');
}

// Email/Password Sign In
try {
  await authService.signInWithEmailAndPassword(
    email: 'user@example.com',  // Auto-sanitized and validated
    password: 'password123',
  );
} on ValidationException catch (e) {
  showError('Invalid input: $e');
} on RateLimitException catch (e) {
  showError('Too many attempts: retry after ${e.retryAfter.inSeconds}s');
}

// Password Reset
await authService.sendPasswordResetEmail(
  email: 'user@example.com',  // Auto-sanitized and validated
);

// Update Password
await authService.updatePassword(
  newPassword: 'NewSecurePass456!',  // Strength validated
);

// Update Email
await authService.updateEmail(
  newEmail: 'new@example.com',  // Auto-sanitized and validated
);
```

## Security Best Practices

### 1. Always Use Validators

**DO**:
```dart
final email = InputValidator.sanitizeEmail(userInput);
await authService.signIn(email, password);
```

**DON'T**:
```dart
await authService.signIn(userInput, password); // Unvalidated input
```

### 2. Handle Rate Limit Exceptions

**DO**:
```dart
try {
  await performOperation();
} on RateLimitException catch (e) {
  showError('Please wait ${e.retryAfter.inSeconds} seconds');
}
```

**DON'T**:
```dart
await performOperation(); // Unhandled rate limit exception
```

### 3. Use Secure Firestore Service

**DO**:
```dart
final secureFirestore = SecureFirestoreService();
await secureFirestore.query(
  collection: 'jobs',
  field: fieldName,  // Automatically validated
  value: value,
);
```

**DON'T**:
```dart
await FirebaseFirestore.instance
  .collection('jobs')
  .where(fieldName, isEqualTo: value)  // No validation
  .get();
```

### 4. Validate IBEW-Specific Fields

**DO**:
```dart
await secureFirestore.createJobDocument(
  documentId: jobId,
  jobData: jobData,  // Auto-validates local, classification, wage
  userId: userId,
);
```

**DON'T**:
```dart
await firestore.collection('jobs').doc(jobId).set(jobData); // No IBEW validation
```

## Testing

All security components have comprehensive unit tests:

```bash
# Run all security tests
flutter test test/security/

# Run specific test suites
flutter test test/security/input_validator_test.dart
flutter test test/security/rate_limiter_test.dart
flutter test test/security/secure_firestore_service_test.dart
```

### Test Coverage

- **InputValidator**: 95%+ coverage
  - Email validation (valid/invalid formats)
  - Password strength (all requirements)
  - Firestore injection prevention
  - String/number validation
  - IBEW-specific validation

- **RateLimiter**: 90%+ coverage
  - Token bucket algorithm
  - Rate limit enforcement
  - Exponential backoff
  - Per-user/per-IP isolation
  - Cleanup mechanisms

- **SecureFirestoreService**: 85%+ coverage
  - Document operations with validation
  - Query operations with field validation
  - Rate limiting integration
  - IBEW field validation

## Error Handling

### ValidationException

Thrown when input validation fails:

```dart
try {
  InputValidator.validatePassword('weak');
} on ValidationException catch (e) {
  print(e.message);     // "Password must be at least 8 characters long"
  print(e.fieldName);   // "password"
  print(e.toString());  // "ValidationException in password: Password must..."
}
```

### RateLimitException

Thrown when rate limit is exceeded:

```dart
try {
  await rateLimiter.isAllowed('user123', operation: 'auth', throwOnLimit: true);
} on RateLimitException catch (e) {
  print(e.message);      // "Rate limit exceeded for auth"
  print(e.retryAfter);   // Duration(seconds: 30)
  print(e.operation);    // "auth"
}
```

## Performance Considerations

### Rate Limiter Optimization

- **Automatic Cleanup**: Idle buckets removed every 5 minutes (configurable)
- **Memory Efficient**: Only active users tracked
- **Fast Operations**: O(1) token bucket checks

### Input Validation Performance

- **Pre-compiled Regex**: Email and field validation uses cached patterns
- **Early Returns**: Validation fails fast on first error
- **Minimal Allocation**: Reuses string instances where possible

## Security Audit Checklist

- [x] Email validation (RFC 5322 compliance)
- [x] Password strength validation (8+ chars, complexity)
- [x] Firestore injection prevention (field/doc/collection)
- [x] Rate limiting (auth, Firestore reads/writes, API)
- [x] Exponential backoff for violations
- [x] Per-user and per-IP rate limiting
- [x] IBEW-specific field validation
- [x] Input sanitization for display (XSS prevention)
- [x] Number range validation (NaN/Infinity checks)
- [x] Comprehensive error handling
- [x] Unit test coverage (>85%)
- [x] Integration tests for auth service
- [x] Documentation and usage examples

## Future Enhancements

1. **Advanced Threat Detection**
   - Behavioral analysis for suspicious patterns
   - Geo-location based rate limiting
   - Device fingerprinting

2. **Enhanced Validation**
   - Content Security Policy (CSP) headers
   - Additional IBEW field validations
   - Custom validation rules per collection

3. **Monitoring & Alerting**
   - Real-time rate limit violation alerts
   - Security event logging
   - Analytics dashboard for security metrics

4. **Performance Optimization**
   - Distributed rate limiting (Redis)
   - Caching for validation results
   - Async validation pipelines

## Contributing

When adding new features that accept user input:

1. **Always validate inputs** using `InputValidator`
2. **Apply rate limiting** for resource-intensive operations
3. **Add unit tests** with >80% coverage
4. **Update documentation** with usage examples
5. **Follow security best practices** outlined in this document

## Support

For security concerns or questions:

1. Review this documentation
2. Check unit tests for usage examples
3. Consult OWASP guidelines for web application security
4. Open an issue for security vulnerabilities (use private disclosure)

---

**Last Updated**: 2025-10-25
**Version**: 1.0.0
**Status**: Production Ready
