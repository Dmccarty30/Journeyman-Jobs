// lib/features/crews/providers/crew_mfa_riverpod_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../../../services/crew_mfa_service.dart';
import '../models/crew.dart';
import '../models/crew_member.dart';
import '../../domain/enums/member_role.dart';

part 'crew_mfa_riverpod_provider.g.dart';

/// CrewMFAService provider
@riverpod
CrewMFAService crewMFAService(Ref ref) {
  return CrewMFAService(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
}

/// Provider for checking if user can enable MFA
@riverpod
bool canEnableMFA(Ref ref) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  if (currentUser == null) return false;

  // In a real implementation, you would check if the user has admin or foreman role
  // For now, we'll assume authenticated users can enable MFA
  return true;
}

/// Provider for getting MFA status for current user
@riverpod
AsyncValue<MFAStatus?> userMFAStatus(Ref ref) {
  final crewMFAService = ref.watch(crewMFAServiceProvider);
  final currentUser = ref.watch(auth_providers.currentUserProvider);

  if (currentUser == null) {
    return const AsyncValue.data(null);
  }

  return AsyncValue.guard(() async {
    return await crewMFAService.getMFAStatus(currentUser.uid);
  });
}

/// Provider for checking if MFA is enabled for current user
@riverpod
bool isMFAEnabled(Ref ref) {
  final mfaStatusAsync = ref.watch(userMFAStatusProvider);
  return mfaStatusAsync.when(
    data: (status) => status?.isEnabled ?? false,
    loading: () => false,
    error: (_, _) => false,
  );
}

/// Provider for checking if MFA is required for operations
@riverpod
bool isMFARequired(Ref ref) {
  // In a real implementation, you might make MFA required for high-risk operations
  // For now, we'll return false
  return false;
}

/// Notifier for managing MFA setup
class MFASetupNotifier extends StateNotifier<AsyncValue<MFASetupResult?>> {
  MFASetupNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Sets up MFA for the current user
  ///
  /// This method enables multi-factor authentication for the current user
  /// in the context of their crew role. It generates TOTP secrets and backup codes.
  ///
  /// Parameters:
  /// - [crewId]: The crew ID where MFA is being enabled
  /// - [role]: The user's role in the crew
  Future<void> setupMFA({
    required String crewId,
    required MemberRole role,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        Exception('User must be authenticated to enable MFA'),
        StackTrace.current,
      );
      return;
    }

    // Check if user has required role
    if (!_isRoleEligibleForMFA(role)) {
      state = AsyncValue.error(
        Exception('MFA is only available for crew administrators and foremen'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final crewMFAService = _ref.read(crewMFAServiceProvider);
      final result = await crewMFAService.enableMFA(
        userId: currentUser.uid,
        crewId: crewId,
        role: role,
      );

      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      debugPrint('[MFASetupNotifier] Error setting up MFA: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Disables MFA for the current user
  ///
  /// This method removes MFA protection for the current user.
  /// All TOTP secrets and backup codes will be permanently deleted.
  ///
  /// Parameters:
  /// - [reason]: The reason for disabling MFA
  Future<void> disableMFA({
    required String reason,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        Exception('User must be authenticated to disable MFA'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final crewMFAService = _ref.read(crewMFAServiceProvider);
      await crewMFAService.disableMFA(
        userId: currentUser.uid,
        reason: reason,
      );

      // Clear the setup result
      state = const AsyncValue.data(null);

      // Update MFA status
      _ref.invalidate(userMFAStatusProvider);
    } catch (e, stackTrace) {
      debugPrint('[MFASetupNotifier] Error disabling MFA: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Resets the notifier state
  void reset() {
    state = const AsyncValue.data(null);
  }

  /// Checks if a role is eligible for MFA
  bool _isRoleEligibleForMFA(MemberRole role) {
    return role == MemberRole.admin || role == MemberRole.foreman;
  }
}

/// Provider for MFA setup notifier
@riverpod
MFASetupNotifier mfaSetupNotifier(Ref ref) {
  return MFASetupNotifier(ref);
}

/// Stream of MFA setup state
@riverpod
AsyncValue<MFASetupResult?> mfaSetupState(Ref ref) {
  return ref.watch(mfaSetupNotifierProvider);
}

/// Notifier for MFA verification
class MFAVerificationNotifier extends StateNotifier<AsyncValue<MFASession?>> {
  MFAVerificationNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Verifies a TOTP code for MFA authentication
  ///
  /// This method validates a time-based one-time password against the
  /// stored secret and creates an MFA session upon successful verification.
  ///
  /// Parameters:
  /// - [totpCode]: The 6-digit TOTP code to verify
  /// - [context]: Optional context for the verification
  Future<void> verifyTOTPCode({
    required String totpCode,
    String? context,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        Exception('User must be authenticated to verify MFA'),
        StackTrace.current,
      );
      return;
    }

    // Validate TOTP code format
    if (totpCode.length != 6 || !RegExp(r'^\d+$').hasMatch(totpCode)) {
      state = const AsyncValue.error(
        Exception('Invalid TOTP code format. Please enter a 6-digit code.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final crewMFAService = _ref.read(crewMFAServiceProvider);
      final session = await crewMFAService.verifyTOTPCode(
        userId: currentUser.uid,
        totpCode: totpCode,
        context: context,
      );

      state = AsyncValue.data(session);
    } catch (e, stackTrace) {
      debugPrint('[MFAVerificationNotifier] Error verifying TOTP: $e');

      // Map common errors to user-friendly messages
      String errorMessage = 'Failed to verify TOTP code';
      if (e.toString().contains('Invalid TOTP code')) {
        errorMessage = 'Invalid TOTP code. Please try again.';
      } else if (e.toString().contains('locked')) {
        errorMessage = 'Too many failed attempts. Please try again later.';
      } else if (e.toString().contains('enabled')) {
        errorMessage = 'MFA is not enabled for your account.';
      }

      state = AsyncValue.error(
        Exception(errorMessage),
        StackTrace.current,
      );
    }
  }

  /// Verifies a backup code for MFA authentication
  ///
  /// This method validates a backup code as an alternative to TOTP,
  /// typically used when the user doesn't have access to their authenticator app.
  ///
  /// Parameters:
  /// - [backupCode]: The backup code to verify
  /// - [context]: Optional context for the verification
  Future<void> verifyBackupCode({
    required String backupCode,
    String? context,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        Exception('User must be authenticated to verify MFA'),
        StackTrace.current,
      );
      return;
    }

    // Validate backup code format
    if (backupCode.length != 6 || !RegExp(r'^\d+$').hasMatch(backupCode)) {
      state = const AsyncValue.error(
        Exception('Invalid backup code format. Please enter a 6-digit code.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final crewMFAService = _ref.read(crewMFAServiceProvider);
      final session = await crewMFAService.verifyBackupCode(
        userId: currentUser.uid,
        backupCode: backupCode,
        context: context,
      );

      state = AsyncValue.data(session);
    } catch (e, stackTrace) {
      debugPrint('[MFAVerificationNotifier] Error verifying backup code: $e');

      // Map common errors to user-friendly messages
      String errorMessage = 'Failed to verify backup code';
      if (e.toString().contains('Invalid backup code')) {
        errorMessage = 'Invalid backup code. Please try again.';
      } else if (e.toString().contains('enabled')) {
        errorMessage = 'MFA is not enabled for your account.';
      }

      state = AsyncValue.error(
        Exception(errorMessage),
        StackTrace.current,
      );
    }
  }

  /// Verifies an existing MFA session token
  ///
  /// This method validates an existing MFA session token and checks
  /// for expiration and validity.
  ///
  /// Parameters:
  /// - [sessionToken]: The MFA session token to verify
  Future<void> verifyMFASession(String sessionToken) async {
    state = const AsyncValue.loading();
    try {
      final crewMFAService = _ref.read(crewMFAServiceProvider);
      final validation = await crewMFAService.verifyMFASession(sessionToken);

      if (validation.isValid) {
        state = AsyncValue.data(MFASession(
          sessionToken: sessionToken,
          userId: validation.userId!,
          crewId: validation.crewId!,
          role: validation.role!,
          expiresAt: validation.expiresAt!,
        ));
      } else {
        state = AsyncValue.error(
          Exception('MFA session is invalid or has expired'),
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[MFAVerificationNotifier] Error verifying MFA session: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Revokes an MFA session immediately
  ///
  /// This method invalidates an active MFA session token.
  ///
  /// Parameters:
  /// - [sessionToken]: The MFA session token to revoke
  Future<void> revokeMFASession(String sessionToken) async {
    try {
      final crewMFAService = _ref.read(crewMFAServiceProvider);
      await crewMFAService.revokeMFASession(sessionToken);

      // Clear current session
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      debugPrint('[MFAVerificationNotifier] Error revoking MFA session: $e');
      // Don't update state on revocation error
    }
  }

  /// Resets the notifier state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for MFA verification notifier
@riverpod
MFAVerificationNotifier mfaVerificationNotifier(Ref ref) {
  return MFAVerificationNotifier(ref);
}

/// Stream of MFA verification state
@riverpod
AsyncValue<MFASession?> mfaVerificationState(Ref ref) {
  return ref.watch(mfaVerificationNotifierProvider);
}

/// Notifier for managing MFA session timeout
class MFASessionNotifier extends StateNotifier<AsyncValue<void>> {
  MFASessionNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;
  Timer? _sessionTimer;

  /// Starts monitoring an MFA session for timeout
  ///
  /// This method automatically revokes the session when it expires.
  ///
  /// Parameters:
  /// - [session]: The MFA session to monitor
  void startSessionMonitoring(MFASession session) {
    // Cancel existing timer
    _sessionTimer?.cancel();

    // Calculate time until expiration
    final timeUntilExpiry = session.expiresAt.difference(DateTime.now());

    if (timeUntilExpiry.isPositive) {
      _sessionTimer = Timer(timeUntilExpiry, () {
        debugPrint('[MFASessionNotifier] MFA session expired');
        _ref.read(mfaVerificationNotifierProvider).revokeMFASession(session.sessionToken);
        state = const AsyncValue.error(
          Exception('MFA session has expired'),
          StackTrace.current,
        );
      });

      state = const AsyncValue.data(null);
    } else {
      // Session already expired
      state = const AsyncValue.error(
        Exception('MFA session has already expired'),
        StackTrace.current,
      );
    }
  }

  /// Stops monitoring the current session
  void stopSessionMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    state = const AsyncValue.data(null);
  }

  /// Extends the current session timeout
  ///
  /// Parameters:
  /// - [extensionDuration]: Duration to extend the session by
  void extendSession(Duration extensionDuration) {
    // Implementation would depend on the MFA service supporting session extension
    debugPrint('[MFASessionNotifier] Session extension not implemented');
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}

/// Provider for MFA session notifier
@riverpod
MFASessionNotifier mfaSessionNotifier(Ref ref) {
  return MFASessionNotifier(ref);
}

/// Stream of MFA session state
@riverpod
AsyncValue<void> mfaSessionState(Ref ref) {
  return ref.watch(mfaSessionNotifierProvider);
}