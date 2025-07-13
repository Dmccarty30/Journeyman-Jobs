// Test runner for manual execution
import 'package:test/test.dart';

// Import all test files
import 'test/widget_test/screens/splash/splash_screen_test.dart' as splash_tests;
import 'test/widget_test/screens/auth/auth_screen_test.dart' as auth_tests;
import 'test/unit_test/providers/app_state_provider_test.dart' as app_state_tests;
import 'test/unit_test/providers/job_filter_provider_test.dart' as filter_tests;
import 'test/unit_test/services/auth_service_test.dart' as auth_service_tests;

void main() {
  group('All Tests', () {
    splash_tests.main();
    auth_tests.main();
    app_state_tests.main();
    filter_tests.main();
    auth_service_tests.main();
  });
}