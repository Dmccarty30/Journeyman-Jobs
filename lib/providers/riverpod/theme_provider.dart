import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../design_system/app_theme.dart';

part 'theme_provider.g.dart';

enum ThemeModePreference { system, light, dark }

@Riverpod(keepAlive: true)
class AppThemeNotifier extends _$AppThemeNotifier {
  static const _themeModeKey = 'theme_mode_preference';

  @override
  Future<ThemeModePreference> build() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString(_themeModeKey);

    if (storedMode == 'light') {
      return ThemeModePreference.light;
    } else if (storedMode == 'dark') {
      return ThemeModePreference.dark;
    } else {
      return ThemeModePreference.system;
    }
  }

  /// Sets the new theme mode and persists it.
  Future<void> setThemeMode(ThemeModePreference newMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, newMode.name);
    state = AsyncData(newMode);
  }

  /// Returns the actual ThemeData based on the current preference and system brightness.
  ThemeData getThemeData(BuildContext context) {
    final Brightness systemBrightness = MediaQuery.of(context).platformBrightness;

    return state.when(
      data: (mode) {
        if (mode == ThemeModePreference.dark || (mode == ThemeModePreference.system && systemBrightness == Brightness.dark)) {
          return AppTheme.darkTheme;
        } else {
          return AppTheme.lightTheme;
        }
      },
      loading: () => AppTheme.lightTheme, // Default while loading preference
      error: (_, __) => AppTheme.lightTheme, // Default on error
    );
  }
}
