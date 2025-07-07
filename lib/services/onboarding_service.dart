import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  
  /// Singleton instance
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  /// Check if user has completed onboarding
  Future<bool> isOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompleteKey) ?? false;
    } catch (e) {
      // If there's an error reading preferences, assume onboarding is not complete
      return false;
    }
  }

  /// Mark onboarding as complete
  Future<void> markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, true);
    } catch (e) {
      // Log error but don't throw - onboarding completion is not critical for app function
      debugPrint('Error marking onboarding complete: $e');
    }
  }

  /// Reset onboarding status (for testing/debugging)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, false);
    } catch (e) {
      debugPrint('Error resetting onboarding: $e');
    }
  }

  /// Clear all onboarding related preferences
  Future<void> clearOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompleteKey);
    } catch (e) {
      debugPrint('Error clearing onboarding data: $e');
    }
  }
}