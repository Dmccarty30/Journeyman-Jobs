// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// MessageService provider

@ProviderFor(messageService)
final messageServiceProvider = MessageServiceProvider._();

/// MessageService provider

final class MessageServiceProvider
    extends $FunctionalProvider<MessageService, MessageService, MessageService>
    with $Provider<MessageService> {
  /// MessageService provider
  MessageServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'messageServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageServiceHash();

  @$internal
  @override
  $ProviderElement<MessageService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MessageService create(Ref ref) {
    return messageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageService>(value),
    );
  }
}

String _$messageServiceHash() => r'd0c924722f972d18522e390071877fc71dc7770b';

/// Stream of crew messages

@ProviderFor(crewMessagesStream)
final crewMessagesStreamProvider = CrewMessagesStreamFamily._();

/// Stream of crew messages

final class CrewMessagesStreamProvider extends $FunctionalProvider<
        AsyncValue<List<Message>>, List<Message>, Stream<List<Message>>>
    with $FutureModifier<List<Message>>, $StreamProvider<List<Message>> {
  /// Stream of crew messages
  CrewMessagesStreamProvider._(
      {required CrewMessagesStreamFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'crewMessagesStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewMessagesStreamHash();

  @override
  String toString() {
    return r'crewMessagesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Message>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Message>> create(Ref ref) {
    final argument = this.argument as String;
    return crewMessagesStream(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrewMessagesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewMessagesStreamHash() =>
    r'903679ba6624d817e27e8d80946d749b35110bf4';

/// Stream of crew messages

final class CrewMessagesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Message>>, String> {
  CrewMessagesStreamFamily._()
      : super(
          retry: null,
          name: r'crewMessagesStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Stream of crew messages

  CrewMessagesStreamProvider call(
    String crewId,
  ) =>
      CrewMessagesStreamProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewMessagesStreamProvider';
}

/// Crew messages

@ProviderFor(crewMessages)
final crewMessagesProvider = CrewMessagesFamily._();

/// Crew messages

final class CrewMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Crew messages
  CrewMessagesProvider._(
      {required CrewMessagesFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'crewMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewMessagesHash();

  @override
  String toString() {
    return r'crewMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return crewMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrewMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewMessagesHash() => r'2b788980c72654ed115942ed3c16728af4ac8403';

/// Crew messages

final class CrewMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  CrewMessagesFamily._()
      : super(
          retry: null,
          name: r'crewMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Crew messages

  CrewMessagesProvider call(
    String crewId,
  ) =>
      CrewMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewMessagesProvider';
}

/// Stream of direct messages between two users

@ProviderFor(directMessagesStream)
final directMessagesStreamProvider = DirectMessagesStreamFamily._();

/// Stream of direct messages between two users

final class DirectMessagesStreamProvider extends $FunctionalProvider<
        AsyncValue<List<Message>>, List<Message>, Stream<List<Message>>>
    with $FutureModifier<List<Message>>, $StreamProvider<List<Message>> {
  /// Stream of direct messages between two users
  DirectMessagesStreamProvider._(
      {required DirectMessagesStreamFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'directMessagesStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$directMessagesStreamHash();

  @override
  String toString() {
    return r'directMessagesStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Message>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Message>> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return directMessagesStream(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DirectMessagesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$directMessagesStreamHash() =>
    r'8f09c28902277c7f5600a93b26599257c715ad2e';

/// Stream of direct messages between two users

final class DirectMessagesStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
            Stream<List<Message>>,
            (
              String,
              String,
            )> {
  DirectMessagesStreamFamily._()
      : super(
          retry: null,
          name: r'directMessagesStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Stream of direct messages between two users

  DirectMessagesStreamProvider call(
    String userId1,
    String userId2,
  ) =>
      DirectMessagesStreamProvider._(argument: (
        userId1,
        userId2,
      ), from: this);

  @override
  String toString() => r'directMessagesStreamProvider';
}

/// Direct messages between two users

@ProviderFor(directMessages)
final directMessagesProvider = DirectMessagesFamily._();

/// Direct messages between two users

final class DirectMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Direct messages between two users
  DirectMessagesProvider._(
      {required DirectMessagesFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'directMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$directMessagesHash();

  @override
  String toString() {
    return r'directMessagesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return directMessages(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DirectMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$directMessagesHash() => r'35d2daa71eee2775122fa32ebd11dabcb29e3da7';

/// Direct messages between two users

final class DirectMessagesFamily extends $Family
    with
        $FunctionalFamilyOverride<
            List<Message>,
            (
              String,
              String,
            )> {
  DirectMessagesFamily._()
      : super(
          retry: null,
          name: r'directMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Direct messages between two users

  DirectMessagesProvider call(
    String userId1,
    String userId2,
  ) =>
      DirectMessagesProvider._(argument: (
        userId1,
        userId2,
      ), from: this);

  @override
  String toString() => r'directMessagesProvider';
}

/// Provider to get unread crew messages count for current user

@ProviderFor(unreadCrewMessagesCount)
final unreadCrewMessagesCountProvider = UnreadCrewMessagesCountFamily._();

/// Provider to get unread crew messages count for current user

final class UnreadCrewMessagesCountProvider
    extends $FunctionalProvider<int, int, int> with $Provider<int> {
  /// Provider to get unread crew messages count for current user
  UnreadCrewMessagesCountProvider._(
      {required UnreadCrewMessagesCountFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'unreadCrewMessagesCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unreadCrewMessagesCountHash();

  @override
  String toString() {
    return r'unreadCrewMessagesCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return unreadCrewMessagesCount(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadCrewMessagesCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unreadCrewMessagesCountHash() =>
    r'66f940db2600c43798c7313c12588d5892594e1c';

/// Provider to get unread crew messages count for current user

final class UnreadCrewMessagesCountFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  UnreadCrewMessagesCountFamily._()
      : super(
          retry: null,
          name: r'unreadCrewMessagesCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get unread crew messages count for current user

  UnreadCrewMessagesCountProvider call(
    String crewId,
  ) =>
      UnreadCrewMessagesCountProvider._(argument: crewId, from: this);

  @override
  String toString() => r'unreadCrewMessagesCountProvider';
}

/// Provider to get unread direct messages count for current user

@ProviderFor(unreadDirectMessagesCount)
final unreadDirectMessagesCountProvider = UnreadDirectMessagesCountFamily._();

/// Provider to get unread direct messages count for current user

final class UnreadDirectMessagesCountProvider
    extends $FunctionalProvider<int, int, int> with $Provider<int> {
  /// Provider to get unread direct messages count for current user
  UnreadDirectMessagesCountProvider._(
      {required UnreadDirectMessagesCountFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'unreadDirectMessagesCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unreadDirectMessagesCountHash();

  @override
  String toString() {
    return r'unreadDirectMessagesCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return unreadDirectMessagesCount(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadDirectMessagesCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unreadDirectMessagesCountHash() =>
    r'2b3a4ee3839057579e9588ea50118aac2a239778';

/// Provider to get unread direct messages count for current user

final class UnreadDirectMessagesCountFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  UnreadDirectMessagesCountFamily._()
      : super(
          retry: null,
          name: r'unreadDirectMessagesCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get unread direct messages count for current user

  UnreadDirectMessagesCountProvider call(
    String otherUserId,
  ) =>
      UnreadDirectMessagesCountProvider._(argument: otherUserId, from: this);

  @override
  String toString() => r'unreadDirectMessagesCountProvider';
}

/// Provider to get total unread messages count for current user across all crews

@ProviderFor(totalUnreadMessages)
final totalUnreadMessagesProvider = TotalUnreadMessagesProvider._();

/// Provider to get total unread messages count for current user across all crews

final class TotalUnreadMessagesProvider
    extends $FunctionalProvider<int, int, int> with $Provider<int> {
  /// Provider to get total unread messages count for current user across all crews
  TotalUnreadMessagesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'totalUnreadMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$totalUnreadMessagesHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return totalUnreadMessages(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$totalUnreadMessagesHash() =>
    r'9b8fd81d5967fa3e90e48ba5cf2357f568bf5bac';

/// Provider to get recent messages (last 24 hours)

@ProviderFor(recentMessages)
final recentMessagesProvider = RecentMessagesFamily._();

/// Provider to get recent messages (last 24 hours)

final class RecentMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get recent messages (last 24 hours)
  RecentMessagesProvider._(
      {required RecentMessagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'recentMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentMessagesHash();

  @override
  String toString() {
    return r'recentMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return recentMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecentMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentMessagesHash() => r'd93c6f22000cc902144e74a18af6c4c817c755ec';

/// Provider to get recent messages (last 24 hours)

final class RecentMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  RecentMessagesFamily._()
      : super(
          retry: null,
          name: r'recentMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get recent messages (last 24 hours)

  RecentMessagesProvider call(
    String crewId,
  ) =>
      RecentMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'recentMessagesProvider';
}

/// Provider to get messages by sender

@ProviderFor(messagesBySender)
final messagesBySenderProvider = MessagesBySenderFamily._();

/// Provider to get messages by sender

final class MessagesBySenderProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get messages by sender
  MessagesBySenderProvider._(
      {required MessagesBySenderFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'messagesBySenderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messagesBySenderHash();

  @override
  String toString() {
    return r'messagesBySenderProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return messagesBySender(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesBySenderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesBySenderHash() => r'2c748b089dcba2a154a7cd6891cdb4dcfe5832cf';

/// Provider to get messages by sender

final class MessagesBySenderFamily extends $Family
    with
        $FunctionalFamilyOverride<
            List<Message>,
            (
              String,
              String,
            )> {
  MessagesBySenderFamily._()
      : super(
          retry: null,
          name: r'messagesBySenderProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get messages by sender

  MessagesBySenderProvider call(
    String crewId,
    String senderId,
  ) =>
      MessagesBySenderProvider._(argument: (
        crewId,
        senderId,
      ), from: this);

  @override
  String toString() => r'messagesBySenderProvider';
}

/// Provider to get messages with attachments

@ProviderFor(messagesWithAttachments)
final messagesWithAttachmentsProvider = MessagesWithAttachmentsFamily._();

/// Provider to get messages with attachments

final class MessagesWithAttachmentsProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get messages with attachments
  MessagesWithAttachmentsProvider._(
      {required MessagesWithAttachmentsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'messagesWithAttachmentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messagesWithAttachmentsHash();

  @override
  String toString() {
    return r'messagesWithAttachmentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return messagesWithAttachments(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesWithAttachmentsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesWithAttachmentsHash() =>
    r'532ba024f2c7612df55d8516a66f3cae134ff2f2';

/// Provider to get messages with attachments

final class MessagesWithAttachmentsFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  MessagesWithAttachmentsFamily._()
      : super(
          retry: null,
          name: r'messagesWithAttachmentsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get messages with attachments

  MessagesWithAttachmentsProvider call(
    String crewId,
  ) =>
      MessagesWithAttachmentsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'messagesWithAttachmentsProvider';
}

/// Provider to get latest message in a crew

@ProviderFor(latestMessage)
final latestMessageProvider = LatestMessageFamily._();

/// Provider to get latest message in a crew

final class LatestMessageProvider
    extends $FunctionalProvider<Message?, Message?, Message?>
    with $Provider<Message?> {
  /// Provider to get latest message in a crew
  LatestMessageProvider._(
      {required LatestMessageFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'latestMessageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$latestMessageHash();

  @override
  String toString() {
    return r'latestMessageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Message?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Message? create(Ref ref) {
    final argument = this.argument as String;
    return latestMessage(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Message? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Message?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LatestMessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$latestMessageHash() => r'fcdf1c416b555afe0614a24e3462911627e0e210';

/// Provider to get latest message in a crew

final class LatestMessageFamily extends $Family
    with $FunctionalFamilyOverride<Message?, String> {
  LatestMessageFamily._()
      : super(
          retry: null,
          name: r'latestMessageProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get latest message in a crew

  LatestMessageProvider call(
    String crewId,
  ) =>
      LatestMessageProvider._(argument: crewId, from: this);

  @override
  String toString() => r'latestMessageProvider';
}

/// Provider to get last message timestamp

@ProviderFor(lastMessageTimestamp)
final lastMessageTimestampProvider = LastMessageTimestampFamily._();

/// Provider to get last message timestamp

final class LastMessageTimestampProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  /// Provider to get last message timestamp
  LastMessageTimestampProvider._(
      {required LastMessageTimestampFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'lastMessageTimestampProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lastMessageTimestampHash();

  @override
  String toString() {
    return r'lastMessageTimestampProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    final argument = this.argument as String;
    return lastMessageTimestamp(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LastMessageTimestampProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastMessageTimestampHash() =>
    r'e189b600e293734f74b755e6fc5c1c1763651812';

/// Provider to get last message timestamp

final class LastMessageTimestampFamily extends $Family
    with $FunctionalFamilyOverride<DateTime?, String> {
  LastMessageTimestampFamily._()
      : super(
          retry: null,
          name: r'lastMessageTimestampProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get last message timestamp

  LastMessageTimestampProvider call(
    String crewId,
  ) =>
      LastMessageTimestampProvider._(argument: crewId, from: this);

  @override
  String toString() => r'lastMessageTimestampProvider';
}

/// Provider to check if crew has unread messages

@ProviderFor(hasUnreadCrewMessages)
final hasUnreadCrewMessagesProvider = HasUnreadCrewMessagesFamily._();

/// Provider to check if crew has unread messages

final class HasUnreadCrewMessagesProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider to check if crew has unread messages
  HasUnreadCrewMessagesProvider._(
      {required HasUnreadCrewMessagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'hasUnreadCrewMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hasUnreadCrewMessagesHash();

  @override
  String toString() {
    return r'hasUnreadCrewMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return hasUnreadCrewMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HasUnreadCrewMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasUnreadCrewMessagesHash() =>
    r'8ccc64117e8c278c804d7a7e5c2e206a1e66bc6a';

/// Provider to check if crew has unread messages

final class HasUnreadCrewMessagesFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  HasUnreadCrewMessagesFamily._()
      : super(
          retry: null,
          name: r'hasUnreadCrewMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to check if crew has unread messages

  HasUnreadCrewMessagesProvider call(
    String crewId,
  ) =>
      HasUnreadCrewMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'hasUnreadCrewMessagesProvider';
}

/// Provider to get message by ID

@ProviderFor(messageById)
final messageByIdProvider = MessageByIdFamily._();

/// Provider to get message by ID

final class MessageByIdProvider
    extends $FunctionalProvider<Message?, Message?, Message?>
    with $Provider<Message?> {
  /// Provider to get message by ID
  MessageByIdProvider._(
      {required MessageByIdFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'messageByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageByIdHash();

  @override
  String toString() {
    return r'messageByIdProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<Message?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Message? create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return messageById(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Message? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Message?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessageByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageByIdHash() => r'546796067825c82a423dcbb8202f5a14dec588d8';

/// Provider to get message by ID

final class MessageByIdFamily extends $Family
    with
        $FunctionalFamilyOverride<
            Message?,
            (
              String,
              String,
            )> {
  MessageByIdFamily._()
      : super(
          retry: null,
          name: r'messageByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get message by ID

  MessageByIdProvider call(
    String crewId,
    String messageId,
  ) =>
      MessageByIdProvider._(argument: (
        crewId,
        messageId,
      ), from: this);

  @override
  String toString() => r'messageByIdProvider';
}

/// Provider to get read receipts for a message

@ProviderFor(messageReadReceipts)
final messageReadReceiptsProvider = MessageReadReceiptsFamily._();

/// Provider to get read receipts for a message

final class MessageReadReceiptsProvider extends $FunctionalProvider<
    Map<String, DateTime>,
    Map<String, DateTime>,
    Map<String, DateTime>> with $Provider<Map<String, DateTime>> {
  /// Provider to get read receipts for a message
  MessageReadReceiptsProvider._(
      {required MessageReadReceiptsFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'messageReadReceiptsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageReadReceiptsHash();

  @override
  String toString() {
    return r'messageReadReceiptsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<Map<String, DateTime>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, DateTime> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return messageReadReceipts(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, DateTime>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessageReadReceiptsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageReadReceiptsHash() =>
    r'b24d930879d052a017c7380376e335b2e6ea2cd9';

/// Provider to get read receipts for a message

final class MessageReadReceiptsFamily extends $Family
    with
        $FunctionalFamilyOverride<
            Map<String, DateTime>,
            (
              String,
              String,
            )> {
  MessageReadReceiptsFamily._()
      : super(
          retry: null,
          name: r'messageReadReceiptsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get read receipts for a message

  MessageReadReceiptsProvider call(
    String crewId,
    String messageId,
  ) =>
      MessageReadReceiptsProvider._(argument: (
        crewId,
        messageId,
      ), from: this);

  @override
  String toString() => r'messageReadReceiptsProvider';
}

/// Provider to get read receipt count for a message

@ProviderFor(messageReadReceiptCount)
final messageReadReceiptCountProvider = MessageReadReceiptCountFamily._();

/// Provider to get read receipt count for a message

final class MessageReadReceiptCountProvider
    extends $FunctionalProvider<int, int, int> with $Provider<int> {
  /// Provider to get read receipt count for a message
  MessageReadReceiptCountProvider._(
      {required MessageReadReceiptCountFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'messageReadReceiptCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageReadReceiptCountHash();

  @override
  String toString() {
    return r'messageReadReceiptCountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return messageReadReceiptCount(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessageReadReceiptCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageReadReceiptCountHash() =>
    r'fdc10d8454f915c410b801c03ba32331f80732cf';

/// Provider to get read receipt count for a message

final class MessageReadReceiptCountFamily extends $Family
    with
        $FunctionalFamilyOverride<
            int,
            (
              String,
              String,
            )> {
  MessageReadReceiptCountFamily._()
      : super(
          retry: null,
          name: r'messageReadReceiptCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get read receipt count for a message

  MessageReadReceiptCountProvider call(
    String crewId,
    String messageId,
  ) =>
      MessageReadReceiptCountProvider._(argument: (
        crewId,
        messageId,
      ), from: this);

  @override
  String toString() => r'messageReadReceiptCountProvider';
}

/// Provider to check if message has been read by specific user

@ProviderFor(isMessageReadBy)
final isMessageReadByProvider = IsMessageReadByFamily._();

/// Provider to check if message has been read by specific user

final class IsMessageReadByProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider to check if message has been read by specific user
  IsMessageReadByProvider._(
      {required IsMessageReadByFamily super.from,
      required (
        String,
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'isMessageReadByProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isMessageReadByHash();

  @override
  String toString() {
    return r'isMessageReadByProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
      String,
    );
    return isMessageReadBy(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsMessageReadByProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isMessageReadByHash() => r'63e7ff7999670cf76964f85026d466ec59ebf69e';

/// Provider to check if message has been read by specific user

final class IsMessageReadByFamily extends $Family
    with
        $FunctionalFamilyOverride<
            bool,
            (
              String,
              String,
              String,
            )> {
  IsMessageReadByFamily._()
      : super(
          retry: null,
          name: r'isMessageReadByProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to check if message has been read by specific user

  IsMessageReadByProvider call(
    String crewId,
    String messageId,
    String userId,
  ) =>
      IsMessageReadByProvider._(argument: (
        crewId,
        messageId,
        userId,
      ), from: this);

  @override
  String toString() => r'isMessageReadByProvider';
}

/// Provider to get messages in chronological order

@ProviderFor(chronologicalMessages)
final chronologicalMessagesProvider = ChronologicalMessagesFamily._();

/// Provider to get messages in chronological order

final class ChronologicalMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get messages in chronological order
  ChronologicalMessagesProvider._(
      {required ChronologicalMessagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'chronologicalMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chronologicalMessagesHash();

  @override
  String toString() {
    return r'chronologicalMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return chronologicalMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChronologicalMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chronologicalMessagesHash() =>
    r'3fdfd8eb70e4c1ca18729a9a4b9d6b9c6f1ebe63';

/// Provider to get messages in chronological order

final class ChronologicalMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  ChronologicalMessagesFamily._()
      : super(
          retry: null,
          name: r'chronologicalMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get messages in chronological order

  ChronologicalMessagesProvider call(
    String crewId,
  ) =>
      ChronologicalMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'chronologicalMessagesProvider';
}

/// Provider to get messages in reverse chronological order

@ProviderFor(reverseChronologicalMessages)
final reverseChronologicalMessagesProvider =
    ReverseChronologicalMessagesFamily._();

/// Provider to get messages in reverse chronological order

final class ReverseChronologicalMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get messages in reverse chronological order
  ReverseChronologicalMessagesProvider._(
      {required ReverseChronologicalMessagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'reverseChronologicalMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reverseChronologicalMessagesHash();

  @override
  String toString() {
    return r'reverseChronologicalMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return reverseChronologicalMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReverseChronologicalMessagesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reverseChronologicalMessagesHash() =>
    r'258f4313c9c762a4a8534d9c633b769a30ea7425';

/// Provider to get messages in reverse chronological order

final class ReverseChronologicalMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  ReverseChronologicalMessagesFamily._()
      : super(
          retry: null,
          name: r'reverseChronologicalMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get messages in reverse chronological order

  ReverseChronologicalMessagesProvider call(
    String crewId,
  ) =>
      ReverseChronologicalMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'reverseChronologicalMessagesProvider';
}

/// Provider to get text messages only

@ProviderFor(textMessages)
final textMessagesProvider = TextMessagesFamily._();

/// Provider to get text messages only

final class TextMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get text messages only
  TextMessagesProvider._(
      {required TextMessagesFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'textMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$textMessagesHash();

  @override
  String toString() {
    return r'textMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return textMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TextMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$textMessagesHash() => r'b30bb47ea6d7e8d97696a722de17d55ff2996cbc';

/// Provider to get text messages only

final class TextMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  TextMessagesFamily._()
      : super(
          retry: null,
          name: r'textMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get text messages only

  TextMessagesProvider call(
    String crewId,
  ) =>
      TextMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'textMessagesProvider';
}

/// Provider to get messages with job shares

@ProviderFor(jobShareMessages)
final jobShareMessagesProvider = JobShareMessagesFamily._();

/// Provider to get messages with job shares

final class JobShareMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get messages with job shares
  JobShareMessagesProvider._(
      {required JobShareMessagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'jobShareMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobShareMessagesHash();

  @override
  String toString() {
    return r'jobShareMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return jobShareMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JobShareMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$jobShareMessagesHash() => r'514a17dc6ed89176a2409b98534ab0361bb56e88';

/// Provider to get messages with job shares

final class JobShareMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  JobShareMessagesFamily._()
      : super(
          retry: null,
          name: r'jobShareMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get messages with job shares

  JobShareMessagesProvider call(
    String crewId,
  ) =>
      JobShareMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'jobShareMessagesProvider';
}

/// Provider to get system notification messages

@ProviderFor(systemNotificationMessages)
final systemNotificationMessagesProvider = SystemNotificationMessagesFamily._();

/// Provider to get system notification messages

final class SystemNotificationMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get system notification messages
  SystemNotificationMessagesProvider._(
      {required SystemNotificationMessagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'systemNotificationMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$systemNotificationMessagesHash();

  @override
  String toString() {
    return r'systemNotificationMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return systemNotificationMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SystemNotificationMessagesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$systemNotificationMessagesHash() =>
    r'dc25401b5b4194760fe96913a60ec15f276b057d';

/// Provider to get system notification messages

final class SystemNotificationMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  SystemNotificationMessagesFamily._()
      : super(
          retry: null,
          name: r'systemNotificationMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get system notification messages

  SystemNotificationMessagesProvider call(
    String crewId,
  ) =>
      SystemNotificationMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'systemNotificationMessagesProvider';
}

/// Provider to get message count for a crew

@ProviderFor(messageCount)
final messageCountProvider = MessageCountFamily._();

/// Provider to get message count for a crew

final class MessageCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider to get message count for a crew
  MessageCountProvider._(
      {required MessageCountFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'messageCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageCountHash();

  @override
  String toString() {
    return r'messageCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return messageCount(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessageCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageCountHash() => r'392355a811a0e713908945c2e23a0a6fb807d4ca';

/// Provider to get message count for a crew

final class MessageCountFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  MessageCountFamily._()
      : super(
          retry: null,
          name: r'messageCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get message count for a crew

  MessageCountProvider call(
    String crewId,
  ) =>
      MessageCountProvider._(argument: crewId, from: this);

  @override
  String toString() => r'messageCountProvider';
}

/// Provider to get today's messages

@ProviderFor(todaysMessages)
final todaysMessagesProvider = TodaysMessagesFamily._();

/// Provider to get today's messages

final class TodaysMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get today's messages
  TodaysMessagesProvider._(
      {required TodaysMessagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'todaysMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todaysMessagesHash();

  @override
  String toString() {
    return r'todaysMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return todaysMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TodaysMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todaysMessagesHash() => r'a9cf9ed2c6402b15b3362ca2cc3d88b58f8fb4cf';

/// Provider to get today's messages

final class TodaysMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  TodaysMessagesFamily._()
      : super(
          retry: null,
          name: r'todaysMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get today's messages

  TodaysMessagesProvider call(
    String crewId,
  ) =>
      TodaysMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'todaysMessagesProvider';
}

/// Provider to get messages from last week

@ProviderFor(lastWeekMessages)
final lastWeekMessagesProvider = LastWeekMessagesFamily._();

/// Provider to get messages from last week

final class LastWeekMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Provider to get messages from last week
  LastWeekMessagesProvider._(
      {required LastWeekMessagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'lastWeekMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lastWeekMessagesHash();

  @override
  String toString() {
    return r'lastWeekMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    final argument = this.argument as String;
    return lastWeekMessages(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LastWeekMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastWeekMessagesHash() => r'1b44f5704cadd7ed136f72e5bd556173df62a8ce';

/// Provider to get messages from last week

final class LastWeekMessagesFamily extends $Family
    with $FunctionalFamilyOverride<List<Message>, String> {
  LastWeekMessagesFamily._()
      : super(
          retry: null,
          name: r'lastWeekMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get messages from last week

  LastWeekMessagesProvider call(
    String crewId,
  ) =>
      LastWeekMessagesProvider._(argument: crewId, from: this);

  @override
  String toString() => r'lastWeekMessagesProvider';
}
