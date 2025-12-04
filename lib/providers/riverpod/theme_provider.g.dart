// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppThemeNotifier)
const appThemeProvider = AppThemeNotifierProvider._();

final class AppThemeNotifierProvider
    extends $AsyncNotifierProvider<AppThemeNotifier, ThemeModePreference> {
  const AppThemeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appThemeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appThemeNotifierHash();

  @$internal
  @override
  AppThemeNotifier create() => AppThemeNotifier();
}

String _$appThemeNotifierHash() => r'25c8d9f4fe5e3921ffca6b77493a6782ab05c5c8';

abstract class _$AppThemeNotifier extends $AsyncNotifier<ThemeModePreference> {
  FutureOr<ThemeModePreference> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<ThemeModePreference>, ThemeModePreference>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ThemeModePreference>, ThemeModePreference>,
        AsyncValue<ThemeModePreference>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
