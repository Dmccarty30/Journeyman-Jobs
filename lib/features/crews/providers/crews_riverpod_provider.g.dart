// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crews_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// JobSharingService provider

@ProviderFor(jobSharingService)
final jobSharingServiceProvider = JobSharingServiceProvider._();

/// JobSharingService provider

final class JobSharingServiceProvider extends $FunctionalProvider<
    JobSharingService,
    JobSharingService,
    JobSharingService> with $Provider<JobSharingService> {
  /// JobSharingService provider
  JobSharingServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'jobSharingServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobSharingServiceHash();

  @$internal
  @override
  $ProviderElement<JobSharingService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JobSharingService create(Ref ref) {
    return jobSharingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobSharingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobSharingService>(value),
    );
  }
}

String _$jobSharingServiceHash() => r'2afec26ba06e06e5154bd86876c1ce2b5956f9bb';

/// JobMatchingService provider

@ProviderFor(jobMatchingService)
final jobMatchingServiceProvider = JobMatchingServiceProvider._();

/// JobMatchingService provider

final class JobMatchingServiceProvider extends $FunctionalProvider<
    JobMatchingService,
    JobMatchingService,
    JobMatchingService> with $Provider<JobMatchingService> {
  /// JobMatchingService provider
  JobMatchingServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'jobMatchingServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$jobMatchingServiceHash();

  @$internal
  @override
  $ProviderElement<JobMatchingService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JobMatchingService create(Ref ref) {
    return jobMatchingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobMatchingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobMatchingService>(value),
    );
  }
}

String _$jobMatchingServiceHash() =>
    r'2759b5cec59520714ca12c4c2d8cda70892ac617';

/// CrewService provider

@ProviderFor(crewService)
final crewServiceProvider = CrewServiceProvider._();

/// CrewService provider

final class CrewServiceProvider
    extends $FunctionalProvider<CrewService, CrewService, CrewService>
    with $Provider<CrewService> {
  /// CrewService provider
  CrewServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'crewServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewServiceHash();

  @$internal
  @override
  $ProviderElement<CrewService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrewService create(Ref ref) {
    return crewService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrewService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrewService>(value),
    );
  }
}

String _$crewServiceHash() => r'9e698e95231d8d3c25fac5543d79e52c3735bf12';

/// Stream of crews for the current user

@ProviderFor(userCrewsStream)
final userCrewsStreamProvider = UserCrewsStreamProvider._();

/// Stream of crews for the current user

final class UserCrewsStreamProvider extends $FunctionalProvider<
        AsyncValue<List<Crew>>, List<Crew>, Stream<List<Crew>>>
    with $FutureModifier<List<Crew>>, $StreamProvider<List<Crew>> {
  /// Stream of crews for the current user
  UserCrewsStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userCrewsStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userCrewsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Crew>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Crew>> create(Ref ref) {
    return userCrewsStream(ref);
  }
}

String _$userCrewsStreamHash() => r'6b7c8df69c33081dadf68808f9c291119ffbcddd';

/// Current user's crews provider

@ProviderFor(userCrews)
final userCrewsProvider = UserCrewsProvider._();

/// Current user's crews provider

final class UserCrewsProvider
    extends $FunctionalProvider<List<Crew>, List<Crew>, List<Crew>>
    with $Provider<List<Crew>> {
  /// Current user's crews provider
  UserCrewsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userCrewsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userCrewsHash();

  @$internal
  @override
  $ProviderElement<List<Crew>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Crew> create(Ref ref) {
    return userCrews(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Crew> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Crew>>(value),
    );
  }
}

String _$userCrewsHash() => r'298a533caa58a465d0e6ec46cdf1ad03ccc12df8';

/// Selected crew provider

@ProviderFor(selectedCrew)
final selectedCrewProvider = SelectedCrewProvider._();

/// Selected crew provider

final class SelectedCrewProvider
    extends $FunctionalProvider<Crew?, Crew?, Crew?> with $Provider<Crew?> {
  /// Selected crew provider
  SelectedCrewProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCrewProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedCrewHash();

  @$internal
  @override
  $ProviderElement<Crew?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Crew? create(Ref ref) {
    return selectedCrew(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Crew? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Crew?>(value),
    );
  }
}

String _$selectedCrewHash() => r'7da0b10ed7a33ed8b2da2d60178785710934bea5';

/// Selected crew notifier provider

@ProviderFor(selectedCrewNotifierProvider)
final selectedCrewNotifierProviderProvider =
    SelectedCrewNotifierProviderProvider._();

/// Selected crew notifier provider

final class SelectedCrewNotifierProviderProvider extends $FunctionalProvider<
    SelectedCrewNotifier,
    SelectedCrewNotifier,
    SelectedCrewNotifier> with $Provider<SelectedCrewNotifier> {
  /// Selected crew notifier provider
  SelectedCrewNotifierProviderProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCrewNotifierProviderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedCrewNotifierProviderHash();

  @$internal
  @override
  $ProviderElement<SelectedCrewNotifier> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SelectedCrewNotifier create(Ref ref) {
    return selectedCrewNotifierProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectedCrewNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectedCrewNotifier>(value),
    );
  }
}

String _$selectedCrewNotifierProviderHash() =>
    r'e720cf8f7f08eee41dcaea57ac90d459ec62f4a1';

/// Provider to check if current user is in a specific crew

@ProviderFor(isUserInCrew)
final isUserInCrewProvider = IsUserInCrewFamily._();

/// Provider to check if current user is in a specific crew

final class IsUserInCrewProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider to check if current user is in a specific crew
  IsUserInCrewProvider._(
      {required IsUserInCrewFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'isUserInCrewProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isUserInCrewHash();

  @override
  String toString() {
    return r'isUserInCrewProvider'
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
    return isUserInCrew(
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
    return other is IsUserInCrewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isUserInCrewHash() => r'8a18e705716676a93812b72bd319ac382beb7116';

/// Provider to check if current user is in a specific crew

final class IsUserInCrewFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsUserInCrewFamily._()
      : super(
          retry: null,
          name: r'isUserInCrewProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to check if current user is in a specific crew

  IsUserInCrewProvider call(
    String crewId,
  ) =>
      IsUserInCrewProvider._(argument: crewId, from: this);

  @override
  String toString() => r'isUserInCrewProvider';
}

/// Provider to get user's role in a specific crew

@ProviderFor(userRoleInCrew)
final userRoleInCrewProvider = UserRoleInCrewFamily._();

/// Provider to get user's role in a specific crew

final class UserRoleInCrewProvider
    extends $FunctionalProvider<MemberRole?, MemberRole?, MemberRole?>
    with $Provider<MemberRole?> {
  /// Provider to get user's role in a specific crew
  UserRoleInCrewProvider._(
      {required UserRoleInCrewFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userRoleInCrewProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userRoleInCrewHash();

  @override
  String toString() {
    return r'userRoleInCrewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<MemberRole?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemberRole? create(Ref ref) {
    final argument = this.argument as String;
    return userRoleInCrew(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberRole? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberRole?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserRoleInCrewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userRoleInCrewHash() => r'1530eb47af8cf6752a1bc2e81bb15510e471085b';

/// Provider to get user's role in a specific crew

final class UserRoleInCrewFamily extends $Family
    with $FunctionalFamilyOverride<MemberRole?, String> {
  UserRoleInCrewFamily._()
      : super(
          retry: null,
          name: r'userRoleInCrewProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get user's role in a specific crew

  UserRoleInCrewProvider call(
    String crewId,
  ) =>
      UserRoleInCrewProvider._(argument: crewId, from: this);

  @override
  String toString() => r'userRoleInCrewProvider';
}

/// Provider to check if user has a specific permission in a crew

@ProviderFor(hasCrewPermission)
final hasCrewPermissionProvider = HasCrewPermissionFamily._();

/// Provider to check if user has a specific permission in a crew

final class HasCrewPermissionProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider to check if user has a specific permission in a crew
  HasCrewPermissionProvider._(
      {required HasCrewPermissionFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'hasCrewPermissionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hasCrewPermissionHash();

  @override
  String toString() {
    return r'hasCrewPermissionProvider'
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
    );
    return hasCrewPermission(
      ref,
      argument.$1,
      argument.$2,
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
    return other is HasCrewPermissionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasCrewPermissionHash() => r'331ba93fa32fe0977fdefee1ad467f9d9b3033e0';

/// Provider to check if user has a specific permission in a crew

final class HasCrewPermissionFamily extends $Family
    with
        $FunctionalFamilyOverride<
            bool,
            (
              String,
              String,
            )> {
  HasCrewPermissionFamily._()
      : super(
          retry: null,
          name: r'hasCrewPermissionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to check if user has a specific permission in a crew

  HasCrewPermissionProvider call(
    String crewId,
    String permission,
  ) =>
      HasCrewPermissionProvider._(argument: (
        crewId,
        permission,
      ), from: this);

  @override
  String toString() => r'hasCrewPermissionProvider';
}

/// Provider to get crew members stream

@ProviderFor(crewMembersStream)
final crewMembersStreamProvider = CrewMembersStreamFamily._();

/// Provider to get crew members stream

final class CrewMembersStreamProvider extends $FunctionalProvider<
        AsyncValue<List<CrewMember>>,
        List<CrewMember>,
        Stream<List<CrewMember>>>
    with $FutureModifier<List<CrewMember>>, $StreamProvider<List<CrewMember>> {
  /// Provider to get crew members stream
  CrewMembersStreamProvider._(
      {required CrewMembersStreamFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'crewMembersStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewMembersStreamHash();

  @override
  String toString() {
    return r'crewMembersStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CrewMember>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<CrewMember>> create(Ref ref) {
    final argument = this.argument as String;
    return crewMembersStream(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrewMembersStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewMembersStreamHash() => r'7896f7dcc34e70f8fdfafa4b6c264514baa05da0';

/// Provider to get crew members stream

final class CrewMembersStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<CrewMember>>, String> {
  CrewMembersStreamFamily._()
      : super(
          retry: null,
          name: r'crewMembersStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get crew members stream

  CrewMembersStreamProvider call(
    String crewId,
  ) =>
      CrewMembersStreamProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewMembersStreamProvider';
}

/// Provider to get crew members

@ProviderFor(crewMembers)
final crewMembersProvider = CrewMembersFamily._();

/// Provider to get crew members

final class CrewMembersProvider extends $FunctionalProvider<List<CrewMember>,
    List<CrewMember>, List<CrewMember>> with $Provider<List<CrewMember>> {
  /// Provider to get crew members
  CrewMembersProvider._(
      {required CrewMembersFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'crewMembersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewMembersHash();

  @override
  String toString() {
    return r'crewMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<CrewMember>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<CrewMember> create(Ref ref) {
    final argument = this.argument as String;
    return crewMembers(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CrewMember> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CrewMember>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrewMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewMembersHash() => r'd9e381c26118c59f15f2aac0e69305358bf47118';

/// Provider to get crew members

final class CrewMembersFamily extends $Family
    with $FunctionalFamilyOverride<List<CrewMember>, String> {
  CrewMembersFamily._()
      : super(
          retry: null,
          name: r'crewMembersProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get crew members

  CrewMembersProvider call(
    String crewId,
  ) =>
      CrewMembersProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewMembersProvider';
}

/// Provider to get current user's crew member data

@ProviderFor(currentUserCrewMember)
final currentUserCrewMemberProvider = CurrentUserCrewMemberFamily._();

/// Provider to get current user's crew member data

final class CurrentUserCrewMemberProvider
    extends $FunctionalProvider<CrewMember?, CrewMember?, CrewMember?>
    with $Provider<CrewMember?> {
  /// Provider to get current user's crew member data
  CurrentUserCrewMemberProvider._(
      {required CurrentUserCrewMemberFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'currentUserCrewMemberProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserCrewMemberHash();

  @override
  String toString() {
    return r'currentUserCrewMemberProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CrewMember?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrewMember? create(Ref ref) {
    final argument = this.argument as String;
    return currentUserCrewMember(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrewMember? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrewMember?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentUserCrewMemberProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentUserCrewMemberHash() =>
    r'9018a173b7ff2c56796809be206e7e5186bf63e4';

/// Provider to get current user's crew member data

final class CurrentUserCrewMemberFamily extends $Family
    with $FunctionalFamilyOverride<CrewMember?, String> {
  CurrentUserCrewMemberFamily._()
      : super(
          retry: null,
          name: r'currentUserCrewMemberProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get current user's crew member data

  CurrentUserCrewMemberProvider call(
    String crewId,
  ) =>
      CurrentUserCrewMemberProvider._(argument: crewId, from: this);

  @override
  String toString() => r'currentUserCrewMemberProvider';
}

/// Provider to check if current user is crew foreman

@ProviderFor(isCrewForeman)
final isCrewForemanProvider = IsCrewForemanFamily._();

/// Provider to check if current user is crew foreman

final class IsCrewForemanProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider to check if current user is crew foreman
  IsCrewForemanProvider._(
      {required IsCrewForemanFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'isCrewForemanProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isCrewForemanHash();

  @override
  String toString() {
    return r'isCrewForemanProvider'
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
    return isCrewForeman(
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
    return other is IsCrewForemanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isCrewForemanHash() => r'70ef9c7fb287fefa817e033cecb943cabd92d8f4';

/// Provider to check if current user is crew foreman

final class IsCrewForemanFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsCrewForemanFamily._()
      : super(
          retry: null,
          name: r'isCrewForemanProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to check if current user is crew foreman

  IsCrewForemanProvider call(
    String crewId,
  ) =>
      IsCrewForemanProvider._(argument: crewId, from: this);

  @override
  String toString() => r'isCrewForemanProvider';
}

/// Provider to get crew by ID

@ProviderFor(crewById)
final crewByIdProvider = CrewByIdFamily._();

/// Provider to get crew by ID

final class CrewByIdProvider extends $FunctionalProvider<Crew?, Crew?, Crew?>
    with $Provider<Crew?> {
  /// Provider to get crew by ID
  CrewByIdProvider._(
      {required CrewByIdFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'crewByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewByIdHash();

  @override
  String toString() {
    return r'crewByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Crew?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Crew? create(Ref ref) {
    final argument = this.argument as String;
    return crewById(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Crew? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Crew?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrewByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewByIdHash() => r'7dfbdb4f0e6292ccf36f0ee068b316295f6de322';

/// Provider to get crew by ID

final class CrewByIdFamily extends $Family
    with $FunctionalFamilyOverride<Crew?, String> {
  CrewByIdFamily._()
      : super(
          retry: null,
          name: r'crewByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get crew by ID

  CrewByIdProvider call(
    String crewId,
  ) =>
      CrewByIdProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewByIdProvider';
}

/// Provider to get active crews only

@ProviderFor(activeCrews)
final activeCrewsProvider = ActiveCrewsProvider._();

/// Provider to get active crews only

final class ActiveCrewsProvider
    extends $FunctionalProvider<List<Crew>, List<Crew>, List<Crew>>
    with $Provider<List<Crew>> {
  /// Provider to get active crews only
  ActiveCrewsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeCrewsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeCrewsHash();

  @$internal
  @override
  $ProviderElement<List<Crew>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Crew> create(Ref ref) {
    return activeCrews(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Crew> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Crew>>(value),
    );
  }
}

String _$activeCrewsHash() => r'9febda40cc21b48e35eab819410bad95a5bb9bf9';

/// Provider to get crew count

@ProviderFor(crewCount)
final crewCountProvider = CrewCountProvider._();

/// Provider to get crew count

final class CrewCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider to get crew count
  CrewCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'crewCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return crewCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$crewCountHash() => r'9b15b161e49cf5addd99dfe18147b5e7b967ce39';

/// Provider to check if user can create crews

@ProviderFor(canCreateCrews)
final canCreateCrewsProvider = CanCreateCrewsProvider._();

/// Provider to check if user can create crews

final class CanCreateCrewsProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider to check if user can create crews
  CanCreateCrewsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'canCreateCrewsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$canCreateCrewsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canCreateCrews(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canCreateCrewsHash() => r'1e8e4048d5f5d997806596894d6dc4da6f32fa28';

/// Provider to get crew creation limit

@ProviderFor(crewCreationLimit)
final crewCreationLimitProvider = CrewCreationLimitProvider._();

/// Provider to get crew creation limit

final class CrewCreationLimitProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider to get crew creation limit
  CrewCreationLimitProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'crewCreationLimitProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewCreationLimitHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return crewCreationLimit(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$crewCreationLimitHash() => r'aade676a47e107b5301e6dbabc86eb13059c9742';

/// Provider to check if user has reached crew creation limit

@ProviderFor(hasReachedCrewLimit)
final hasReachedCrewLimitProvider = HasReachedCrewLimitProvider._();

/// Provider to check if user has reached crew creation limit

final class HasReachedCrewLimitProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider to check if user has reached crew creation limit
  HasReachedCrewLimitProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hasReachedCrewLimitProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hasReachedCrewLimitHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasReachedCrewLimit(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasReachedCrewLimitHash() =>
    r'6c6cb512f0d8e6bf943cfa282f23b8a09ade7736';

/// Provider for crew creation notifier

@ProviderFor(crewCreationNotifier)
final crewCreationProvider = CrewCreationNotifierProvider._();

/// Provider for crew creation notifier

final class CrewCreationNotifierProvider extends $FunctionalProvider<
    CrewCreationNotifier,
    CrewCreationNotifier,
    CrewCreationNotifier> with $Provider<CrewCreationNotifier> {
  /// Provider for crew creation notifier
  CrewCreationNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'crewCreationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewCreationNotifierHash();

  @$internal
  @override
  $ProviderElement<CrewCreationNotifier> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrewCreationNotifier create(Ref ref) {
    return crewCreationNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrewCreationNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrewCreationNotifier>(value),
    );
  }
}

String _$crewCreationNotifierHash() =>
    r'28a17361d065e3366282ec119e670c8bde834bdb';

/// Stream of crew creation state

@ProviderFor(crewCreationState)
final crewCreationStateProvider = CrewCreationStateProvider._();

/// Stream of crew creation state

final class CrewCreationStateProvider extends $FunctionalProvider<
    AsyncValue<void>,
    AsyncValue<void>,
    AsyncValue<void>> with $Provider<AsyncValue<void>> {
  /// Stream of crew creation state
  CrewCreationStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'crewCreationStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crewCreationStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<void>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<void> create(Ref ref) {
    return crewCreationState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$crewCreationStateHash() => r'298083a6536d7e748562a55e99d5876d3c5cf8f0';
