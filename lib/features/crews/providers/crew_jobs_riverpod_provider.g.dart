// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_jobs_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Crew filtered jobs stream provider - uses JobMatchingService to get jobs filtered by crew preferences

@ProviderFor(crewFilteredJobsStream)
const crewFilteredJobsStreamProvider = CrewFilteredJobsStreamFamily._();

/// Crew filtered jobs stream provider - uses JobMatchingService to get jobs filtered by crew preferences

final class CrewFilteredJobsStreamProvider
    extends
        $FunctionalProvider<AsyncValue<List<Job>>, List<Job>, Stream<List<Job>>>
    with $FutureModifier<List<Job>>, $StreamProvider<List<Job>> {
  /// Crew filtered jobs stream provider - uses JobMatchingService to get jobs filtered by crew preferences
  const CrewFilteredJobsStreamProvider._({
    required CrewFilteredJobsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'crewFilteredJobsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$crewFilteredJobsStreamHash();

  @override
  String toString() {
    return r'crewFilteredJobsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Job>> create(Ref ref) {
    final argument = this.argument as String;
    return crewFilteredJobsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CrewFilteredJobsStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewFilteredJobsStreamHash() =>
    r'd4b7a6a18089e562edae5495ed0c2e1859f887a5';

/// Crew filtered jobs stream provider - uses JobMatchingService to get jobs filtered by crew preferences

final class CrewFilteredJobsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Job>>, String> {
  const CrewFilteredJobsStreamFamily._()
    : super(
        retry: null,
        name: r'crewFilteredJobsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Crew filtered jobs stream provider - uses JobMatchingService to get jobs filtered by crew preferences

  CrewFilteredJobsStreamProvider call(String crewId) =>
      CrewFilteredJobsStreamProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewFilteredJobsStreamProvider';
}

/// Crew filtered jobs - extracts data from AsyncValue

@ProviderFor(crewFilteredJobs)
const crewFilteredJobsProvider = CrewFilteredJobsFamily._();

/// Crew filtered jobs - extracts data from AsyncValue

final class CrewFilteredJobsProvider
    extends $FunctionalProvider<List<Job>, List<Job>, List<Job>>
    with $Provider<List<Job>> {
  /// Crew filtered jobs - extracts data from AsyncValue
  const CrewFilteredJobsProvider._({
    required CrewFilteredJobsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'crewFilteredJobsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$crewFilteredJobsHash();

  @override
  String toString() {
    return r'crewFilteredJobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Job>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Job> create(Ref ref) {
    final argument = this.argument as String;
    return crewFilteredJobs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Job> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Job>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrewFilteredJobsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewFilteredJobsHash() => r'2febd448c247fe67444a37e57a3a1ed090cf3b92';

/// Crew filtered jobs - extracts data from AsyncValue

final class CrewFilteredJobsFamily extends $Family
    with $FunctionalFamilyOverride<List<Job>, String> {
  const CrewFilteredJobsFamily._()
    : super(
        retry: null,
        name: r'crewFilteredJobsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Crew filtered jobs - extracts data from AsyncValue

  CrewFilteredJobsProvider call(String crewId) =>
      CrewFilteredJobsProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewFilteredJobsProvider';
}

/// Provider to check if crew filtered jobs are loading

@ProviderFor(isCrewJobsLoading)
const isCrewJobsLoadingProvider = IsCrewJobsLoadingFamily._();

/// Provider to check if crew filtered jobs are loading

final class IsCrewJobsLoadingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider to check if crew filtered jobs are loading
  const IsCrewJobsLoadingProvider._({
    required IsCrewJobsLoadingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isCrewJobsLoadingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isCrewJobsLoadingHash();

  @override
  String toString() {
    return r'isCrewJobsLoadingProvider'
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
    return isCrewJobsLoading(ref, argument);
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
    return other is IsCrewJobsLoadingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isCrewJobsLoadingHash() => r'72047c801e0524108e71ffc8765d481de9c2dd1d';

/// Provider to check if crew filtered jobs are loading

final class IsCrewJobsLoadingFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const IsCrewJobsLoadingFamily._()
    : super(
        retry: null,
        name: r'isCrewJobsLoadingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to check if crew filtered jobs are loading

  IsCrewJobsLoadingProvider call(String crewId) =>
      IsCrewJobsLoadingProvider._(argument: crewId, from: this);

  @override
  String toString() => r'isCrewJobsLoadingProvider';
}

/// Provider for crew filtered jobs error

@ProviderFor(crewJobsError)
const crewJobsErrorProvider = CrewJobsErrorFamily._();

/// Provider for crew filtered jobs error

final class CrewJobsErrorProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Provider for crew filtered jobs error
  const CrewJobsErrorProvider._({
    required CrewJobsErrorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'crewJobsErrorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$crewJobsErrorHash();

  @override
  String toString() {
    return r'crewJobsErrorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as String;
    return crewJobsError(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CrewJobsErrorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crewJobsErrorHash() => r'2ead0efac25794aa79d159f4978293c938905177';

/// Provider for crew filtered jobs error

final class CrewJobsErrorFamily extends $Family
    with $FunctionalFamilyOverride<String?, String> {
  const CrewJobsErrorFamily._()
    : super(
        retry: null,
        name: r'crewJobsErrorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for crew filtered jobs error

  CrewJobsErrorProvider call(String crewId) =>
      CrewJobsErrorProvider._(argument: crewId, from: this);

  @override
  String toString() => r'crewJobsErrorProvider';
}
