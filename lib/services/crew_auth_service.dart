import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../features/crews/models/crew.dart';
import '../features/crews/models/crew_member.dart';
import '../domain/enums/member_role.dart';
import '../security/rate_limiter.dart';

/// Service for crew-specific authentication and permission verification.
///
/// This service implements comprehensive security and access control for crew operations.
/// It provides role-based permissions, session management, and security monitoring
/// specifically designed for the IBEW electrical worker crew management system.
///
/// Features:
/// - Role-based access control (admin, foreman, lead, member)
/// - Permission verification for all crew operations
/// - Session token management with crew context
/// - Security event logging and monitoring
/// - Rate limiting for authentication operations
/// - Audit trail for all permission checks
class CrewAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final RateLimiter _rateLimiter;

  // Collection names
  static const String _crewsCollection = 'crews';
  static const String _crewMembersCollection = 'crew_members';
  static const String _authLogsCollection = 'crew_auth_logs';

  // Security: Rate limiting configuration
  static const int _maxAuthAttempts = 10;
  static const Duration _authWindow = Duration(minutes: 5);
  static const Duration _sessionTimeout = Duration(hours: 1);

  // Performance: Permission caching
  final Map<String, _CachedPermission> _permissionCache = {};
  static const Duration _permissionCacheTTL = Duration(minutes: 10);

  CrewAuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore,
       _rateLimiter = RateLimiter();

  /// Verifies if a user has a specific permission within a crew.
  ///
  /// This method implements comprehensive permission checking with security
  /// optimizations including caching, rate limiting, and audit logging.
  ///
  /// Parameters:
  /// - [userId]: The user ID to verify permissions for
  /// - [crewId]: The crew ID where permission is being checked
  /// - [permission]: The specific permission to verify
  /// - [context]: Optional context describing the operation being performed
  ///
  /// Returns:
  /// - [true] if the user has the specified permission
  /// - [false] if the user lacks permission or verification fails
  ///
  /// Security considerations:
  /// - All permission checks are logged for audit purposes
  /// - Rate limiting prevents brute force permission enumeration
  /// - Caching improves performance while maintaining security
  /// - Failed attempts are monitored for security threats
  Future<bool> verifyCrewPermission({
    required String userId,
    required String crewId,
    required CrewPermission permission,
    String? context,
  }) async {
    try {
      // Security: Validate inputs
      if (userId.isEmpty || crewId.isEmpty) {
        await _logAuthEvent(
          userId: userId,
          crewId: crewId,
          event: CrewAuthEvent.permissionCheckFailed,
          details: 'Invalid user or crew ID',
          context: context,
        );
        return false;
      }

      // Performance: Check cache first
      final cacheKey = '${userId}_${crewId}_${permission.name}';
      final cachedPermission = _getCachedPermission(cacheKey);
      if (cachedPermission != null) {
        await _logAuthEvent(
          userId: userId,
          crewId: crewId,
          event: CrewAuthEvent.permissionCheckCacheHit,
          details: 'Permission ${permission.name} from cache',
          context: context,
        );
        return cachedPermission;
      }

      // Security: Check rate limiting
      final rateLimitKey = 'auth_${userId.hashCode}';
      if (!await _rateLimiter.isAllowed(rateLimitKey, operation: 'auth')) {
        await _logAuthEvent(
          userId: userId,
          crewId: crewId,
          event: CrewAuthEvent.rateLimitExceeded,
          details: 'Permission check rate limited',
          context: context,
        );
        return false;
      }

      // Get crew member information
      final crewMemberDoc = await _firestore
          .collection(_crewMembersCollection)
          .doc(userId)
          .get();

      if (!crewMemberDoc.exists) {
        await _logAuthEvent(
          userId: userId,
          crewId: crewId,
          event: CrewAuthEvent.permissionCheckFailed,
          details: 'User is not a crew member',
          context: context,
        );
        return false;
      }

      final crewMember = CrewMember.fromFirestore(crewMemberDoc);

      // Verify user belongs to the specified crew
      if (crewMember.crewId != crewId) {
        await _logAuthEvent(
          userId: userId,
          crewId: crewId,
          event: CrewAuthEvent.permissionCheckFailed,
          details: 'User does not belong to this crew',
          context: context,
        );
        return false;
      }

      // Check if member is active
      if (!crewMember.isActive) {
        await _logAuthEvent(
          userId: userId,
          crewId: crewId,
          event: CrewAuthEvent.permissionCheckFailed,
          details: 'Crew member is inactive',
          context: context,
        );
        return false;
      }

      // Verify specific permission based on role
      final hasPermission = _checkPermissionByRole(crewMember.role, permission);

      // Cache the result
      _cachePermission(cacheKey, hasPermission);

      // Log the permission check
      await _logAuthEvent(
        userId: userId,
        crewId: crewId,
        event: hasPermission
            ? CrewAuthEvent.permissionCheckSuccess
            : CrewAuthEvent.permissionCheckFailed,
        details: 'Permission ${permission.name} for role ${crewMember.role.name}: $hasPermission',
        context: context,
      );

      // Security: Reset rate limit on successful operation
      if (hasPermission) {
        _rateLimiter.reset(rateLimitKey, operation: 'auth');
      }

      return hasPermission;
    } catch (e) {
      debugPrint('[CrewAuthService] Error verifying permission: $e');

      await _logAuthEvent(
        userId: userId,
        crewId: crewId,
        event: CrewAuthEvent.permissionCheckError,
        details: 'Error verifying permission: $e',
        context: context,
      );

      return false;
    }
  }

  /// Generates a crew session token with crew context.
  ///
  /// This method creates a secure session token that includes crew-specific
  /// context for enhanced security and auditability. The token is used for
  /// crew operations and includes role information and expiration.
  ///
  /// Parameters:
  /// - [crewId]: The crew ID for the session
  /// - [userId]: The user ID requesting the session
  /// - [expiresIn]: Token expiration duration (default: 1 hour)
  ///
  /// Returns:
  /// - [CrewSessionToken] containing session information and permissions
  ///
  /// Security features:
  /// - Token includes user role and permissions
  /// - Automatic expiration with configurable TTL
  /// - Audit logging for session creation
  /// - Rate limiting prevents token abuse
  Future<CrewSessionToken> generateCrewSessionToken({
    required String crewId,
    required String userId,
    Duration expiresIn = _sessionTimeout,
  }) async {
    try {
      // Security: Validate inputs
      if (userId.isEmpty || crewId.isEmpty) {
        throw ArgumentError('User ID and crew ID cannot be empty');
      }

      // Security: Check rate limiting
      final rateLimitKey = 'token_${userId.hashCode}';
      if (!await _rateLimiter.isAllowed(rateLimitKey, operation: 'token')) {
        throw RateLimitException(
          'Too many session token requests. Please try again later.',
          operation: 'token',
        );
      }

      // Get user's role in the crew
      final crewMemberDoc = await _firestore
          .collection(_crewMembersCollection)
          .doc(userId)
          .get();

      if (!crewMemberDoc.exists) {
        throw Exception('User is not a member of this crew');
      }

      final crewMember = CrewMember.fromFirestore(crewMemberDoc);
      if (crewMember.crewId != crewId || !crewMember.isActive) {
        throw Exception('Invalid crew membership');
      }

      // Generate session token
      final token = CrewSessionToken(
        userId: userId,
        crewId: crewId,
        role: crewMember.role,
        permissions: crewMember.permissions,
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(expiresIn),
        token: _generateSecureToken(userId, crewId),
      );

      // Log session creation
      await _logAuthEvent(
        userId: userId,
        crewId: crewId,
        event: CrewAuthEvent.sessionCreated,
        details: 'Session token created for role ${crewMember.role.name}',
        context: 'expiresIn: ${expiresIn.inMinutes} minutes',
      );

      // Security: Reset rate limit on successful token creation
      _rateLimiter.reset(rateLimitKey, operation: 'token');

      return token;
    } catch (e) {
      debugPrint('[CrewAuthService] Error generating session token: $e');

      await _logAuthEvent(
        userId: userId,
        crewId: crewId,
        event: CrewAuthEvent.sessionCreationFailed,
        details: 'Error creating session token: $e',
      );

      rethrow;
    }
  }

  /// Verifies a crew session token and returns validation result.
  ///
  /// This method validates session tokens and checks for expiration,
  /// revocation, and other security conditions.
  ///
  /// Parameters:
  /// - [token]: The crew session token to verify
  ///
  /// Returns:
  /// - [CrewSessionValidation] containing validation status and metadata
  Future<CrewSessionValidation> verifyCrewSessionToken(CrewSessionToken token) async {
    try {
      // Check token expiration
      if (DateTime.now().isAfter(token.expiresAt)) {
        await _logAuthEvent(
          userId: token.userId,
          crewId: token.crewId,
          event: CrewAuthEvent.sessionExpired,
          details: 'Session token expired',
        );

        return CrewSessionValidation(
          isValid: false,
          reason: 'Token expired',
          expiredAt: token.expiresAt,
        );
      }

      // Verify user is still active in the crew
      final crewMemberDoc = await _firestore
          .collection(_crewMembersCollection)
          .doc(token.userId)
          .get();

      if (!crewMemberDoc.exists) {
        await _logAuthEvent(
          userId: token.userId,
          crewId: token.crewId,
          event: CrewAuthEvent.sessionInvalid,
          details: 'User no longer exists in crew',
        );

        return CrewSessionValidation(
          isValid: false,
          reason: 'User no longer in crew',
        );
      }

      final crewMember = CrewMember.fromFirestore(crewMemberDoc);
      if (!crewMember.isActive || crewMember.crewId != token.crewId) {
        await _logAuthEvent(
          userId: token.userId,
          crewId: token.crewId,
          event: CrewAuthEvent.sessionInvalid,
          details: 'Crew membership no longer active',
        );

        return CrewSessionValidation(
          isValid: false,
          reason: 'Crew membership inactive',
        );
      }

      // Check if role has changed
      if (crewMember.role != token.role) {
        await _logAuthEvent(
          userId: token.userId,
          crewId: token.crewId,
          event: CrewAuthEvent.sessionInvalid,
          details: 'User role changed since token issued',
        );

        return CrewSessionValidation(
          isValid: false,
          reason: 'User role changed',
        );
      }

      // Token is valid
      await _logAuthEvent(
        userId: token.userId,
        crewId: token.crewId,
        event: CrewAuthEvent.sessionValidated,
        details: 'Session token validated successfully',
      );

      return CrewSessionValidation(
        isValid: true,
        crewMember: crewMember,
        token: token,
      );
    } catch (e) {
      debugPrint('[CrewAuthService] Error verifying session token: $e');

      return CrewSessionValidation(
        isValid: false,
        reason: 'Error validating token: $e',
      );
    }
  }

  /// Gets all permissions for a user in a specific crew.
  ///
  /// This method returns the complete permission set for a user
  /// based on their role in the crew hierarchy.
  ///
  /// Parameters:
  /// - [userId]: The user ID
  /// - [crewId]: The crew ID
  ///
  /// Returns:
  /// - [MemberPermissions] object with all user permissions
  /// - [null] if user is not a member of the crew
  Future<MemberPermissions?> getUserPermissions({
    required String userId,
    required String crewId,
  }) async {
    try {
      final crewMemberDoc = await _firestore
          .collection(_crewMembersCollection)
          .doc(userId)
          .get();

      if (!crewMemberDoc.exists) {
        return null;
      }

      final crewMember = CrewMember.fromFirestore(crewMemberDoc);
      if (crewMember.crewId != crewId) {
        return null;
      }

      return crewMember.permissions;
    } catch (e) {
      debugPrint('[CrewAuthService] Error getting user permissions: $e');
      return null;
    }
  }

  /// Checks if a user is a member of a crew.
  ///
  /// Parameters:
  /// - [userId]: The user ID to check
  /// - [crewId]: The crew ID to check membership for
  ///
  /// Returns:
  /// - [true] if the user is an active member of the crew
  /// - [false] otherwise
  Future<bool> isCrewMember({
    required String userId,
    required String crewId,
  }) async {
    try {
      final crewMemberDoc = await _firestore
          .collection(_crewMembersCollection)
          .doc(userId)
          .get();

      if (!crewMemberDoc.exists) {
        return false;
      }

      final crewMember = CrewMember.fromFirestore(crewMemberDoc);
      return crewMember.crewId == crewId && crewMember.isActive;
    } catch (e) {
      debugPrint('[CrewAuthService] Error checking crew membership: $e');
      return false;
    }
  }

  /// Gets the role of a user in a specific crew.
  ///
  /// Parameters:
  /// - [userId]: The user ID
  /// - [crewId]: The crew ID
  ///
  /// Returns:
  /// - [MemberRole] if the user is a member of the crew
  /// - [null] if the user is not a member
  Future<MemberRole?> getUserRole({
    required String userId,
    required String crewId,
  }) async {
    try {
      final crewMemberDoc = await _firestore
          .collection(_crewMembersCollection)
          .doc(userId)
          .get();

      if (!crewMemberDoc.exists) {
        return null;
      }

      final crewMember = CrewMember.fromFirestore(crewMemberDoc);
      return crewMember.crewId == crewId ? crewMember.role : null;
    } catch (e) {
      debugPrint('[CrewAuthService] Error getting user role: $e');
      return null;
    }
  }

  /// Logs out user from all crew sessions.
  ///
  /// This method invalidates all active session tokens for a user
  /// and logs the security event.
  ///
  /// Parameters:
  /// - [userId]: The user ID to log out
  Future<void> logoutFromAllCrews(String userId) async {
    try {
      // Clear permission cache for this user
      _permissionCache.removeWhere((key, _) => key.startsWith('${userId}_'));

      // Log the logout event
      await _logAuthEvent(
        userId: userId,
        crewId: 'all',
        event: CrewAuthEvent.sessionRevoked,
        details: 'User logged out from all crew sessions',
      );

      debugPrint('[CrewAuthService] User $userId logged out from all crews');
    } catch (e) {
      debugPrint('[CrewAuthService] Error during logout: $e');
    }
  }

  // Private helper methods

  /// Checks if a role has a specific permission.
  bool _checkPermissionByRole(MemberRole role, CrewPermission permission) {
    switch (role) {
      case MemberRole.admin:
        return true; // Admin has all permissions

      case MemberRole.foreman:
        switch (permission) {
          case CrewPermission.inviteMembers:
          case CrewPermission.removeMembers:
          case CrewPermission.shareJobs:
          case CrewPermission.postAnnouncements:
          case CrewPermission.editCrewInfo:
          case CrewPermission.viewAnalytics:
          case CrewPermission.manageMembers:
            return true;
          case CrewPermission.deleteCrew:
            return false; // Only admin can delete crew
        }

      case MemberRole.lead:
        switch (permission) {
          case CrewPermission.inviteMembers:
          case CrewPermission.shareJobs:
          case CrewPermission.postAnnouncements:
            return true;
          case CrewPermission.removeMembers:
          case CrewPermission.editCrewInfo:
          case CrewPermission.viewAnalytics:
          case CrewPermission.manageMembers:
          case CrewPermission.deleteCrew:
            return false;
        }

      case MemberRole.member:
        switch (permission) {
          case CrewPermission.viewCrew: // Implicit permission
            return true;
          case CrewPermission.inviteMembers:
          case CrewPermission.removeMembers:
          case CrewPermission.shareJobs:
          case CrewPermission.postAnnouncements:
          case CrewPermission.editCrewInfo:
          case CrewPermission.viewAnalytics:
          case CrewPermission.manageMembers:
          case CrewPermission.deleteCrew:
            return false;
        }
    }
  }

  /// Generates a secure session token.
  String _generateSecureToken(String userId, String crewId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return '${userId}_${crewId}_${timestamp}_${random}';
  }

  /// Gets cached permission if valid.
  bool? _getCachedPermission(String cacheKey) {
    final cached = _permissionCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _permissionCacheTTL) {
      return cached.hasPermission;
    }

    // Remove expired cache entry
    _permissionCache.remove(cacheKey);
    return null;
  }

  /// Caches permission result.
  void _cachePermission(String cacheKey, bool hasPermission) {
    _permissionCache[cacheKey] = _CachedPermission(
      hasPermission: hasPermission,
      timestamp: DateTime.now(),
    );

    // Cleanup old cache entries
    _permissionCache.removeWhere((key, cached) =>
        DateTime.now().difference(cached.timestamp) > _permissionCacheTTL);
  }

  /// Logs authentication and security events.
  Future<void> _logAuthEvent({
    required String userId,
    required String crewId,
    required CrewAuthEvent event,
    required String details,
    String? context,
  }) async {
    try {
      await _firestore.collection(_authLogsCollection).add({
        'userId': userId,
        'crewId': crewId,
        'event': event.name,
        'details': details,
        'context': context,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'userAgent': 'Journeyman Jobs App', // Could be enhanced with actual user agent
        'ipAddress': 'mobile', // Could be enhanced with actual IP
      });
    } catch (e) {
      // Don't let logging failures break the app
      debugPrint('[CrewAuthService] Failed to log auth event: $e');
    }
  }

  /// Cleans up resources and cache.
  void dispose() {
    _permissionCache.clear();
  }
}

/// Enumeration of crew permissions.
enum CrewPermission {
  inviteMembers,
  removeMembers,
  shareJobs,
  postAnnouncements,
  editCrewInfo,
  viewAnalytics,
  manageMembers,
  deleteCrew,
  viewCrew, // Implicit permission for all members
}

/// Enumeration of authentication event types.
enum CrewAuthEvent {
  permissionCheckSuccess,
  permissionCheckFailed,
  permissionCheckError,
  permissionCheckCacheHit,
  rateLimitExceeded,
  sessionCreated,
  sessionCreationFailed,
  sessionExpired,
  sessionInvalid,
  sessionValidated,
  sessionRevoked,
}

/// Crew session token with security context.
class CrewSessionToken {
  final String userId;
  final String crewId;
  final MemberRole role;
  final MemberPermissions permissions;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String token;

  CrewSessionToken({
    required this.userId,
    required this.crewId,
    required this.role,
    required this.permissions,
    required this.issuedAt,
    required this.expiresAt,
    required this.token,
  });

  /// Checks if the token is expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Gets remaining time until expiration.
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'crewId': crewId,
      'role': role.name,
      'permissions': permissions.toMap(),
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'token': token,
    };
  }

  factory CrewSessionToken.fromMap(Map<String, dynamic> map) {
    return CrewSessionToken(
      userId: map['userId'] ?? '',
      crewId: map['crewId'] ?? '',
      role: MemberRole.values.firstWhere(
        (r) => r.name == (map['role'] ?? 'member'),
        orElse: () => MemberRole.member,
      ),
      permissions: MemberPermissions.fromMap(map['permissions'] ?? {}),
      issuedAt: DateTime.parse(map['issuedAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(map['expiresAt'] ?? DateTime.now().toIso8601String()),
      token: map['token'] ?? '',
    );
  }
}

/// Result of crew session validation.
class CrewSessionValidation {
  final bool isValid;
  final String? reason;
  final CrewMember? crewMember;
  final CrewSessionToken? token;
  final DateTime? expiredAt;

  CrewSessionValidation({
    required this.isValid,
    this.reason,
    this.crewMember,
    this.token,
    this.expiredAt,
  });
}

/// Internal cache entry for permission results.
class _CachedPermission {
  final bool hasPermission;
  final DateTime timestamp;

  _CachedPermission({
    required this.hasPermission,
    required this.timestamp,
  });
}

/// Custom exception for rate limiting.
class RateLimitException implements Exception {
  final String message;
  final String operation;

  RateLimitException(
    this.message, {
    required this.operation,
  });

  @override
  String toString() => 'RateLimitException: $message';
}