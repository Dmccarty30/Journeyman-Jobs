// lib/features/crews/providers/crew_message_encryption_riverpod_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../../../services/crew_message_encryption_service.dart';
import '../models/crew.dart';
import '../models/crew_member.dart';
import '../../domain/enums/member_role.dart';

part 'crew_message_encryption_riverpod_provider.g.dart';

/// CrewMessageEncryptionService provider
@riverpod
CrewMessageEncryptionService crewMessageEncryptionService(Ref ref) {
  return CrewMessageEncryptionService(
    firestore: FirebaseFirestore.instance,
  );
}

/// Provider for checking if user can use encryption
@riverpod
bool canUseEncryption(Ref ref) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  if (currentUser == null) return false;

  // In a real implementation, you would check if the user has encryption keys
  // For now, we'll assume authenticated users can use encryption
  return true;
}

/// Provider for getting encryption status for current user
@riverpod
AsyncValue<EncryptionStatus?> userEncryptionStatus(Ref ref) {
  final crewMessageEncryptionService = ref.watch(crewMessageEncryptionServiceProvider);
  final currentUser = ref.watch(auth_providers.currentUserProvider);

  if (currentUser == null) {
    return const AsyncValue.data(null);
  }

  return AsyncValue.guard(() async {
    return await crewMessageEncryptionService.getEncryptionStatus(currentUser.uid);
  });
}

/// Provider for checking if encryption is enabled for current user
@riverpod
bool isEncryptionEnabled(Ref ref) {
  final encryptionStatusAsync = ref.watch(userEncryptionStatusProvider);
  return encryptionStatusAsync.when(
    data: (status) => status?.isActive ?? false,
    loading: () => false,
    error: (_, _) => false,
  );
}

/// Provider for checking if encryption key rotation is required
@riverpod
bool isKeyRotationRequired(Ref ref) {
  final encryptionStatusAsync = ref.watch(userEncryptionStatusProvider);
  return encryptionStatusAsync.when(
    data: (status) => status?.rotationRequired ?? false,
    loading: () => false,
    error: (_, _) => false,
  );
}

/// Notifier for managing encryption setup
class EncryptionSetupNotifier extends StateNotifier<AsyncValue<EncryptionKeyPair?>> {
  EncryptionSetupNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Initializes encryption for the current user
  ///
  /// This method generates public/private key pairs for secure communication
  /// within the crew. The public key is stored in Firestore for other members
  /// to use when encrypting messages.
  ///
  /// Parameters:
  /// - [crewId]: The crew ID where encryption is being initialized
  /// - [role]: The user's role in the crew
  Future<void> initializeEncryption({
    required String crewId,
    required MemberRole role,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        Exception('User must be authenticated to initialize encryption'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final crewMessageEncryptionService = _ref.read(crewMessageEncryptionServiceProvider);
      final keyPair = await crewMessageEncryptionService.initializeEncryption(
        userId: currentUser.uid,
        crewId: crewId,
        role: role,
      );

      state = AsyncValue.data(keyPair);

      // Update encryption status
      _ref.invalidate(userEncryptionStatusProvider);
    } catch (e, stackTrace) {
      debugPrint('[EncryptionSetupNotifier] Error initializing encryption: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Rotates encryption keys for enhanced security
  ///
  /// This method generates new encryption keys and marks old keys
  /// for rotation, ensuring backward compatibility during the transition.
  ///
  /// Parameters:
  /// - [crewId]: The crew ID
  /// - [role]: The user's role in the crew
  Future<void> rotateEncryptionKeys({
    required String crewId,
    required MemberRole role,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        Exception('User must be authenticated to rotate encryption keys'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final crewMessageEncryptionService = _ref.read(crewMessageEncryptionServiceProvider);
      final newKeyPair = await crewMessageEncryptionService.rotateKeys(
        userId: currentUser.uid,
        crewId: crewId,
        role: role,
      );

      state = AsyncValue.data(newKeyPair);

      // Update encryption status
      _ref.invalidate(userEncryptionStatusProvider);
      _ref.invalidate(isKeyRotationRequiredProvider);
    } catch (e, stackTrace) {
      debugPrint('[EncryptionSetupNotifier] Error rotating encryption keys: $e');

      // Map common errors to user-friendly messages
      String errorMessage = 'Failed to rotate encryption keys';
      if (e.toString().contains('No existing keys found')) {
        errorMessage = 'Encryption is not enabled for your account. Please initialize encryption first.';
      }

      state = AsyncValue.error(
        Exception(errorMessage),
        StackTrace.current,
      );
    }
  }

  /// Disables encryption for the current user
  ///
  /// This method removes all encryption keys and disables
  /// encryption for the specified user.
  ///
  /// Parameters:
  /// - [reason]: The reason for disabling encryption
  Future<void> disableEncryption({
    required String reason,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        Exception('User must be authenticated to disable encryption'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final crewMessageEncryptionService = _ref.read(crewMessageEncryptionServiceProvider);
      await crewMessageEncryptionService.disableEncryption(
        userId: currentUser.uid,
        reason: reason,
      );

      // Clear the key pair
      state = const AsyncValue.data(null);

      // Update encryption status
      _ref.invalidate(userEncryptionStatusProvider);
      _ref.invalidate(isEncryptionEnabledProvider);
      _ref.invalidate(isKeyRotationRequiredProvider);
    } catch (e, stackTrace) {
      debugPrint('[EncryptionSetupNotifier] Error disabling encryption: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Resets the notifier state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for encryption setup notifier
@riverpod
EncryptionSetupNotifier encryptionSetupNotifier(Ref ref) {
  return EncryptionSetupNotifier(ref);
}

/// Stream of encryption setup state
@riverpod
AsyncValue<EncryptionKeyPair?> encryptionSetupState(Ref ref) {
  return ref.watch(encryptionSetupNotifierProvider);
}

/// Notifier for managing message encryption and decryption
class MessageEncryptionNotifier extends StateNotifier<AsyncValue<EncryptedMessage?>> {
  MessageEncryptionNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Encrypts a message for crew communication
  ///
  /// This method encrypts message content using AES-256-GCM and
  /// encrypts the AES key with RSA for each recipient.
  ///
  /// Parameters:
  /// - [content]: The message content to encrypt
  /// - [crewId]: The crew ID
  /// - [recipientIds]: List of recipient user IDs (optional)
  /// - [messageType]: Type of message for additional context
  Future<void> encryptMessage({
    required String content,
    required String crewId,
    List<String>? recipientIds,
    String messageType = 'text',
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        Exception('User must be authenticated to encrypt messages'),
        StackTrace.current,
      );
      return;
    }

    // Validate message content
    if (content.trim().isEmpty) {
      state = const AsyncValue.error(
        Exception('Message content cannot be empty'),
        StackTrace.current,
      );
      return;
    }

    // Check message length limits
    if (content.length > 10000) {
      state = const AsyncValue.error(
        Exception('Message content is too long (max 10,000 characters)'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final crewMessageEncryptionService = _ref.read(crewMessageEncryptionServiceProvider);
      final encryptedMessage = await crewMessageEncryptionService.encryptMessage(
        senderId: currentUser.uid,
        crewId: crewId,
        content: content,
        recipientIds: recipientIds,
        messageType: messageType,
      );

      state = AsyncValue.data(encryptedMessage);
    } catch (e, stackTrace) {
      debugPrint('[MessageEncryptionNotifier] Error encrypting message: $e');

      // Map common errors to user-friendly messages
      String errorMessage = 'Failed to encrypt message';
      if (e.toString().contains('No recipients found')) {
        errorMessage = 'No valid recipients found for encryption.';
      } else if (e.toString().contains('No valid recipient keys')) {
        errorMessage = 'Some recipients do not have encryption enabled.';
      } else if (e.toString().contains('Too many encryption requests')) {
        errorMessage = 'Too many encryption requests. Please try again later.';
      }

      state = AsyncValue.error(
        Exception(errorMessage),
        StackTrace.current,
      );
    }
  }

  /// Decrypts a message received by a crew member
  ///
  /// This method decrypts the AES key using the recipient's private key
  /// and then decrypts the message content using AES-256-GCM.
  ///
  /// Parameters:
  /// - [encryptedMessage]: The encrypted message to decrypt
  /// - [privateKey]: The user's private RSA key
  Future<void> decryptMessage({
    required EncryptedMessage encryptedMessage,
    required String privateKey,
  }) async {
    // Validate encrypted message
    if (encryptedMessage.encryptedContent.isEmpty) {
      state = const AsyncValue.error(
        Exception('Invalid encrypted message'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final crewMessageEncryptionService = _ref.read(crewMessageEncryptionServiceProvider);
      final decryptedMessage = await crewMessageEncryptionService.decryptMessage(
        userId: encryptedMessage.recipientIds.keys.first, // Simplified - in real implementation, get current user ID
        encryptedMessage: encryptedMessage,
        privateKey: privateKey,
      );

      // Convert decrypted message back to encrypted format for state consistency
      final resultMessage = EncryptedMessage(
        messageId: decryptedMessage.messageId,
        senderId: decryptedMessage.senderId,
        crewId: decryptedMessage.crewId,
        encryptedContent: '', // We don't store decrypted content in state
        iv: encryptedMessage.iv,
        encryptedKeys: encryptedMessage.encryptedKeys,
        messageType: decryptedMessage.messageType,
        createdAt: decryptedMessage.createdAt,
        algorithm: encryptedMessage.algorithm,
        keyAlgorithm: encryptedMessage.keyAlgorithm,
      );

      state = AsyncValue.data(resultMessage);

      // Store the decrypted content separately (in real implementation)
      debugPrint('[MessageEncryptionNotifier] Message decrypted successfully: ${decryptedMessage.content}');
    } catch (e, stackTrace) {
      debugPrint('[MessageEncryptionNotifier] Error decrypting message: $e');

      // Map common errors to user-friendly messages
      String errorMessage = 'Failed to decrypt message';
      if (e.toString().contains('User is not a recipient')) {
        errorMessage = 'You are not authorized to decrypt this message.';
      } else if (e.toString().contains('Invalid TOTP code')) {
        errorMessage = 'Invalid TOTP code. Please try again.';
      } else if (e.toString().contains('Message tampered')) {
        errorMessage = 'Message integrity check failed. The message may have been tampered with.';
      } else if (e.toString().contains('Too many decryption requests')) {
        errorMessage = 'Too many decryption requests. Please try again later.';
      }

      state = AsyncValue.error(
        Exception(errorMessage),
        StackTrace.current,
      );
    }
  }

  /// Resets the notifier state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for message encryption notifier
@riverpod
MessageEncryptionNotifier messageEncryptionNotifier(Ref ref) {
  return MessageEncryptionNotifier(ref);
}

/// Stream of message encryption state
@riverpod
AsyncValue<EncryptedMessage?> messageEncryptionState(Ref ref) {
  return ref.watch(messageEncryptionNotifierProvider);
}

/// Provider for encryption statistics and monitoring
@riverpod
AsyncValue<EncryptionStatistics> encryptionStatistics(Ref ref) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);

  if (currentUser == null) {
    return const AsyncValue.data(EncryptionStatistics(
      encryptedMessagesCount: 0,
      decryptedMessagesCount: 0,
      keyRotationsCount: 0,
      lastActivity: null,
    ));
  }

  // In a real implementation, you would fetch statistics from Firestore
  // For now, return default statistics
  return const AsyncValue.data(EncryptionStatistics(
    encryptedMessagesCount: 0,
    decryptedMessagesCount: 0,
    keyRotationsCount: 0,
    lastActivity: null,
  ));
}

/// Data class for encryption statistics
class EncryptionStatistics {
  final int encryptedMessagesCount;
  final int decryptedMessagesCount;
  final int keyRotationsCount;
  final DateTime? lastActivity;

  const EncryptionStatistics({
    required this.encryptedMessagesCount,
    required this.decryptedMessagesCount,
    required this.keyRotationsCount,
    this.lastActivity,
  });
}