// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for app settings service instance
///
/// Creates singleton service with Firestore and SharedPreferences dependencies

@ProviderFor(appSettingsService)
const appSettingsServiceProvider = AppSettingsServiceProvider._();

/// Provider for app settings service instance
///
/// Creates singleton service with Firestore and SharedPreferences dependencies

final class AppSettingsServiceProvider
    extends
        $FunctionalProvider<
          AppSettingsService,
          AppSettingsService,
          AppSettingsService
        >
    with $Provider<AppSettingsService> {
  /// Provider for app settings service instance
  ///
  /// Creates singleton service with Firestore and SharedPreferences dependencies
  const AppSettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsServiceHash();

  @$internal
  @override
  $ProviderElement<AppSettingsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppSettingsService create(Ref ref) {
    return appSettingsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettingsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettingsService>(value),
    );
  }
}

String _$appSettingsServiceHash() =>
    r'624b749abdd99f327a2dbc3b18f3b4ed712dacfc';

/// Riverpod notifier for managing app settings state
///
/// Handles loading, saving, and updating user app settings with
/// Firestore persistence and local caching. Provides reactive state
/// updates for UI components.
///
/// ## Usage:
///
/// ```dart
/// // Watch settings state
/// final settingsState = ref.watch(appSettingsNotifierProvider);
///
/// // Load settings for user
/// ref.read(appSettingsNotifierProvider.notifier).loadSettings(userId);
///
/// // Update single setting
/// ref.read(appSettingsNotifierProvider.notifier).updateThemeMode('dark');
///
/// // Save all settings
/// ref.read(appSettingsNotifierProvider.notifier).saveSettings(userId, settings);
/// ```

@ProviderFor(AppSettingsNotifier)
const appSettingsProvider = AppSettingsNotifierProvider._();

/// Riverpod notifier for managing app settings state
///
/// Handles loading, saving, and updating user app settings with
/// Firestore persistence and local caching. Provides reactive state
/// updates for UI components.
///
/// ## Usage:
///
/// ```dart
/// // Watch settings state
/// final settingsState = ref.watch(appSettingsNotifierProvider);
///
/// // Load settings for user
/// ref.read(appSettingsNotifierProvider.notifier).loadSettings(userId);
///
/// // Update single setting
/// ref.read(appSettingsNotifierProvider.notifier).updateThemeMode('dark');
///
/// // Save all settings
/// ref.read(appSettingsNotifierProvider.notifier).saveSettings(userId, settings);
/// ```
final class AppSettingsNotifierProvider
    extends $NotifierProvider<AppSettingsNotifier, AppSettingsState> {
  /// Riverpod notifier for managing app settings state
  ///
  /// Handles loading, saving, and updating user app settings with
  /// Firestore persistence and local caching. Provides reactive state
  /// updates for UI components.
  ///
  /// ## Usage:
  ///
  /// ```dart
  /// // Watch settings state
  /// final settingsState = ref.watch(appSettingsNotifierProvider);
  ///
  /// // Load settings for user
  /// ref.read(appSettingsNotifierProvider.notifier).loadSettings(userId);
  ///
  /// // Update single setting
  /// ref.read(appSettingsNotifierProvider.notifier).updateThemeMode('dark');
  ///
  /// // Save all settings
  /// ref.read(appSettingsNotifierProvider.notifier).saveSettings(userId, settings);
  /// ```
  const AppSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsNotifierHash();

  @$internal
  @override
  AppSettingsNotifier create() => AppSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettingsState>(value),
    );
  }
}

String _$appSettingsNotifierHash() =>
    r'5e2d66a88fabffdb1f1ec72a8dd31163b2f4cbf7';

/// Riverpod notifier for managing app settings state
///
/// Handles loading, saving, and updating user app settings with
/// Firestore persistence and local caching. Provides reactive state
/// updates for UI components.
///
/// ## Usage:
///
/// ```dart
/// // Watch settings state
/// final settingsState = ref.watch(appSettingsNotifierProvider);
///
/// // Load settings for user
/// ref.read(appSettingsNotifierProvider.notifier).loadSettings(userId);
///
/// // Update single setting
/// ref.read(appSettingsNotifierProvider.notifier).updateThemeMode('dark');
///
/// // Save all settings
/// ref.read(appSettingsNotifierProvider.notifier).saveSettings(userId, settings);
/// ```

abstract class _$AppSettingsNotifier extends $Notifier<AppSettingsState> {
  AppSettingsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppSettingsState, AppSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSettingsState, AppSettingsState>,
              AppSettingsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for current app settings

@ProviderFor(currentAppSettings)
const currentAppSettingsProvider = CurrentAppSettingsProvider._();

/// Provider for current app settings

final class CurrentAppSettingsProvider
    extends
        $FunctionalProvider<
          AppSettingsModel,
          AppSettingsModel,
          AppSettingsModel
        >
    with $Provider<AppSettingsModel> {
  /// Provider for current app settings
  const CurrentAppSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAppSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAppSettingsHash();

  @$internal
  @override
  $ProviderElement<AppSettingsModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppSettingsModel create(Ref ref) {
    return currentAppSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettingsModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettingsModel>(value),
    );
  }
}

String _$currentAppSettingsHash() =>
    r'484fcd9a4e5bebe281c9cb59901f68143deb8848';

/// Provider for checking if settings are loading

@ProviderFor(appSettingsLoading)
const appSettingsLoadingProvider = AppSettingsLoadingProvider._();

/// Provider for checking if settings are loading

final class AppSettingsLoadingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if settings are loading
  const AppSettingsLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsLoadingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return appSettingsLoading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appSettingsLoadingHash() =>
    r'264ea4320732b39770c953a1168f84593a49502c';

/// Provider for settings error message

@ProviderFor(appSettingsError)
const appSettingsErrorProvider = AppSettingsErrorProvider._();

/// Provider for settings error message

final class AppSettingsErrorProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Provider for settings error message
  const AppSettingsErrorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsErrorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsErrorHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return appSettingsError(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$appSettingsErrorHash() => r'4b7620d0090c671064990f680b8be011216383d0';

/// Provider for last updated timestamp

@ProviderFor(appSettingsLastUpdated)
const appSettingsLastUpdatedProvider = AppSettingsLastUpdatedProvider._();

/// Provider for last updated timestamp

final class AppSettingsLastUpdatedProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  /// Provider for last updated timestamp
  const AppSettingsLastUpdatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsLastUpdatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsLastUpdatedHash();

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    return appSettingsLastUpdated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$appSettingsLastUpdatedHash() =>
    r'682325a3ab68a8378ba5b28d72d37379155b6e0d';

/// Provider for theme mode from settings

@ProviderFor(appThemeMode)
const appThemeModeProvider = AppThemeModeProvider._();

/// Provider for theme mode from settings

final class AppThemeModeProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider for theme mode from settings
  const AppThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return appThemeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$appThemeModeHash() => r'04a947a0178420132c735aff2535335bce49529d';

/// Provider for electrical effects enabled state

@ProviderFor(electricalEffectsEnabled)
const electricalEffectsEnabledProvider = ElectricalEffectsEnabledProvider._();

/// Provider for electrical effects enabled state

final class ElectricalEffectsEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for electrical effects enabled state
  const ElectricalEffectsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'electricalEffectsEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$electricalEffectsEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return electricalEffectsEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$electricalEffectsEnabledHash() =>
    r'ee446d1536da44221f172f97d222166edce22b06';

/// Provider for location services enabled state

@ProviderFor(locationServicesEnabled)
const locationServicesEnabledProvider = LocationServicesEnabledProvider._();

/// Provider for location services enabled state

final class LocationServicesEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for location services enabled state
  const LocationServicesEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationServicesEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationServicesEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return locationServicesEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$locationServicesEnabledHash() =>
    r'a25dd9f277527c6e52f666f5d80ce70380dc7ba0';
