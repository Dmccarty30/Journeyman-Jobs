// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_feed_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream of global messages

@ProviderFor(globalMessagesStream)
const globalMessagesStreamProvider = GlobalMessagesStreamProvider._();

/// Stream of global messages

final class GlobalMessagesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Message>>,
          List<Message>,
          Stream<List<Message>>
        >
    with $FutureModifier<List<Message>>, $StreamProvider<List<Message>> {
  /// Stream of global messages
  const GlobalMessagesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalMessagesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalMessagesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Message>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Message>> create(Ref ref) {
    return globalMessagesStream(ref);
  }
}

String _$globalMessagesStreamHash() =>
    r'049d535b34ae95f81dc651445652368b4b881bf2';

/// Global messages

@ProviderFor(globalMessages)
const globalMessagesProvider = GlobalMessagesProvider._();

/// Global messages

final class GlobalMessagesProvider
    extends $FunctionalProvider<List<Message>, List<Message>, List<Message>>
    with $Provider<List<Message>> {
  /// Global messages
  const GlobalMessagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalMessagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalMessagesHash();

  @$internal
  @override
  $ProviderElement<List<Message>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Message> create(Ref ref) {
    return globalMessages(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }
}

String _$globalMessagesHash() => r'ab50198c26eb20f5ec83ad064dc16dfca4c80d77';

/// Provider to send a global message

@ProviderFor(SendGlobalMessageNotifier)
const sendGlobalMessageProvider = SendGlobalMessageNotifierProvider._();

/// Provider to send a global message
final class SendGlobalMessageNotifierProvider
    extends $NotifierProvider<SendGlobalMessageNotifier, void> {
  /// Provider to send a global message
  const SendGlobalMessageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendGlobalMessageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendGlobalMessageNotifierHash();

  @$internal
  @override
  SendGlobalMessageNotifier create() => SendGlobalMessageNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$sendGlobalMessageNotifierHash() =>
    r'70c6861af622d342af0f9fbdc59551aa40ee8225';

/// Provider to send a global message

abstract class _$SendGlobalMessageNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

/// Provider to get unread global messages count

@ProviderFor(unreadGlobalCount)
const unreadGlobalCountProvider = UnreadGlobalCountProvider._();

/// Provider to get unread global messages count

final class UnreadGlobalCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider to get unread global messages count
  const UnreadGlobalCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadGlobalCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadGlobalCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return unreadGlobalCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadGlobalCountHash() => r'403b028c9adf40eb5aa1ab09dcf1f2dab15b487b';
