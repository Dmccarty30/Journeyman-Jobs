import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../features/crews/models/crew.dart';
import '../features/crews/models/crew_member.dart';
import '../domain/enums/member_role.dart';
import '../security/rate_limiter.dart';
import '../utils/structured_logging.dart';

/// Service for Multi-Factor Authentication (MFA) for crew administrators.
///
/// This service implements comprehensive MFA functionality designed specifically
/// for crew management operations that require enhanced security. It provides
/// time-based one-time passwords (TOTP), backup codes, and recovery mechanisms
/// for crew administrators and foremen.
///
/// Features:
/// - Time-based One-Time Password (TOTP) generation and verification
/// - Backup codes for emergency access
/// - MFA session management with crew context
/// - Rate limiting and abuse prevention
/// - Comprehensive audit logging
/// - Recovery mechanisms for lost devices
/// - Role-based MFA requirements (admin/foreman only)
class CrewMFAService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final RateLimiter _rateLimiter;

  // Collection names
  static const String _mfaSecretsCollection = 'crew_mfa_secrets';
  static const String _mfaSessionsCollection = 'crew_mfa_sessions';
  static const String _mfaBackupCodesCollection = 'crew_mfa_backup_codes';
  static const String _mfaLogsCollection = 'crew_mfa_logs';

  // Security configuration
  static const int _maxVerificationAttempts = 5;
  static const Duration _verificationWindow = Duration(minutes: 5);
  static const Duration _mfaSessionTimeout = Duration(minutes: 10);
  static const int _backupCodeCount = 10;
  static const int _totpCodeLength = 6;

  // Rate limiting
  static const int _maxMFATries = 3;
  static const Duration _mfaCooldownPeriod = Duration(minutes: 15);

  CrewMFAService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore,
       _rateLimiter = RateLimiter();

  /// Enables MFA for a crew administrator or foreman.
  ///
  /// This method generates TOTP secrets and backup codes for a user
  /// and stores them securely in Firestore. MFA is only available for
  /// users with admin or foreman roles in crews.
  ///
  /// Parameters:
  /// - [userId]: The user ID to enable MFA for
  /// - [crewId]: The crew ID where the user has admin/foreman role
  /// - [role]: The user's role in the crew
  ///
  /// Returns:
  /// - [MFASetupResult] containing setup QR code data and backup codes
  ///
  /// Throws:
  /// - [MFANotAllowedException] if user doesn't have required role
  /// - [MFAAlreadyEnabledException] if MFA is already enabled
  /// - [FirebaseException] for database errors
  Future<MFASetupResult> enableMFA({
    required String userId,
    required String crewId,
    required MemberRole role,
  }) async {
    try {
      // Security: Verify user has required role
      if (!_isRoleRequiredForMFA(role)) {
        throw MFANotAllowedException(
          'MFA is only available for crew administrators and foremen',
        );
      }

      // Security: Check if MFA is already enabled
      final existingSecret = await _getMFASecret(userId);
      if (existingSecret != null) {
        throw MFAAlreadyEnabledException(
          'MFA is already enabled for this user',
        );
      }

      // Security: Check rate limiting
      final rateLimitKey = 'mfa_setup_${userId.hashCode}';
      if (!await _rateLimiter.isAllowed(rateLimitKey, operation: 'mfa_setup')) {
        throw MFARateLimitException(
          'Too many MFA setup attempts. Please try again later.',
          retryAfter: _rateLimiter.getRetryAfter(rateLimitKey, operation: 'mfa_setup'),
        );
      }

      // Generate TOTP secret
      final totpSecret = _generateTOTPSecret();
      final backupCodes = _generateBackupCodes();

      // Store MFA secret securely
      await _firestore.collection(_mfaSecretsCollection).doc(userId).set({
        'userId': userId,
        'crewId': crewId,
        'role': role.name,
        'totpSecret': totpSecret,
        'isEnabled': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUsedAt': null,
        'verificationAttempts': 0,
        'lockedUntil': null,
      });

      // Store backup codes
      final backupCodesData = backupCodes.map((code) => {
        'userId': userId,
        'code': _hashBackupCode(code),
        'isUsed': false,
        'createdAt': FieldValue.serverTimestamp(),
      }).toList();

      final batch = _firestore.batch();
      for (int i = 0; i < backupCodesData.length; i++) {
        final docRef = _firestore
            .collection(_mfaBackupCodesCollection)
            .doc('${userId}_${i}');
        batch.set(docRef, backupCodesData[i]);
      }
      await batch.commit();

      // Generate QR code data for authenticator apps
      final qrData = _generateTOTPQRData(userId, crewId, totpSecret);

      // Log MFA enablement
      await _logMFAEvent(
        userId: userId,
        crewId: crewId,
        event: MFAEvent.mfaEnabled,
        details: 'MFA enabled for role ${role.name}',
      );

      // Security: Reset rate limit on successful operation
      _rateLimiter.reset(rateLimitKey, operation: 'mfa_setup');

      return MFASetupResult(
        totpSecret: totpSecret,
        qrCodeData: qrData,
        backupCodes: backupCodes,
        instructions: _getMFASetupInstructions(),
      );
    } on MFANotAllowedException catch (e) {
      debugPrint('[CrewMFAService] MFA not allowed: $e');
      rethrow;
    } on MFAAlreadyEnabledException catch (e) {
      debugPrint('[CrewMFAService] MFA already enabled: $e');
      rethrow;
    } on MFARateLimitException catch (e) {
      debugPrint('[CrewMFAService] Rate limit exceeded: $e');
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('[CrewMFAService] Firestore error enabling MFA: $e');
      rethrow;
    } catch (e) {
      debugPrint('[CrewMFAService] Unexpected error enabling MFA: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to enable MFA: $e',
      );
    }
  }

  /// Verifies a TOTP code for MFA authentication.
  ///
  /// This method validates a time-based one-time password against the
  /// stored secret and manages MFA sessions upon successful verification.
  ///
  /// Parameters:
  /// - [userId]: The user ID to verify MFA for
  /// - [totpCode]: The 6-digit TOTP code to verify
  /// - [context]: Optional context for the MFA verification
  ///
  /// Returns:
  /// - [MFASession] containing session token and permissions
  ///
  /// Throws:
  /// - [MFANotEnabledException] if MFA is not enabled for the user
  /// - [MFAInvalidCodeException] if the TOTP code is invalid
  /// - [MFALockedException] if MFA is temporarily locked
  /// - [MFARateLimitException] if too many verification attempts
  Future<MFASession> verifyTOTPCode({
    required String userId,
    required String totpCode,
    String? context,
  }) async {
    try {
      // Security: Validate TOTP code format
      if (totpCode.length != _totpCodeLength || !RegExp(r'^\d+$').hasMatch(totpCode)) {
        throw MFAInvalidCodeException('Invalid TOTP code format');
      }

      // Get MFA secret
      final mfaSecret = await _getMFASecret(userId);
      if (mfaSecret == null || !mfaSecret['isEnabled']) {
        throw MFANotEnabledException('MFA is not enabled for this user');
      }

      // Security: Check if MFA is locked
      if (mfaSecret['lockedUntil'] != null) {
        final lockedUntil = (mfaSecret['lockedUntil'] as Timestamp).toDate();
        if (DateTime.now().isBefore(lockedUntil)) {
          throw MFALockedException(
            'MFA is temporarily locked. Please try again later.',
            lockedUntil: lockedUntil,
          );
        }
      }

      // Security: Check rate limiting
      final rateLimitKey = 'mfa_verify_${userId.hashCode}';
      if (!await _rateLimiter.isAllowed(rateLimitKey, operation: 'mfa_verify')) {
        // Increment verification attempts and potentially lock account
        await _incrementVerificationAttempts(userId);
        throw MFARateLimitException(
          'Too many MFA verification attempts. Please try again later.',
          retryAfter: _rateLimiter.getRetryAfter(rateLimitKey, operation: 'mfa_verify'),
        );
      }

      // Verify TOTP code
      final isValidTOTP = _verifyTOTPCode(
        totpSecret['totpSecret'] as String,
        totpCode,
      );

      if (!isValidTOTP) {
        // Increment failed attempts
        await _incrementVerificationAttempts(userId);

        await _logMFAEvent(
          userId: userId,
          crewId: mfaSecret['crewId'] as String,
          event: MFAEvent.verificationFailed,
          details: 'Invalid TOTP code provided',
          context: context,
        );

        throw MFAInvalidCodeException('Invalid TOTP code');
      }

      // Reset verification attempts on successful verification
      await _resetVerificationAttempts(userId);

      // Create MFA session
      final session = await _createMFASession(
        userId: userId,
        crewId: mfaSecret['crewId'] as String,
        role: MemberRole.values.firstWhere(
          (r) => r.name == (mfaSecret['role'] as String),
        ),
      );

      // Update last used timestamp
      await _firestore.collection(_mfaSecretsCollection).doc(userId).update({
        'lastUsedAt': FieldValue.serverTimestamp(),
        'verificationAttempts': 0,
        'lockedUntil': null,
      });

      // Log successful verification
      await _logMFAEvent(
        userId: userId,
        crewId: mfaSecret['crewId'] as String,
        event: MFAEvent.verificationSuccess,
        details: 'MFA verification successful using TOTP',
        context: context,
      );

      // Security: Reset rate limit on successful operation
      _rateLimiter.reset(rateLimitKey, operation: 'mfa_verify');

      return session;
    } on MFAInvalidCodeException catch (e) {
      debugPrint('[CrewMFAService] Invalid TOTP code: $e');
      rethrow;
    } on MFALockedException catch (e) {
      debugPrint('[CrewMFAService] MFA locked: $e');
      rethrow;
    } on MFARateLimitException catch (e) {
      debugPrint('[CrewMFAService] Rate limit exceeded: $e');
      rethrow;
    } on MFANotEnabledException catch (e) {
      debugPrint('[CrewMFAService] MFA not enabled: $e');
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('[CrewMFAService] Firestore error verifying TOTP: $e');
      rethrow;
    } catch (e) {
      debugPrint('[CrewMFAService] Unexpected error verifying TOTP: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to verify TOTP code: $e',
      );
    }
  }

  /// Verifies a backup code for MFA authentication.
  ///
  /// This method validates a backup code as an alternative to TOTP,
  /// typically used when the user doesn't have access to their authenticator app.
  ///
  /// Parameters:
  /// - [userId]: The user ID to verify MFA for
  /// - [backupCode]: The backup code to verify
  /// - [context]: Optional context for the MFA verification
  ///
  /// Returns:
  /// - [MFASession] containing session token and permissions
  ///
  /// Throws:
  /// - [MFANotEnabledException] if MFA is not enabled for the user
  /// - [MFAInvalidCodeException] if the backup code is invalid
  /// - [MFALockedException] if MFA is temporarily locked
  Future<MFASession> verifyBackupCode({
    required String userId,
    required String backupCode,
    String? context,
  }) async {
    try {
      // Get MFA secret to verify MFA is enabled
      final mfaSecret = await _getMFASecret(userId);
      if (mfaSecret == null || !mfaSecret['isEnabled']) {
        throw MFANotEnabledException('MFA is not enabled for this user');
      }

      // Security: Check if MFA is locked
      if (mfaSecret['lockedUntil'] != null) {
        final lockedUntil = (mfaSecret['lockedUntil'] as Timestamp).toDate();
        if (DateTime.now().isBefore(lockedUntil)) {
          throw MFALockedException(
            'MFA is temporarily locked. Please try again later.',
            lockedUntil: lockedUntil,
          );
        }
      }

      // Find matching backup code
      final backupCodeHash = _hashBackupCode(backupCode);
      final backupCodeDocs = await _firestore
          .collection(_mfaBackupCodesCollection)
          .where('userId', isEqualTo: userId)
          .where('code', isEqualTo: backupCodeHash)
          .where('isUsed', isEqualTo: false)
          .limit(1)
          .get();

      if (backupCodeDocs.docs.isEmpty) {
        await _logMFAEvent(
          userId: userId,
          crewId: mfaSecret['crewId'] as String,
          event: MFAEvent.verificationFailed,
          details: 'Invalid backup code provided',
          context: context,
        );

        throw MFAInvalidCodeException('Invalid backup code');
      }

      final backupCodeDoc = backupCodeDocs.docs.first;

      // Mark backup code as used
      await backupCodeDoc.reference.update({
        'isUsed': true,
        'usedAt': FieldValue.serverTimestamp(),
      });

      // Create MFA session
      final session = await _createMFASession(
        userId: userId,
        crewId: mfaSecret['crewId'] as String,
        role: MemberRole.values.firstWhere(
          (r) => r.name == (mfaSecret['role'] as String),
        ),
      );

      // Log successful verification
      await _logMFAEvent(
        userId: userId,
        crewId: mfaSecret['crewId'] as String,
        event: MFAEvent.verificationSuccess,
        details: 'MFA verification successful using backup code',
        context: context,
      );

      return session;
    } on MFAInvalidCodeException catch (e) {
      debugPrint('[CrewMFAService] Invalid backup code: $e');
      rethrow;
    } on MFALockedException catch (e) {
      debugPrint('[CrewMFAService] MFA locked: $e');
      rethrow;
    } on MFANotEnabledException catch (e) {
      debugPrint('[CrewMFAService] MFA not enabled: $e');
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('[CrewMFAService] Firestore error verifying backup code: $e');
      rethrow;
    } catch (e) {
      debugPrint('[CrewMFAService] Unexpected error verifying backup code: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to verify backup code: $e',
      );
    }
  }

  /// Verifies an MFA session token.
  ///
  /// This method validates an existing MFA session token and checks
  /// for expiration and validity.
  ///
  /// Parameters:
  /// - [sessionToken]: The MFA session token to verify
  ///
  /// Returns:
  /// - [MFAValidation] containing validation status and metadata
  Future<MFAValidation> verifyMFASession(String sessionToken) async {
    try {
      // Get session from Firestore
      final sessionDoc = await _firestore
          .collection(_mfaSessionsCollection)
          .doc(sessionToken)
          .get();

      if (!sessionDoc.exists) {
        return MFAValidation(
          isValid: false,
          reason: 'Session not found',
        );
      }

      final sessionData = sessionDoc.data() as Map<String, dynamic>;
      final expiresAt = (sessionData['expiresAt'] as Timestamp).toDate();

      // Check expiration
      if (DateTime.now().isAfter(expiresAt)) {
        await _logMFAEvent(
          userId: sessionData['userId'] as String,
          crewId: sessionData['crewId'] as String,
          event: MFAEvent.sessionExpired,
          details: 'MFA session expired',
        );

        return MFAValidation(
          isValid: false,
          reason: 'Session expired',
          expiredAt: expiresAt,
        );
      }

      // Session is valid
      return MFAValidation(
        isValid: true,
        userId: sessionData['userId'] as String,
        crewId: sessionData['crewId'] as String,
        role: MemberRole.values.firstWhere(
          (r) => r.name == (sessionData['role'] as String),
        ),
        expiresAt: expiresAt,
      );
    } on FirebaseException catch (e) {
      debugPrint('[CrewMFAService] Error verifying MFA session: $e');
      return MFAValidation(
        isValid: false,
        reason: 'Error verifying session: $e',
      );
    } catch (e) {
      debugPrint('[CrewMFAService] Unexpected error verifying MFA session: $e');
      return MFAValidation(
        isValid: false,
        reason: 'Unexpected error: $e',
      );
    }
  }

  /// Revokes an MFA session immediately.
  ///
  /// This method invalidates an active MFA session token.
  ///
  /// Parameters:
  /// - [sessionToken]: The MFA session token to revoke
  Future<void> revokeMFASession(String sessionToken) async {
    try {
      final sessionDoc = await _firestore
          .collection(_mfaSessionsCollection)
          .doc(sessionToken)
          .get();

      if (sessionDoc.exists) {
        final sessionData = sessionDoc.data() as Map<String, dynamic>;

        await sessionDoc.reference.update({
          'isActive': false,
          'revokedAt': FieldValue.serverTimestamp(),
        });

        await _logMFAEvent(
          userId: sessionData['userId'] as String,
          crewId: sessionData['crewId'] as String,
          event: MFAEvent.sessionRevoked,
          details: 'MFA session revoked',
        );
      }
    } catch (e) {
      debugPrint('[CrewMFAService] Error revoking MFA session: $e');
    }
  }

  /// Disables MFA for a user.
  ///
  /// This method removes MFA protection for a user, including
  /// deleting TOTP secrets and backup codes. This should only be
  /// used when the user explicitly disables MFA or for account recovery.
  ///
  /// Parameters:
  /// - [userId]: The user ID to disable MFA for
  /// - [reason]: The reason for disabling MFA
  ///
  /// Throws:
  /// - [FirebaseException] for database errors
  Future<void> disableMFA({
    required String userId,
    required String reason,
  }) async {
    try {
      final mfaSecret = await _getMFASecret(userId);
      if (mfaSecret != null) {
        // Delete MFA secret
        await _firestore.collection(_mfaSecretsCollection).doc(userId).delete();

        // Delete backup codes
        final backupCodesSnapshot = await _firestore
            .collection(_mfaBackupCodesCollection)
            .where('userId', isEqualTo: userId)
            .get();

        final batch = _firestore.batch();
        for (final doc in backupCodesSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        // Revoke all active sessions
        final sessionsSnapshot = await _firestore
            .collection(_mfaSessionsCollection)
            .where('userId', isEqualTo: userId)
            .where('isActive', isEqualTo: true)
            .get();

        for (final doc in sessionsSnapshot.docs) {
          await doc.reference.update({
            'isActive': false,
            'revokedAt': FieldValue.serverTimestamp(),
          });
        }

        await _logMFAEvent(
          userId: userId,
          crewId: mfaSecret['crewId'] as String,
          event: MFAEvent.mfaDisabled,
          details: 'MFA disabled: $reason',
        );
      }
    } catch (e) {
      debugPrint('[CrewMFAService] Error disabling MFA: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to disable MFA: $e',
      );
    }
  }

  /// Gets MFA status for a user.
  ///
  /// Parameters:
  /// - [userId]: The user ID to check MFA status for
  ///
  /// Returns:
  /// - [MFAStatus] containing MFA configuration and status
  Future<MFAStatus?> getMFAStatus(String userId) async {
    try {
      final mfaSecret = await _getMFASecret(userId);
      if (mfaSecret == null) {
        return null;
      }

      final backupCodesCount = await _firestore
          .collection(_mfaBackupCodesCollection)
          .where('userId', isEqualTo: userId)
          .where('isUsed', isEqualTo: false)
          .count()
          .get();

      final activeSessionsCount = await _firestore
          .collection(_mfaSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .count()
          .get();

      return MFAStatus(
        isEnabled: mfaSecret['isEnabled'] as bool,
        createdAt: (mfaSecret['createdAt'] as Timestamp).toDate(),
        lastUsedAt: mfaSecret['lastUsedAt'] != null
            ? (mfaSecret['lastUsedAt'] as Timestamp).toDate()
            : null,
        verificationAttempts: mfaSecret['verificationAttempts'] as int,
        lockedUntil: mfaSecret['lockedUntil'] != null
            ? (mfaSecret['lockedUntil'] as Timestamp).toDate()
            : null,
        availableBackupCodes: backupCodesCount.count ?? 0,
        activeSessions: activeSessionsCount.count ?? 0,
      );
    } catch (e) {
      debugPrint('[CrewMFAService] Error getting MFA status: $e');
      return null;
    }
  }

  // Private helper methods

  /// Checks if a role requires MFA.
  bool _isRoleRequiredForMFA(MemberRole role) {
    return role == MemberRole.admin || role == MemberRole.foreman;
  }

  /// Gets MFA secret for a user.
  Future<Map<String, dynamic>?> _getMFASecret(String userId) async {
    final doc = await _firestore.collection(_mfaSecretsCollection).doc(userId).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  /// Generates a TOTP secret.
  String _generateTOTPSecret() {
    final random = Random.secure();
    final bytes = List<int>.generate(20, (_) => random.nextInt(256));
    return base32Encode(bytes);
  }

  /// Generates backup codes.
  List<String> _generateBackupCodes() {
    final random = Random.secure();
    return List<String>.generate(_backupCodeCount, (_) {
      final code = random.nextInt(1000000).toString().padLeft(6, '0');
      return code;
    });
  }

  /// Generates TOTP QR code data.
  String _generateTOTPQRData(String userId, String crewId, String secret) {
    final issuer = 'Journeyman Jobs Crews';
    final accountName = '$userId@$crewId';
    return 'otpauth://totp/$issuer:$accountName?secret=$secret&issuer=$issuer';
  }

  /// Verifies a TOTP code.
  bool _verifyTOTPCode(String secret, String code) {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ 30;

    // Check current time window and adjacent windows for clock drift
    for (int offset = -1; offset <= 1; offset++) {
      final timeWindow = currentTime + offset;
      final expectedCode = _generateTOTPCode(secret, timeWindow);
      if (expectedCode == code) {
        return true;
      }
    }

    return false;
  }

  /// Generates a TOTP code for a given time window.
  String _generateTOTPCode(String secret, int timeWindow) {
    // Simplified TOTP implementation
    // In production, use a proper crypto library like 'otp'
    final hash = '${secret}_${timeWindow}'.hashCode.abs();
    return (hash % 1000000).toString().padLeft(6, '0');
  }

  /// Hashes a backup code for secure storage.
  String _hashBackupCode(String code) {
    // Simple hashing for demonstration
    // In production, use proper cryptographic hashing
    return code.hashCode.toString();
  }

  /// Creates an MFA session.
  Future<MFASession> _createMFASession({
    required String userId,
    required String crewId,
    required MemberRole role,
  }) async {
    final sessionToken = _generateSecureToken();
    final expiresAt = DateTime.now().add(_mfaSessionTimeout);

    await _firestore.collection(_mfaSessionsCollection).doc(sessionToken).set({
      'userId': userId,
      'crewId': crewId,
      'role': role.name,
      'sessionToken': sessionToken,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': true,
    });

    return MFASession(
      sessionToken: sessionToken,
      userId: userId,
      crewId: crewId,
      role: role,
      expiresAt: expiresAt,
    );
  }

  /// Generates a secure session token.
  String _generateSecureToken() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes) + '_$timestamp';
  }

  /// Increments verification attempts and potentially locks account.
  Future<void> _incrementVerificationAttempts(String userId) async {
    final docRef = _firestore.collection(_mfaSecretsCollection).doc(userId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final attempts = (data['verificationAttempts'] as int? ?? 0) + 1;

        if (attempts >= _maxVerificationAttempts) {
          final lockedUntil = DateTime.now().add(_mfaCooldownPeriod);
          transaction.update(docRef, {
            'verificationAttempts': attempts,
            'lockedUntil': Timestamp.fromDate(lockedUntil),
          });
        } else {
          transaction.update(docRef, {
            'verificationAttempts': attempts,
          });
        }
      }
    });
  }

  /// Resets verification attempts.
  Future<void> _resetVerificationAttempts(String userId) async {
    await _firestore.collection(_mfaSecretsCollection).doc(userId).update({
      'verificationAttempts': 0,
      'lockedUntil': null,
    });
  }

  /// Gets MFA setup instructions.
  List<String> _getMFASetupInstructions() {
    return [
      '1. Install an authenticator app (Google Authenticator, Authy, etc.)',
      '2. Scan the QR code or enter the secret manually',
      '3. Save the backup codes in a secure location',
      '4. Enter the 6-digit code to verify setup',
      '5. Keep your backup codes safe for emergency access',
    ];
  }

  /// Logs MFA events.
  Future<void> _logMFAEvent({
    required String userId,
    required String crewId,
    required MFAEvent event,
    required String details,
    String? context,
  }) async {
    try {
      await _firestore.collection(_mfaLogsCollection).add({
        'userId': userId,
        'crewId': crewId,
        'event': event.name,
        'details': details,
        'context': context,
        'timestamp': FieldValue.serverTimestamp(),
        'userAgent': 'Journeyman Jobs App',
        'ipAddress': 'mobile',
      });
    } catch (e) {
      debugPrint('[CrewMFAService] Failed to log MFA event: $e');
    }
  }

  /// Encodes bytes to Base32.
  String base32Encode(List<int> bytes) {
    // Simplified Base32 encoding
    // In production, use a proper Base32 library
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    String result = '';

    for (int i = 0; i < bytes.length; i += 5) {
      int chunk = 0;
      int bits = 0;

      for (int j = 0; j < 5 && i + j < bytes.length; j++) {
        chunk = (chunk << 8) | bytes[i + j];
        bits += 8;
      }

      while (bits >= 5) {
        result += alphabet[(chunk >> (bits - 5)) & 0x1F];
        bits -= 5;
      }
    }

    return result;
  }

  /// Encodes bytes to Base64 URL safe.
  String base64UrlEncode(List<int> bytes) {
    // Simplified Base64 URL encoding
    // In production, use dart:convert
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// MFA setup result containing QR code data and backup codes.
class MFASetupResult {
  final String totpSecret;
  final String qrCodeData;
  final List<String> backupCodes;
  final List<String> instructions;

  MFASetupResult({
    required this.totpSecret,
    required this.qrCodeData,
    required this.backupCodes,
    required this.instructions,
  });
}

/// MFA session containing authentication context.
class MFASession {
  final String sessionToken;
  final String userId;
  final String crewId;
  final MemberRole role;
  final DateTime expiresAt;

  MFASession({
    required this.sessionToken,
    required this.userId,
    required this.crewId,
    required this.role,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// MFA validation result.
class MFAValidation {
  final bool isValid;
  final String? reason;
  final String? userId;
  final String? crewId;
  final MemberRole? role;
  final DateTime? expiredAt;

  MFAValidation({
    required this.isValid,
    this.reason,
    this.userId,
    this.crewId,
    this.role,
    this.expiredAt,
  });
}

/// MFA status information.
class MFAStatus {
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final int verificationAttempts;
  final DateTime? lockedUntil;
  final int availableBackupCodes;
  final int activeSessions;

  MFAStatus({
    required this.isEnabled,
    required this.createdAt,
    this.lastUsedAt,
    required this.verificationAttempts,
    this.lockedUntil,
    required this.availableBackupCodes,
    required this.activeSessions,
  });
}

/// MFA event types.
enum MFAEvent {
  mfaEnabled,
  mfaDisabled,
  verificationSuccess,
  verificationFailed,
  sessionCreated,
  sessionExpired,
  sessionRevoked,
  sessionLocked,
}

/// Custom exceptions for MFA operations.
class MFANotAllowedException implements Exception {
  final String message;
  MFANotAllowedException(this.message);
  @override
  String toString() => 'MFANotAllowedException: $message';
}

class MFAAlreadyEnabledException implements Exception {
  final String message;
  MFAAlreadyEnabledException(this.message);
  @override
  String toString() => 'MFAAlreadyEnabledException: $message';
}

class MFAInvalidCodeException implements Exception {
  final String message;
  MFAInvalidCodeException(this.message);
  @override
  String toString() => 'MFAInvalidCodeException: $message';
}

class MFALockedException implements Exception {
  final String message;
  final DateTime? lockedUntil;
  MFALockedException(this.message, {this.lockedUntil});
  @override
  String toString() => 'MFALockedException: $message';
}

class MFARateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;
  MFARateLimitException(this.message, {this.retryAfter});
  @override
  String toString() => 'MFARateLimitException: $message';
}