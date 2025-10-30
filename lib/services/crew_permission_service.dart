import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/crews/models/crew.dart';
import '../features/crews/models/crew_member.dart';
import '../domain/enums/member_role.dart';
import 'crew_auth_service.dart';

/// Service for implementing permission-based access control throughout the application.
///
/// This service provides centralized permission checking and UI visibility controls
/// based on crew member roles and permissions. It integrates with the CrewAuthService
/// to provide consistent security enforcement across all crew operations.
///
/// Features:
/// - Centralized permission checking
/// - Role-based UI visibility controls
/// - Permission validation for crew operations
/// - Real-time permission updates
/// - Integration with authentication service
class CrewPermissionService {
  final CrewAuthService _authService;
  final FirebaseFirestore _firestore;

  // Performance: Permission cache with TTL
  final Map<String, _CachedUIPermission> _uiPermissionCache = {};
  static const Duration _uiPermissionCacheTTL = Duration(minutes: 5);

  CrewPermissionService({
    required CrewAuthService authService,
    required FirebaseFirestore firestore,
  }) : _authService = authService,
       _firestore = firestore;

  /// Checks if a user has permission to perform a specific crew operation.
  ///
  /// This method provides a centralized way to check permissions for all
  /// crew operations throughout the application.
  ///
  /// Parameters:
  /// - [userId]: The user ID to check permissions for
  /// - [crewId]: The crew ID where the operation will be performed
  /// - [operation]: The specific operation to check permission for
  ///
  /// Returns:
  /// - [true] if the user has permission for the operation
  /// - [false] if the user lacks permission
  Future<bool> hasPermission({
    required String userId,
    required String crewId,
    required CrewOperation operation,
  }) async {
    final permission = _operationToPermission(operation);
    return await _authService.verifyCrewPermission(
      userId: userId,
      crewId: crewId,
      permission: permission,
      context: 'Operation: ${operation.name}',
    );
  }

  /// Determines if a UI element should be visible based on user permissions.
  ///
  /// This method provides role-based UI visibility controls to ensure
  /// users only see interface elements they have permission to use.
  ///
  /// Parameters:
  /// - [userId]: The user ID
  /// - [crewId]: The crew ID
  /// - [uiElement]: The UI element to check visibility for
  ///
  /// Returns:
  /// - [true] if the UI element should be visible to the user
  /// - [false] if the UI element should be hidden
  Future<bool> shouldShowUIElement({
    required String userId,
    required String crewId,
    required UIElement uiElement,
  }) async {
    // Performance: Check cache first
    final cacheKey = '${userId}_${crewId}_${uiElement.name}';
    final cachedPermission = _getCachedUIPermission(cacheKey);
    if (cachedPermission != null) {
      return cachedPermission.isVisible;
    }

    final permission = _uiElementToPermission(uiElement);
    final isVisible = await _authService.verifyCrewPermission(
      userId: userId,
      crewId: crewId,
      permission: permission,
      context: 'UI Element: ${uiElement.name}',
    );

    // Cache the result
    _cacheUIPermission(cacheKey, isVisible);

    return isVisible;
  }

  /// Gets all available operations for a user's role in a crew.
  ///
  /// This method returns a list of operations that a user can perform
  /// based on their role in the crew hierarchy.
  ///
  /// Parameters:
  /// - [userId]: The user ID
  /// - [crewId]: The crew ID
  ///
  /// Returns:
  /// - List of [CrewOperation] that the user can perform
  Future<List<CrewOperation>> getAvailableOperations({
    required String userId,
    required String crewId,
  }) async {
    try {
      final userRole = await _authService.getUserRole(userId: userId, crewId: crewId);
      if (userRole == null) return [];

      return _getOperationsForRole(userRole);
    } catch (e) {
      debugPrint('[CrewPermissionService] Error getting available operations: $e');
      return [];
    }
  }

  /// Validates if a user can access a specific crew feature.
  ///
  /// This method provides feature-level access control for crew features
  /// like analytics, member management, etc.
  ///
  /// Parameters:
  /// - [userId]: The user ID
  /// - [crewId]: The crew ID
  /// - [feature]: The crew feature to access
  ///
  /// Returns:
  /// - [CrewFeatureAccess] containing access status and metadata
  Future<CrewFeatureAccess> canAccessFeature({
    required String userId,
    required String crewId,
    required CrewFeature feature,
  }) async {
    try {
      final requiredPermissions = _getRequiredPermissionsForFeature(feature);

      for (final permission in requiredPermissions) {
        final hasPermission = await _authService.verifyCrewPermission(
          userId: userId,
          crewId: crewId,
          permission: permission,
          context: 'Feature Access: ${feature.name}',
        );

        if (!hasPermission) {
          return CrewFeatureAccess(
            canAccess: false,
            reason: 'Missing required permission: ${permission.name}',
            feature: feature,
          );
        }
      }

      return CrewFeatureAccess(
        canAccess: true,
        feature: feature,
      );
    } catch (e) {
      debugPrint('[CrewPermissionService] Error checking feature access: $e');
      return CrewFeatureAccess(
        canAccess: false,
        reason: 'Error checking access: $e',
        feature: feature,
      );
    }
  }

  /// Checks if a user can modify another user's data in the crew.
  ///
  /// This method provides user-to-user permission checking for operations
  /// like role changes, removal, etc.
  ///
  /// Parameters:
  /// - [actorUserId]: The user performing the action
  /// - [targetUserId]: The user being targeted
  /// - [crewId]: The crew ID
  /// - [action]: The action being performed
  ///
  /// Returns:
  /// - [true] if the actor has permission to perform the action on the target
  Future<bool> canModifyUser({
    required String actorUserId,
    required String targetUserId,
    required String crewId,
    required UserModificationAction action,
  }) async {
    try {
      // Get both users' roles
      final actorRole = await _authService.getUserRole(userId: actorUserId, crewId: crewId);
      final targetRole = await _authService.getUserRole(userId: targetUserId, crewId: crewId);

      if (actorRole == null || targetRole == null) {
        return false;
      }

      // Check hierarchy rules
      return _canUserModifyTarget(actorRole, targetRole, action);
    } catch (e) {
      debugPrint('[CrewPermissionService] Error checking user modification: $e');
      return false;
    }
  }

  /// Gets permission-based navigation options for a user.
  ///
  /// This method returns navigation options that should be available
  /// to a user based on their crew permissions.
  ///
  /// Parameters:
  /// - [userId]: The user ID
  /// - [crewId]: The crew ID
  ///
  /// Returns:
  /// - List of navigation options available to the user
  Future<List<NavigationOption>> getAvailableNavigationOptions({
    required String userId,
    required String crewId,
  }) async {
    try {
      final availableOperations = await getAvailableOperations(
        userId: userId,
        crewId: crewId,
      );

      List<NavigationOption> options = [
        // Basic navigation available to all members
        NavigationOption(
          title: 'Crew Feed',
          icon: Icons.feed,
          route: '/crew/feed',
          requiresPermission: false,
        ),
        NavigationOption(
          title: 'Messages',
          icon: Icons.message,
          route: '/crew/messages',
          requiresPermission: false,
        ),
      ];

      // Add permission-based options
      if (availableOperations.contains(CrewOperation.viewAnalytics)) {
        options.add(NavigationOption(
          title: 'Analytics',
          icon: Icons.analytics,
          route: '/crew/analytics',
          requiresPermission: true,
        ));
      }

      if (availableOperations.contains(CrewOperation.manageMembers)) {
        options.add(NavigationOption(
          title: 'Members',
          icon: Icons.people,
          route: '/crew/members',
          requiresPermission: true,
        ));
      }

      if (availableOperations.contains(CrewOperation.editCrewInfo)) {
        options.add(NavigationOption(
          title: 'Settings',
          icon: Icons.settings,
          route: '/crew/settings',
          requiresPermission: true,
        ));
      }

      return options;
    } catch (e) {
      debugPrint('[CrewPermissionService] Error getting navigation options: $e');
      return [];
    }
  }

  /// Clears permission cache for a specific user.
  void clearUserPermissionCache(String userId) {
    _uiPermissionCache.removeWhere((key, _) => key.startsWith('${userId}_'));
  }

  /// Clears all permission caches.
  void clearAllPermissionCaches() {
    _uiPermissionCache.clear();
  }

  // Private helper methods

  /// Converts crew operation to permission.
  CrewPermission _operationToPermission(CrewOperation operation) {
    switch (operation) {
      case CrewOperation.inviteMembers:
        return CrewPermission.inviteMembers;
      case CrewOperation.removeMembers:
        return CrewPermission.removeMembers;
      case CrewOperation.shareJobs:
        return CrewPermission.shareJobs;
      case CrewOperation.postAnnouncements:
        return CrewPermission.postAnnouncements;
      case CrewOperation.editCrewInfo:
        return CrewPermission.editCrewInfo;
      case CrewOperation.viewAnalytics:
        return CrewPermission.viewAnalytics;
      case CrewOperation.manageMembers:
        return CrewPermission.manageMembers;
      case CrewOperation.deleteCrew:
        return CrewPermission.deleteCrew;
    }
  }

  /// Converts UI element to permission.
  CrewPermission _uiElementToPermission(UIElement element) {
    switch (element) {
      case UIElement.inviteButton:
        return CrewPermission.inviteMembers;
      case UIElement.removeMemberButton:
        return CrewPermission.removeMembers;
      case UIElement.shareJobButton:
        return CrewPermission.shareJobs;
      case UIElement.announcementInput:
        return CrewPermission.postAnnouncements;
      case UIElement.editCrewButton:
        return CrewPermission.editCrewInfo;
      case UIElement.analyticsTab:
        return CrewPermission.viewAnalytics;
      case UIElement.manageMembersTab:
        return CrewPermission.manageMembers;
      case UIElement.deleteCrewButton:
        return CrewPermission.deleteCrew;
    }
  }

  /// Gets operations available for a specific role.
  List<CrewOperation> _getOperationsForRole(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return CrewOperation.values;
      case MemberRole.foreman:
        return [
          CrewOperation.inviteMembers,
          CrewOperation.removeMembers,
          CrewOperation.shareJobs,
          CrewOperation.postAnnouncements,
          CrewOperation.editCrewInfo,
          CrewOperation.viewAnalytics,
          CrewOperation.manageMembers,
        ];
      case MemberRole.lead:
        return [
          CrewOperation.inviteMembers,
          CrewOperation.shareJobs,
          CrewOperation.postAnnouncements,
        ];
      case MemberRole.member:
        return []; // Basic members have no special operations
    }
  }

  /// Gets required permissions for a feature.
  List<CrewPermission> _getRequiredPermissionsForFeature(CrewFeature feature) {
    switch (feature) {
      case CrewFeature.analytics:
        return [CrewPermission.viewAnalytics];
      case CrewFeature.memberManagement:
        return [CrewPermission.manageMembers];
      case CrewFeature.crewSettings:
        return [CrewPermission.editCrewInfo];
      case CrewFeature.jobSharing:
        return [CrewPermission.shareJobs];
      case CrewFeature.announcements:
        return [CrewPermission.postAnnouncements];
    }
  }

  /// Checks if a user can modify another user based on hierarchy.
  bool _canUserModifyTarget(
    MemberRole actorRole,
    MemberRole targetRole,
    UserModificationAction action,
  ) {
    // Admin can modify anyone
    if (actorRole == MemberRole.admin) {
      return true;
    }

    // Foreman can modify leads and members
    if (actorRole == MemberRole.foreman) {
      return targetRole == MemberRole.lead || targetRole == MemberRole.member;
    }

    // Lead can only modify members (for limited actions)
    if (actorRole == MemberRole.lead) {
      return targetRole == MemberRole.member &&
             (action == UserModificationAction.invite ||
              action == UserModificationAction.shareJob);
    }

    // Members cannot modify others
    return false;
  }

  /// Gets cached UI permission if valid.
  bool? _getCachedUIPermission(String cacheKey) {
    final cached = _uiPermissionCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _uiPermissionCacheTTL) {
      return cached.isVisible;
    }

    // Remove expired cache entry
    _uiPermissionCache.remove(cacheKey);
    return null;
  }

  /// Caches UI permission result.
  void _cacheUIPermission(String cacheKey, bool isVisible) {
    _uiPermissionCache[cacheKey] = _CachedUIPermission(
      isVisible: isVisible,
      timestamp: DateTime.now(),
    );

    // Cleanup old cache entries
    _uiPermissionCache.removeWhere((key, cached) =>
        DateTime.now().difference(cached.timestamp) > _uiPermissionCacheTTL);
  }
}

/// Enumeration of crew operations that require permissions.
enum CrewOperation {
  inviteMembers,
  removeMembers,
  shareJobs,
  postAnnouncements,
  editCrewInfo,
  viewAnalytics,
  manageMembers,
  deleteCrew,
}

/// Enumeration of UI elements that should be controlled by permissions.
enum UIElement {
  inviteButton,
  removeMemberButton,
  shareJobButton,
  announcementInput,
  editCrewButton,
  analyticsTab,
  manageMembersTab,
  deleteCrewButton,
}

/// Enumeration of crew features that require permissions.
enum CrewFeature {
  analytics,
  memberManagement,
  crewSettings,
  jobSharing,
  announcements,
}

/// Enumeration of user modification actions.
enum UserModificationAction {
  invite,
  remove,
  changeRole,
  shareJob,
  viewProfile,
}

/// Result of crew feature access check.
class CrewFeatureAccess {
  final bool canAccess;
  final String? reason;
  final CrewFeature feature;

  CrewFeatureAccess({
    required this.canAccess,
    this.reason,
    required this.feature,
  });
}

/// Navigation option with permission requirements.
class NavigationOption {
  final String title;
  final IconData icon;
  final String route;
  final bool requiresPermission;

  NavigationOption({
    required this.title,
    required this.icon,
    required this.route,
    required this.requiresPermission,
  });
}

/// Internal cache entry for UI permissions.
class _CachedUIPermission {
  final bool isVisible;
  final DateTime timestamp;

  _CachedUIPermission({
    required this.isVisible,
    required this.timestamp,
  });
}