import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/crews/models/crew.dart';
import '../features/crews/models/crew_member.dart';
import '../domain/enums/member_role.dart';
import 'crew_auth_service.dart';
import 'crew_permission_service.dart';
import 'crew_auth_monitoring_service.dart';
import 'user_discovery_service.dart';

/// Integration service that orchestrates all crew authentication and discovery services.
///
/// This service provides a unified interface for crew authentication, user discovery,
/// permission management, and security monitoring. It coordinates between the various
/// crew-related services to provide seamless functionality with proper security controls.
///
/// Features:
/// - Unified authentication and permission management
/// - Integrated user discovery with security controls
/// - Comprehensive monitoring and audit trails
/// - Performance optimization and caching
/// - Security event correlation and analysis
class CrewAuthIntegrationService {
  final CrewAuthService _authService;
  final CrewPermissionService _permissionService;
  final CrewAuthMonitoringService _monitoringService;
  final UserDiscoveryService _discoveryService;
  final FirebaseFirestore _firestore;

  CrewAuthIntegrationService({
    required CrewAuthService authService,
    required CrewPermissionService permissionService,
    required CrewAuthMonitoringService monitoringService,
    required UserDiscoveryService discoveryService,
    required FirebaseFirestore firestore,
  }) : _authService = authService,
       _permissionService = permissionService,
       _monitoringService = monitoringService,
       _discoveryService = discoveryService,
       _firestore = firestore;

  /// Performs complete user invitation flow with security validation.
  ///
  /// This method handles the entire user invitation process including:
  /// - Permission validation
  /// - User discovery and verification
  /// - Security checks and monitoring
  /// - Invitation creation and logging
  ///
  /// Parameters:
  /// - [inviterId]: ID of the user sending the invitation
  /// - [inviteeId]: ID of the user being invited
  /// - [crewId]: ID of the crew
  /// - [message]: Optional invitation message
  ///
  /// Returns:
  /// - [InvitationResult] containing the outcome and metadata
  Future<InvitationResult> inviteUserToCrew({
    required String inviterId,
    required String inviteeId,
    required String crewId,
    String? message,
  }) async {
    final operationId = _generateOperationId();
    final startTime = DateTime.now();

    try {
      // Create authentication context for monitoring
      final authContext = AuthEventContext(
        operationId: operationId,
        userAgent: 'Journeyman Jobs App',
        ipAddress: 'mobile', // Would be enhanced with actual IP
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
        additionalData: {
          'inviterId': inviterId,
          'inviteeId': inviteeId,
          'crewId': crewId,
          'hasMessage': message != null,
        },
      );

      // Step 1: Validate inviter permissions
      final hasInvitePermission = await _authService.verifyCrewPermission(
        userId: inviterId,
        crewId: crewId,
        permission: CrewPermission.inviteMembers,
        context: 'User invitation flow',
      );

      if (!hasInvitePermission) {
        await _monitoringService.logAuthEvent(
          event: CrewAuthEvent.permissionCheckFailed,
          userId: inviterId,
          crewId: crewId,
          context: authContext,
          metadata: {'action': 'invite_user', 'reason': 'no_permission'},
        );

        return InvitationResult(
          success: false,
          reason: 'You do not have permission to invite members to this crew',
          operationId: operationId,
        );
      }

      // Step 2: Validate invitee exists and is accessible
      final inviteeDoc = await _firestore.collection('users').doc(inviteeId).get();
      if (!inviteeDoc.exists) {
        return InvitationResult(
          success: false,
          reason: 'User not found',
          operationId: operationId,
        );
      }

      // Step 3: Check if user is already a crew member
      final isAlreadyMember = await _authService.isCrewMember(
        userId: inviteeId,
        crewId: crewId,
      );

      if (isAlreadyMember) {
        return InvitationResult(
          success: false,
          reason: 'User is already a member of this crew',
          operationId: operationId,
        );
      }

      // Step 4: Check for existing pending invitation
      final existingInvitation = await _firestore
          .collection('crew_invitations')
          .where('crewId', isEqualTo: crewId)
          .where('inviteeId', isEqualTo: inviteeId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingInvitation.docs.isNotEmpty) {
        return InvitationResult(
          success: false,
          reason: 'User already has a pending invitation to this crew',
          operationId: operationId,
        );
      }

      // Step 5: Create the invitation
      final invitationData = {
        'id': _generateInvitationId(),
        'crewId': crewId,
        'inviterId': inviterId,
        'inviteeId': inviteeId,
        'message': message,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'operationId': operationId,
      };

      await _firestore.collection('crew_invitations').add(invitationData);

      // Step 6: Log successful invitation
      await _monitoringService.logAuthEvent(
        event: CrewAuthEvent.permissionCheckSuccess,
        userId: inviterId,
        crewId: crewId,
        context: authContext,
        metadata: {
          'action': 'invite_user',
          'inviteeId': inviteeId,
          'invitationId': invitationData['id'],
        },
      );

      // Track performance
      _monitoringService.trackPerformance(
        operation: 'invite_user',
        operationId: operationId,
        startTime: startTime,
        endTime: DateTime.now(),
      );

      return InvitationResult(
        success: true,
        invitationId: invitationData['id'],
        operationId: operationId,
      );
    } catch (e) {
      debugPrint('[CrewAuthIntegrationService] Error inviting user: $e');

      // Log error
      await _monitoringService.logAuthEvent(
        event: CrewAuthEvent.permissionCheckError,
        userId: inviterId,
        crewId: crewId,
        context: AuthEventContext(
          operationId: operationId,
          userAgent: 'Journeyman Jobs App',
          ipAddress: 'mobile',
          sessionId: 'error_session',
        ),
        metadata: {
          'action': 'invite_user',
          'error': e.toString(),
        },
      );

      return InvitationResult(
        success: false,
        reason: 'Failed to send invitation: $e',
        operationId: operationId,
      );
    }
  }

  /// Performs secure user discovery with permission validation.
  ///
  /// This method provides user search functionality with proper security
  /// controls, rate limiting, and audit logging.
  ///
  /// Parameters:
  /// - [searcherId]: ID of the user performing the search
  /// - [crewId]: ID of the crew context
  /// - [query]: Search query
  /// - [limit]: Maximum number of results
  ///
  /// Returns:
  /// - [SecureSearchResult] containing users and security metadata
  Future<SecureSearchResult> searchUsersSecurely({
    required String searcherId,
    required String crewId,
    required String query,
    int limit = 20,
  }) async {
    final operationId = _generateOperationId();
    final startTime = DateTime.now();

    try {
      // Create authentication context
      final authContext = AuthEventContext(
        operationId: operationId,
        userAgent: 'Journeyman Jobs App',
        ipAddress: 'mobile',
        sessionId: 'search_session',
        additionalData: {
          'query': query,
          'limit': limit,
          'crewId': crewId,
        },
      );

      // Validate searcher has basic crew access
      final isMember = await _authService.isCrewMember(
        userId: searcherId,
        crewId: crewId,
      );

      if (!isMember) {
        await _monitoringService.logAuthEvent(
          event: CrewAuthEvent.permissionCheckFailed,
          userId: searcherId,
          crewId: crewId,
          context: authContext,
          metadata: {'action': 'search_users', 'reason': 'not_member'},
        );

        return SecureSearchResult(
          users: [],
          success: false,
          reason: 'You must be a crew member to search for users',
          operationId: operationId,
        );
      }

      // Perform search with current user excluded
      final searchResult = await _discoveryService.searchUsers(
        query: query,
        limit: limit,
        excludeUserId: searcherId,
      );

      // Filter results to exclude current crew members
      final crewDoc = await _firestore.collection('crews').doc(crewId).get();
      final currentMemberIds = <String>{};
      if (crewDoc.exists) {
        final crewData = crewDoc.data() as Map<String, dynamic>;
        final memberIds = List<String>.from(crewData['memberIds'] ?? []);
        currentMemberIds.addAll(memberIds);
      }

      final filteredUsers = searchResult.users
          .where((user) => !currentMemberIds.contains(user.uid))
          .toList();

      // Log successful search
      await _monitoringService.logAuthEvent(
        event: CrewAuthEvent.permissionCheckSuccess,
        userId: searcherId,
        crewId: crewId,
        context: authContext,
        metadata: {
          'action': 'search_users',
          'resultCount': filteredUsers.length,
          'query': query,
        },
      );

      // Track performance
      _monitoringService.trackPerformance(
        operation: 'search_users',
        operationId: operationId,
        startTime: startTime,
        endTime: DateTime.now(),
      );

      return SecureSearchResult(
        users: filteredUsers,
        success: true,
        operationId: operationId,
        totalResults: searchResult.users.length,
        filteredResults: filteredUsers.length,
      );
    } catch (e) {
      debugPrint('[CrewAuthIntegrationService] Error searching users: $e');

      return SecureSearchResult(
        users: [],
        success: false,
        reason: 'Search failed: $e',
        operationId: operationId,
      );
    }
  }

  /// Validates crew access and provides user permissions.
  ///
  /// This method performs comprehensive crew access validation and
  /// returns the user's permissions within the crew context.
  ///
  /// Parameters:
  /// - [userId]: ID of the user to validate
  /// - [crewId]: ID of the crew
  ///
  /// Returns:
  /// - [CrewAccessResult] containing access status and permissions
  Future<CrewAccessResult> validateCrewAccess({
    required String userId,
    required String crewId,
  }) async {
    final operationId = _generateOperationId();

    try {
      // Check if user is a crew member
      final isMember = await _authService.isCrewMember(
        userId: userId,
        crewId: crewId,
      );

      if (!isMember) {
        return CrewAccessResult(
          hasAccess: false,
          reason: 'User is not a member of this crew',
          operationId: operationId,
        );
      }

      // Get user's role and permissions
      final role = await _authService.getUserRole(userId: userId, crewId: crewId);
      final permissions = await _authService.getUserPermissions(
        userId: userId,
        crewId: crewId,
      );

      if (role == null || permissions == null) {
        return CrewAccessResult(
          hasAccess: false,
          reason: 'Unable to determine user permissions',
          operationId: operationId,
        );
      }

      // Get available operations
      final availableOperations = await _permissionService.getAvailableOperations(
        userId: userId,
        crewId: crewId,
      );

      // Get available navigation options
      final navigationOptions = await _permissionService.getAvailableNavigationOptions(
        userId: userId,
        crewId: crewId,
      );

      return CrewAccessResult(
        hasAccess: true,
        role: role,
        permissions: permissions,
        availableOperations: availableOperations,
        navigationOptions: navigationOptions,
        operationId: operationId,
      );
    } catch (e) {
      debugPrint('[CrewAuthIntegrationService] Error validating crew access: $e');

      return CrewAccessResult(
        hasAccess: false,
        reason: 'Access validation failed: $e',
        operationId: operationId,
      );
    }
  }

  /// Generates a comprehensive security report for a crew.
  ///
  /// This method creates detailed security reports for crew
  /// administrators to monitor authentication and access patterns.
  ///
  /// Parameters:
  /// - [crewId]: ID of the crew
  /// - [requesterId]: ID of the user requesting the report
  /// - [period]: Report period in days (default: 7)
  ///
  /// Returns:
  /// - [CrewSecurityReport] containing comprehensive security analytics
  Future<CrewSecurityReport> generateCrewSecurityReport({
    required String crewId,
    required String requesterId,
    int period = 7,
  }) async {
    final operationId = _generateOperationId();

    try {
      // Validate requester has permission to view analytics
      final hasPermission = await _authService.verifyCrewPermission(
        userId: requesterId,
        crewId: crewId,
        permission: CrewPermission.viewAnalytics,
        context: 'Security report generation',
      );

      if (!hasPermission) {
        return CrewSecurityReport(
          success: false,
          reason: 'You do not have permission to view security reports',
          operationId: operationId,
        );
      }

      // Generate report period
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: period));

      // Get security report from monitoring service
      final securityReport = await _monitoringService.generateSecurityReport(
        startDate: startDate,
        endDate: endDate,
        crewId: crewId,
      );

      // Get current security metrics
      final currentMetrics = await _monitoringService.getCurrentSecurityMetrics(
        crewId: crewId,
      );

      // Get crew member count
      final crewDoc = await _firestore.collection('crews').doc(crewId).get();
      final memberCount = crewDoc.exists
          ? (crewDoc.data() as Map<String, dynamic>)['memberCount'] ?? 0
          : 0;

      return CrewSecurityReport(
        success: true,
        periodStart: startDate,
        periodEnd: endDate,
        crewId: crewId,
        memberCount: memberCount,
        totalEvents: securityReport.totalEvents,
        securityEvents: securityReport.securityEvents,
        failedAuthentications: securityReport.failedAuthentications,
        successfulAuthentications: securityReport.successfulAuthentications,
        securityScore: securityReport.securityScore,
        currentActiveUsers: currentMetrics.activeUsers,
        currentSecurityAlerts: currentMetrics.securityAlerts,
        operationId: operationId,
      );
    } catch (e) {
      debugPrint('[CrewAuthIntegrationService] Error generating security report: $e');

      return CrewSecurityReport(
        success: false,
        reason: 'Failed to generate security report: $e',
        operationId: operationId,
      );
    }
  }

  /// Cleans up expired sessions and invalid tokens.
  ///
  /// This maintenance task should be run periodically to clean up
  /// expired authentication data and maintain system performance.
  Future<void> performMaintenanceCleanup() async {
    try {
      debugPrint('[CrewAuthIntegrationService] Starting maintenance cleanup...');

      // Clean up expired invitations
      final now = DateTime.now();
      final expiredInvitations = await _firestore
          .collection('crew_invitations')
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .where('status', isEqualTo: 'pending')
          .get();

      for (final invitation in expiredInvitations.docs) {
        await invitation.reference.update({'status': 'expired'});
      }

      debugPrint('[CrewAuthIntegrationService] Cleaned up ${expiredInvitations.size} expired invitations');

      // Clean up old auth logs (older than 90 days)
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));
      final oldAuthLogs = await _firestore
          .collection('crew_auth_logs')
          .where('timestamp', isLessThan: Timestamp.fromDate(ninetyDaysAgo))
          .limit(1000) // Process in batches
          .get();

      for (final log in oldAuthLogs.docs) {
        await log.reference.delete();
      }

      debugPrint('[CrewAuthIntegrationService] Cleaned up ${oldAuthLogs.size} old auth logs');

      debugPrint('[CrewAuthIntegrationService] Maintenance cleanup completed');
    } catch (e) {
      debugPrint('[CrewAuthIntegrationService] Error during maintenance cleanup: $e');
    }
  }

  // Private helper methods

  /// Generates a unique operation ID for tracking.
  String _generateOperationId() {
    return 'op_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  /// Generates a unique invitation ID.
  String _generateInvitationId() {
    return 'inv_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  /// Generates a random string for IDs.
  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }
    return result;
  }
}

/// Result of user invitation operation.
class InvitationResult {
  final bool success;
  final String? invitationId;
  final String? reason;
  final String operationId;

  InvitationResult({
    required this.success,
    this.invitationId,
    this.reason,
    required this.operationId,
  });
}

/// Result of secure user search operation.
class SecureSearchResult {
  final List<UsersRecord> users;
  final bool success;
  final String? reason;
  final String operationId;
  final int? totalResults;
  final int? filteredResults;

  SecureSearchResult({
    required this.users,
    required this.success,
    this.reason,
    required this.operationId,
    this.totalResults,
    this.filteredResults,
  });
}

/// Result of crew access validation.
class CrewAccessResult {
  final bool hasAccess;
  final MemberRole? role;
  final MemberPermissions? permissions;
  final List<CrewOperation>? availableOperations;
  final List<NavigationOption>? navigationOptions;
  final String? reason;
  final String operationId;

  CrewAccessResult({
    required this.hasAccess,
    this.role,
    this.permissions,
    this.availableOperations,
    this.navigationOptions,
    this.reason,
    required this.operationId,
  });
}

/// Comprehensive crew security report.
class CrewSecurityReport {
  final bool success;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String crewId;
  final int memberCount;
  final int totalEvents;
  final int securityEvents;
  final int failedAuthentications;
  final int successfulAuthentications;
  final double securityScore;
  final int currentActiveUsers;
  final int currentSecurityAlerts;
  final String? reason;
  final String operationId;

  CrewSecurityReport({
    required this.success,
    required this.periodStart,
    required this.periodEnd,
    required this.crewId,
    required this.memberCount,
    required this.totalEvents,
    required this.securityEvents,
    required this.failedAuthentications,
    required this.successfulAuthentications,
    required this.securityScore,
    required this.currentActiveUsers,
    required this.currentSecurityAlerts,
    this.reason,
    required this.operationId,
  });
}