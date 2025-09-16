import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/connectivity_service.dart';
import '../models/crew_communication.dart';
import '../models/message_attachment.dart';
import '../services/crew_communication_service.dart';

part 'crew_communication_provider.g.dart';

/// State class for crew communication management
class CrewCommunicationState {
  final Map<String, List<CrewCommunication>> messagesByCrewId;
  final Map<String, bool> loadingStates;
  final Map<String, String?> errors;
  final Map<String, int> unreadCounts;
  final Map<String, Set<String>> typingIndicators;
  final Map<String, double> uploadProgress;
  final List<Map<String, dynamic>> offlineMessageQueue;
  final bool isOnline;

  const CrewCommunicationState({
    this.messagesByCrewId = const {},
    this.loadingStates = const {},
    this.errors = const {},
    this.unreadCounts = const {},
    this.typingIndicators = const {},
    this.uploadProgress = const {},
    this.offlineMessageQueue = const [],
    this.isOnline = true,
  });

  CrewCommunicationState copyWith({
    Map<String, List<CrewCommunication>>? messagesByCrewId,
    Map<String, bool>? loadingStates,
    Map<String, String?>? errors,
    Map<String, int>? unreadCounts,
    Map<String, Set<String>>? typingIndicators,
    Map<String, double>? uploadProgress,
    List<Map<String, dynamic>>? offlineMessageQueue,
    bool? isOnline,
  }) {
    return CrewCommunicationState(
      messagesByCrewId: messagesByCrewId ?? this.messagesByCrewId,
      loadingStates: loadingStates ?? this.loadingStates,
      errors: errors ?? this.errors,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      typingIndicators: typingIndicators ?? this.typingIndicators,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      offlineMessageQueue: offlineMessageQueue ?? this.offlineMessageQueue,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  /// Get messages for a specific crew
  List<CrewCommunication> getMessagesForCrew(String crewId) {
    return messagesByCrewId[crewId] ?? [];
  }

  /// Get loading state for a specific crew
  bool isLoadingForCrew(String crewId) {
    return loadingStates[crewId] ?? false;
  }

  /// Get error for a specific crew
  String? getErrorForCrew(String crewId) {
    return errors[crewId];
  }

  /// Get unread count for a specific crew
  int getUnreadCountForCrew(String crewId) {
    return unreadCounts[crewId] ?? 0;
  }

  /// Get typing users for a specific crew
  Set<String> getTypingUsersForCrew(String crewId) {
    return typingIndicators[crewId] ?? {};
  }

  /// Get upload progress for a specific attachment
  double getUploadProgressForAttachment(String attachmentId) {
    return uploadProgress[attachmentId] ?? 0.0;
  }
}

/// CrewCommunicationService provider
@riverpod
CrewCommunicationService crewCommunicationService(Ref ref) {
  return CrewCommunicationService();
}

/// Connectivity service provider for communication
@riverpod
ConnectivityService communicationConnectivityService(Ref ref) {
  return ConnectivityService();
}

/// Main CrewCommunicationProvider for managing real-time crew communication
@riverpod
class CrewCommunicationNotifier extends _$CrewCommunicationNotifier {
  Timer? _typingResetTimer;
  final Map<String, StreamSubscription<List<CrewCommunication>>> _messageStreams = {};
  final Map<String, Timer> _typingTimers = {};
  final Map<String, Timer> _uploadProgressTimers = {};
  final Map<String, Timer> _uploadCleanupTimers = {};

  @override
  CrewCommunicationState build() {
    ref.onDispose(() {
      _dispose();
    });

    // Listen to connectivity changes
    ref.listen(communicationConnectivityServiceProvider, (previous, next) {
      final isOnline = next.isOnline;
      state = state.copyWith(isOnline: isOnline);

      // Process offline queue when coming back online
      if (isOnline && state.offlineMessageQueue.isNotEmpty) {
        _processOfflineQueue();
      }
    });

    return const CrewCommunicationState();
  }

  /// Get real-time message stream for a crew
  Stream<List<CrewCommunication>> getMessagesStream(String crewId) {
    try {
      final service = ref.read(crewCommunicationServiceProvider);
      return service.listenToCrewMessages(crewId);
    } catch (e) {
      // Return empty stream on error
      return Stream.value([]);
    }
  }

  /// Start listening to messages for a crew
  Future<void> startListeningToMessages(String crewId) async {
    try {
      // Cancel existing stream if any
      await _messageStreams[crewId]?.cancel();

      // Set loading state
      final updatedLoadingStates = Map<String, bool>.from(state.loadingStates);
      updatedLoadingStates[crewId] = true;
      state = state.copyWith(loadingStates: updatedLoadingStates);

      final service = ref.read(crewCommunicationServiceProvider);

      // Create new stream subscription
      _messageStreams[crewId] = service.listenToCrewMessages(crewId).listen(
        (messages) {
          _updateMessagesForCrew(crewId, messages);
          _updateUnreadCount(crewId, messages);

          // Clear loading state
          final updatedLoadingStates = Map<String, bool>.from(state.loadingStates);
          updatedLoadingStates[crewId] = false;
          state = state.copyWith(loadingStates: updatedLoadingStates);
        },
        onError: (error) {
          _setErrorForCrew(crewId, error.toString());

          // Clear loading state
          final updatedLoadingStates = Map<String, bool>.from(state.loadingStates);
          updatedLoadingStates[crewId] = false;
          state = state.copyWith(loadingStates: updatedLoadingStates);
        },
      );
    } catch (e) {
      _setErrorForCrew(crewId, 'Failed to start listening to messages: $e');

      // Clear loading state
      final updatedLoadingStates = Map<String, bool>.from(state.loadingStates);
      updatedLoadingStates[crewId] = false;
      state = state.copyWith(loadingStates: updatedLoadingStates);
    }
  }

  /// Stop listening to messages for a crew
  Future<void> stopListeningToMessages(String crewId) async {
    await _messageStreams[crewId]?.cancel();
    _messageStreams.remove(crewId);
    _typingTimers[crewId]?.cancel();
    _typingTimers.remove(crewId);
  }

  /// Send a message to crew
  Future<void> sendMessage({
    required String crewId,
    required String content,
    required MessageType messageType,
    List<MessageAttachment>? attachments,
  }) async {
    try {
      final service = ref.read(crewCommunicationServiceProvider);

      if (state.isOnline) {
        // Send immediately if online
        final result = await service.sendMessage(
          crewId: crewId,
          content: content,
          messageType: messageType,
          attachments: attachments,
        );

        if (!result.success) {
          throw Exception(result.error ?? 'Failed to send message');
        }
      } else {
        // Queue for offline sending
        _queueOfflineMessage({
          'crewId': crewId,
          'content': content,
          'messageType': messageType.name,
          'attachments': attachments?.map((a) => a.toJson()).toList(),
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'sendMessage',
        });
      }
    } catch (e) {
      _setErrorForCrew(crewId, 'Failed to send message: $e');
      rethrow;
    }
  }

  /// Send safety announcement
  Future<void> sendSafetyAnnouncement({
    required String crewId,
    required String content,
    required SafetyLevel safetyLevel,
    required MessageUrgency urgency,
  }) async {
    try {
      final service = ref.read(crewCommunicationServiceProvider);

      if (state.isOnline) {
        final result = await service.sendSafetyAnnouncement(
          crewId: crewId,
          content: content,
          safetyLevel: safetyLevel,
          urgency: urgency,
        );

        if (!result.success) {
          throw Exception(result.error ?? 'Failed to send safety announcement');
        }
      } else {
        // Queue for offline sending
        _queueOfflineMessage({
          'crewId': crewId,
          'content': content,
          'safetyLevel': safetyLevel.name,
          'urgency': urgency.name,
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'sendSafetyAnnouncement',
        });
      }
    } catch (e) {
      _setErrorForCrew(crewId, 'Failed to send safety announcement: $e');
      rethrow;
    }
  }

  /// Send emergency alert
  Future<void> sendEmergencyAlert({
    required String crewId,
    required String content,
    required Map<String, dynamic> location,
  }) async {
    try {
      final service = ref.read(crewCommunicationServiceProvider);

      if (state.isOnline) {
        final result = await service.sendEmergencyAlert(
          crewId: crewId,
          content: content,
          location: location,
        );

        if (!result.success) {
          throw Exception(result.error ?? 'Failed to send emergency alert');
        }
      } else {
        // Queue for offline sending with high priority
        _queueOfflineMessage({
          'crewId': crewId,
          'content': content,
          'location': location,
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'sendEmergencyAlert',
          'priority': 'emergency',
        });
      }
    } catch (e) {
      _setErrorForCrew(crewId, 'Failed to send emergency alert: $e');
      rethrow;
    }
  }

  /// Send safety check-in
  Future<void> sendSafetyCheckin({
    required String crewId,
    required String content,
    required SafetyStatus safetyStatus,
    List<String>? clearances,
    int? crewCount,
    String? location,
  }) async {
    try {
      final service = ref.read(crewCommunicationServiceProvider);

      if (state.isOnline) {
        final result = await service.sendSafetyCheckin(
          crewId: crewId,
          content: content,
          safetyStatus: safetyStatus,
          clearances: clearances,
          crewCount: crewCount,
          location: location,
        );

        if (!result.success) {
          throw Exception(result.error ?? 'Failed to send safety check-in');
        }
      } else {
        // Queue for offline sending
        _queueOfflineMessage({
          'crewId': crewId,
          'content': content,
          'safetyStatus': safetyStatus.name,
          'clearances': clearances,
          'crewCount': crewCount,
          'location': location,
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'sendSafetyCheckin',
        });
      }
    } catch (e) {
      _setErrorForCrew(crewId, 'Failed to send safety check-in: $e');
      rethrow;
    }
  }

  /// Upload attachment with progress tracking
  Future<String> uploadAttachment({
    required String messageId,
    required File attachment,
    required String attachmentId,
  }) async {
    try {
      final service = ref.read(crewCommunicationServiceProvider);

      // Initialize progress
      final updatedProgress = Map<String, double>.from(state.uploadProgress);
      updatedProgress[attachmentId] = 0.0;
      state = state.copyWith(uploadProgress: updatedProgress);

      // TODO: Implement progress tracking in service
      // For now, simulate progress updates
      _uploadProgressTimers[attachmentId] = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        final currentProgress = state.uploadProgress[attachmentId] ?? 0.0;
        if (currentProgress >= 1.0) {
          timer.cancel();
          _uploadProgressTimers.remove(attachmentId);
          return;
        }

        final newProgress = (currentProgress + 0.1).clamp(0.0, 0.9);
        final updatedProgress = Map<String, double>.from(state.uploadProgress);
        updatedProgress[attachmentId] = newProgress;
        state = state.copyWith(uploadProgress: updatedProgress);
      });

      // Upload attachment
      final downloadUrl = await service.uploadAttachment(messageId, attachment);

      // Complete progress
      final finalProgress = Map<String, double>.from(state.uploadProgress);
      finalProgress[attachmentId] = 1.0;
      state = state.copyWith(uploadProgress: finalProgress);

      // Clean up progress after delay
      _uploadCleanupTimers[attachmentId] = Timer(const Duration(seconds: 2), () {
        final cleanedProgress = Map<String, double>.from(state.uploadProgress);
        cleanedProgress.remove(attachmentId);
        state = state.copyWith(uploadProgress: cleanedProgress);
        _uploadCleanupTimers.remove(attachmentId);
      });

      return downloadUrl;
    } catch (e) {
      // Cancel and clean up timers on error
      _uploadProgressTimers[attachmentId]?.cancel();
      _uploadProgressTimers.remove(attachmentId);
      _uploadCleanupTimers[attachmentId]?.cancel();
      _uploadCleanupTimers.remove(attachmentId);

      // Remove progress on error
      final cleanedProgress = Map<String, double>.from(state.uploadProgress);
      cleanedProgress.remove(attachmentId);
      state = state.copyWith(uploadProgress: cleanedProgress);

      throw Exception('Failed to upload attachment: $e');
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      final service = ref.read(crewCommunicationServiceProvider);
      await service.markMessageAsRead(messageId, userId);
    } catch (e) {
      // Log error but don't throw - marking as read is not critical
      debugPrint('Failed to mark message as read: $e');
    }
  }

  /// Set typing indicator for a crew
  void setTypingIndicator(String crewId, String userId, bool isTyping) {
    final updatedIndicators = Map<String, Set<String>>.from(state.typingIndicators);

    if (!updatedIndicators.containsKey(crewId)) {
      updatedIndicators[crewId] = <String>{};
    }

    if (isTyping) {
      updatedIndicators[crewId]!.add(userId);

      // Reset typing indicator after 3 seconds
      _typingTimers[crewId]?.cancel();
      _typingTimers[crewId] = Timer(const Duration(seconds: 3), () {
        final indicators = Map<String, Set<String>>.from(state.typingIndicators);
        indicators[crewId]?.remove(userId);
        state = state.copyWith(typingIndicators: indicators);
      });
    } else {
      updatedIndicators[crewId]!.remove(userId);
    }

    state = state.copyWith(typingIndicators: updatedIndicators);
  }

  /// Get unread count stream for a crew
  Stream<int> getUnreadCountStream(String crewId) {
    return Stream.fromIterable([state.getUnreadCountForCrew(crewId)]);
  }

  /// Clear error for a crew
  void clearErrorForCrew(String crewId) {
    final updatedErrors = Map<String, String?>.from(state.errors);
    updatedErrors.remove(crewId);
    state = state.copyWith(errors: updatedErrors);
  }

  /// Edit a message
  Future<void> editMessage({
    required String crewId,
    required String messageId,
    required String newContent,
  }) async {
    try {
      final service = ref.read(crewCommunicationServiceProvider);

      if (state.isOnline) {
        final result = await service.editMessage(
          crewId: crewId,
          messageId: messageId,
          newContent: newContent,
        );

        if (!result.success) {
          throw Exception(result.error ?? 'Failed to edit message');
        }
      } else {
        // Queue for offline processing
        _queueOfflineMessage({
          'crewId': crewId,
          'messageId': messageId,
          'newContent': newContent,
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'editMessage',
        });
      }
    } catch (e) {
      _setErrorForCrew(crewId, 'Failed to edit message: $e');
      rethrow;
    }
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String crewId,
    required String messageId,
  }) async {
    try {
      final service = ref.read(crewCommunicationServiceProvider);

      if (state.isOnline) {
        final result = await service.deleteMessage(
          crewId: crewId,
          messageId: messageId,
        );

        if (!result.success) {
          throw Exception(result.error ?? 'Failed to delete message');
        }
      } else {
        // Queue for offline processing
        _queueOfflineMessage({
          'crewId': crewId,
          'messageId': messageId,
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'deleteMessage',
        });
      }
    } catch (e) {
      _setErrorForCrew(crewId, 'Failed to delete message: $e');
      rethrow;
    }
  }

  /// Pin or unpin a message
  Future<void> pinMessage({
    required String crewId,
    required String messageId,
  }) async {
    try {
      final service = ref.read(crewCommunicationServiceProvider);

      if (state.isOnline) {
        final result = await service.pinMessage(
          crewId: crewId,
          messageId: messageId,
        );

        if (!result.success) {
          throw Exception(result.error ?? 'Failed to pin message');
        }
      } else {
        // Queue for offline processing
        _queueOfflineMessage({
          'crewId': crewId,
          'messageId': messageId,
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'pinMessage',
        });
      }
    } catch (e) {
      _setErrorForCrew(crewId, 'Failed to pin message: $e');
      rethrow;
    }
  }

  // Private helper methods

  void _updateMessagesForCrew(String crewId, List<CrewCommunication> messages) {
    final updatedMessages = Map<String, List<CrewCommunication>>.from(state.messagesByCrewId);
    updatedMessages[crewId] = messages;
    state = state.copyWith(messagesByCrewId: updatedMessages);
  }

  void _updateUnreadCount(String crewId, List<CrewCommunication> messages) {
    // TODO: Implement actual unread count logic based on user ID and read receipts
    // For now, use a simple count of recent messages
    final unreadCount = messages.where((msg) =>
      DateTime.now().difference(msg.timestamp).inHours < 24
    ).length;

    final updatedCounts = Map<String, int>.from(state.unreadCounts);
    updatedCounts[crewId] = unreadCount;
    state = state.copyWith(unreadCounts: updatedCounts);
  }

  void _setErrorForCrew(String crewId, String error) {
    final updatedErrors = Map<String, String?>.from(state.errors);
    updatedErrors[crewId] = error;
    state = state.copyWith(errors: updatedErrors);
  }

  void _queueOfflineMessage(Map<String, dynamic> messageData) {
    final updatedQueue = List<Map<String, dynamic>>.from(state.offlineMessageQueue);

    // Add priority handling
    if (messageData['priority'] == 'emergency') {
      updatedQueue.insert(0, messageData);
    } else {
      updatedQueue.add(messageData);
    }

    state = state.copyWith(offlineMessageQueue: updatedQueue);
  }

  Future<void> _processOfflineQueue() async {
    if (state.offlineMessageQueue.isEmpty) return;

    final service = ref.read(crewCommunicationServiceProvider);
    final processedMessages = <Map<String, dynamic>>[];

    for (final messageData in state.offlineMessageQueue) {
      try {
        switch (messageData['action']) {
          case 'sendMessage':
            await service.sendMessage(
              crewId: messageData['crewId'],
              content: messageData['content'],
              messageType: MessageType.values.firstWhere(
                (t) => t.name == messageData['messageType'],
                orElse: () => MessageType.text,
              ),
              attachments: (messageData['attachments'] as List?)
                  ?.map((a) => MessageAttachment.fromJson(a))
                  .toList(),
            );
            break;
          case 'sendSafetyAnnouncement':
            await service.sendSafetyAnnouncement(
              crewId: messageData['crewId'],
              content: messageData['content'],
              safetyLevel: SafetyLevel.values.firstWhere(
                (s) => s.name == messageData['safetyLevel'],
                orElse: () => SafetyLevel.general,
              ),
              urgency: MessageUrgency.values.firstWhere(
                (u) => u.name == messageData['urgency'],
                orElse: () => MessageUrgency.normal,
              ),
            );
            break;
          case 'sendEmergencyAlert':
            await service.sendEmergencyAlert(
              crewId: messageData['crewId'],
              content: messageData['content'],
              location: messageData['location'],
            );
            break;
          case 'sendSafetyCheckin':
            await service.sendSafetyCheckin(
              crewId: messageData['crewId'],
              content: messageData['content'],
              safetyStatus: SafetyStatus.values.firstWhere(
                (s) => s.name == messageData['safetyStatus'],
                orElse: () => SafetyStatus.allClear,
              ),
              clearances: messageData['clearances']?.cast<String>(),
              crewCount: messageData['crewCount'],
              location: messageData['location'],
            );
            break;
          case 'editMessage':
            await service.editMessage(
              crewId: messageData['crewId'],
              messageId: messageData['messageId'],
              newContent: messageData['newContent'],
            );
            break;
          case 'deleteMessage':
            await service.deleteMessage(
              crewId: messageData['crewId'],
              messageId: messageData['messageId'],
            );
            break;
          case 'pinMessage':
            await service.pinMessage(
              crewId: messageData['crewId'],
              messageId: messageData['messageId'],
            );
            break;
        }

        processedMessages.add(messageData);
      } catch (e) {
        // Log error but continue with other messages
        debugPrint('Failed to process offline message: $e');
      }
    }

    // Remove processed messages from queue
    final updatedQueue = List<Map<String, dynamic>>.from(state.offlineMessageQueue);
    for (final processed in processedMessages) {
      updatedQueue.remove(processed);
    }
    state = state.copyWith(offlineMessageQueue: updatedQueue);
  }

  void _dispose() {
    _typingResetTimer?.cancel();

    for (final subscription in _messageStreams.values) {
      subscription.cancel();
    }
    _messageStreams.clear();

    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();

    for (final timer in _uploadProgressTimers.values) {
      timer.cancel();
    }
    _uploadProgressTimers.clear();

    for (final timer in _uploadCleanupTimers.values) {
      timer.cancel();
    }
    _uploadCleanupTimers.clear();
  }
}

/// Provider for getting messages for a specific crew
@riverpod
Stream<List<CrewCommunication>> crewMessages(Ref ref, String crewId) {
  final notifier = ref.watch(crewCommunicationNotifierProvider.notifier);
  return notifier.getMessagesStream(crewId);
}

/// Provider for getting unread count for a specific crew
@riverpod
Stream<int> crewUnreadCount(Ref ref, String crewId) {
  final notifier = ref.watch(crewCommunicationNotifierProvider.notifier);
  return notifier.getUnreadCountStream(crewId);
}

/// Provider for checking if any crew has unread messages
@riverpod
bool hasUnreadMessages(Ref ref) {
  final state = ref.watch(crewCommunicationNotifierProvider);
  return state.unreadCounts.values.any((count) => count > 0);
}

/// Provider for getting total unread count across all crews
@riverpod
int totalUnreadCount(Ref ref) {
  final state = ref.watch(crewCommunicationNotifierProvider);
  return state.unreadCounts.values.fold(0, (total, count) => total + count);
}

/// Provider for checking if any crew is currently loading
@riverpod
bool isAnyCrewLoading(Ref ref) {
  final state = ref.watch(crewCommunicationNotifierProvider);
  return state.loadingStates.values.any((isLoading) => isLoading);
}

/// Provider for getting all crew communication errors
@riverpod
List<String> allCommunicationErrors(Ref ref) {
  final state = ref.watch(crewCommunicationNotifierProvider);
  return state.errors.values.where((error) => error != null).cast<String>().toList();
}

/// Provider for checking if there are pending offline messages
@riverpod
bool hasPendingOfflineMessages(Ref ref) {
  final state = ref.watch(crewCommunicationNotifierProvider);
  return state.offlineMessageQueue.isNotEmpty;
}

/// Provider for getting offline message count
@riverpod
int offlineMessageCount(Ref ref) {
  final state = ref.watch(crewCommunicationNotifierProvider);
  return state.offlineMessageQueue.length;
}