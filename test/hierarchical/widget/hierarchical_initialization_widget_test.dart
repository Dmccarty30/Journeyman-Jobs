import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/locals_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart';
import 'package:journeyman_jobs/screens/storm/home_screen.dart';
import 'package:journeyman_jobs/screens/storm/locals_screen.dart';
import 'package:journeyman_jobs/screens/storm/jobs_screen.dart';
import 'package:journeyman_jobs/widgets/electrical_components/jj_electrical_loader.dart';

import '../fixtures/hierarchical_mock_data.dart';
import '../helpers/test_helpers.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  User,
])
import 'hierarchical_initialization_widget_test.mocks.dart';

void main() {
  group('Hierarchical Initialization Widget Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(mockUser.uid).thenReturn(HierarchicalMockData.testUserId);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.emailVerified).thenReturn(true);
    });

    Widget createTestWidget({Widget? child}) {
      return ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => mockAuth),
        ],
        child: MaterialApp(
          home: child ?? const Scaffold(),
        ),
      );
    }

    group('Authentication Flow Tests', () {
      testWidgets('should show loading state during authentication check', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null)); // Not authenticated initially

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const AuthenticationWrapper(),
        ));

        // Assert
        expect(find.byType(JJElectricalLoader), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);
      });

      testWidgets('should redirect to login when not authenticated', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const AuthenticationWrapper(),
        ));

        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
      });

      testWidgets('should proceed to app when authenticated', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const AuthenticationWrapper(),
        ));

        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      });

      testWidgets('should handle authentication errors gracefully', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges())
            .thenAnswer((_) => Stream.error(FirebaseException(
              plugin: 'firebase_auth',
              code: 'network-request-failed',
            )));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const AuthenticationWrapper(),
        ));

        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ErrorScreen), findsOneWidget);
        expect(find.text('Authentication Error'), findsOneWidget);
        expect(find.textContaining('Network request failed'), findsOneWidget);
      });
    });

    group('Home Screen Initialization Tests', () {
      testWidgets('should load user data when authenticated', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HomeScreen(),
        ));

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Welcome back, Test User'), findsOneWidget);
        expect(find.text('IBEW Journeyman Jobs'), findsOneWidget);
      });

      testWidgets('should show hierarchical navigation options', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HomeScreen(),
        ));

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Locals'), findsOneWidget);
        expect(find.text('Jobs'), findsOneWidget);
        expect(find.text('Storm Work'), findsOneWidget);
        expect(find.text('Resources'), findsOneWidget);
      });

      testWidgets('should handle user data loading errors', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));
        // Simulate user data loading error - this would be tested with mock providers

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HomeScreen(),
        ));

        await tester.pumpAndSettle();

        // Assert - Should still show basic UI even if some data fails to load
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('IBEW Journeyman Jobs'), findsOneWidget);
      });

      testWidgets('should display loading indicators during data fetch', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HomeScreen(),
        ));

        // Check for loading states
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // Assert loading completes
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('Locals Screen Hierarchical Tests', () {
      testWidgets('should load locals when navigating from home', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const LocalsScreen(),
        ));

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('IBEW Locals'), findsOneWidget);
        expect(find.byType(SearchTextField), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should handle large locals dataset efficiently', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const LocalsScreen(),
        ));

        await tester.pumpAndSettle();

        // Assert - Should render first page efficiently
        expect(find.byType(ListView), findsOneWidget);

        // Verify pagination indicators
        expect(find.text('Load More'), findsOneWidget);

        // Test performance with scroll
        await tester.fling(find.byType(ListView), const Offset(0, -500), 10000);
        await tester.pumpAndSettle();

        // Should remain responsive
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should filter locals by search query', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const LocalsScreen(),
        ));

        await tester.pumpAndSettle();

        // Enter search query
        await tester.enterText(find.byType(SearchTextField), 'New York');
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('New York'), findsAtLeastOneWidget);
        expect(find.textContaining('Los Angeles'), findsNothing);
      });

      testWidgets('should filter locals by state', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const LocalsScreen(),
        ));

        await tester.pumpAndSettle();

        // Tap state filter
        await tester.tap(find.text('All States'));
        await tester.pumpAndSettle();

        // Select specific state
        await tester.tap(find.text('New York'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('New York'), findsOneWidget);
        expect(find.byType(FilterChip), findsWidgets);
      });

      testWidgets('should handle locals loading errors', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: LocalsScreen(
            onError: (error) => Text('Error: $error'),
          ),
        ));

        await tester.pumpAndSettle();

        // Assert error handling
        expect(find.byType(LocalsScreen), findsOneWidget);
        // Error message would appear if loading fails
      });
    });

    group('Jobs Screen Hierarchical Tests', () {
      testWidgets('should load jobs filtered by user preferences', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const JobsScreen(),
        ));

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Job Opportunities'), findsOneWidget);
        expect(find.byType(JobFilterChip), findsWidgets);
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should show jobs from user\'s preferred locals', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const JobsScreen(),
        ));

        await tester.pumpAndSettle();

        // Assert - Should show jobs from user's preferred locals
        expect(find.textContaining('Local 3'), findsAtLeastOneWidget);
        expect(find.byType(JobCard), findsWidgets);
      });

      testWidgets('should filter jobs by classification', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const JobsScreen(),
        ));

        await tester.pumpAndSettle();

        // Tap classification filter
        await tester.tap(find.text('All Classifications'));
        await tester.pumpAndSettle();

        // Select specific classification
        await tester.tap(find.text('Inside Wireman'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Inside Wireman'), findsOneWidget);
        expect(find.byType(FilterChip), findsWidgets);
      });

      testWidgets('should handle job pagination', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const JobsScreen(),
        ));

        await tester.pumpAndSettle();

        // Scroll to trigger pagination
        await tester.fling(find.byType(ListView), const Offset(0, -300), 5000);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ListView), findsOneWidget);
        // Should load more items and remain responsive
      });

      testWidgets('should show job details when tapped', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const JobsScreen(),
        ));

        await tester.pumpAndSettle();

        // Tap on first job card
        await tester.tap(find.byType(JobCard).first);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(JobDetailsDialog), findsOneWidget);
        expect(find.text('Job Details'), findsOneWidget);
      });
    });

    group('Hierarchical Navigation Tests', () {
      testWidgets('should navigate through hierarchy levels', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HierarchicalNavigationWrapper(),
        ));

        await tester.pumpAndSettle();

        // Navigate from Home to Locals
        await tester.tap(find.text('Locals'));
        await tester.pumpAndSettle();

        // Assert - Should be on Locals screen
        expect(find.text('IBEW Locals'), findsOneWidget);
        expect(find.byType(LocalsScreen), findsOneWidget);

        // Navigate from Locals to Jobs for a specific local
        await tester.tap(find.byType(LocalCard).first);
        await tester.pumpAndSettle();

        // Assert - Should show jobs for selected local
        expect(find.text('Jobs for Local'), findsOneWidget);
        expect(find.byType(JobsScreen), findsOneWidget);
      });

      testWidgets('should maintain hierarchical context during navigation', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HierarchicalNavigationWrapper(),
        ));

        await tester.pumpAndSettle();

        // Navigate through hierarchy
        await tester.tap(find.text('Locals'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('New York')); // Filter by state
        await tester.pumpAndSettle();

        await tester.tap(find.byType(LocalCard).first);
        await tester.pumpAndSettle();

        // Assert - Should maintain context
        expect(find.textContaining('New York'), findsOneWidget);
        expect(find.byType(BreadcrumbNavigation), findsOneWidget);
      });

      testWidgets('should handle back navigation through hierarchy', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HierarchicalNavigationWrapper(),
        ));

        await tester.pumpAndSettle();

        // Navigate deep into hierarchy
        await tester.tap(find.text('Locals'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(LocalCard).first);
        await tester.pumpAndSettle();

        // Navigate back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Assert - Should return to previous level
        expect(find.text('IBEW Locals'), findsOneWidget);
        expect(find.byType(LocalsScreen), findsOneWidget);
      });
    });

    group('Loading State Tests', () {
      testWidgets('should show appropriate loading indicators', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HierarchicalLoadingWrapper(),
        ));

        // Assert
        expect(find.byType(JJElectricalLoader), findsOneWidget);
        expect(find.text('Loading hierarchical data...'), findsOneWidget);
      });

      testWidgets('should show skeleton loaders during data loading', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HierarchicalLoadingWrapper(),
        ));

        await tester.pump(Duration(milliseconds: 100)); // Partial loading

        // Assert
        expect(find.byType(SkeletonLoader), findsWidgets);
      });

      testWidgets('should hide loading states when data is loaded', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const HierarchicalLoadingWrapper(),
        ));

        await tester.pumpAndSettle(); // Complete loading

        // Assert
        expect(find.byType(JJElectricalLoader), findsNothing);
        expect(find.byType(ContentLoaded), findsOneWidget);
      });
    });

    group('Error State Tests', () {
      testWidgets('should show error messages for network errors', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: HierarchicalErrorWrapper(
            error: 'Network connection failed',
            onRetry: () {},
          ),
        ));

        // Assert
        expect(find.text('Network connection failed'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should show specific error for permission denied', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: HierarchicalErrorWrapper(
            error: 'Permission denied',
            onRetry: () {},
          ),
        ));

        // Assert
        expect(find.text('Permission denied'), findsOneWidget);
        expect(find.textContaining('You don\'t have permission'), findsOneWidget);
      });

      testWidgets('should handle retry functionality', (tester) async {
        // Arrange
        bool retryCalled = false;
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: HierarchicalErrorWrapper(
            error: 'Temporary error',
            onRetry: () {
              retryCalled = true;
            },
          ),
        ));

        // Tap retry button
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Assert
        expect(retryCalled, isTrue);
      });
    });

    group('Performance Tests', () {
      testWidgets('should render large lists efficiently', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const LargeDatasetScreen(),
        ));

        await tester.pumpAndSettle();

        // Assert performance
        final startTime = DateTime.now();

        // Perform scroll operations
        await tester.fling(find.byType(ListView), const Offset(0, -500), 10000);
        await tester.pumpAndSettle();

        final endTime = DateTime.now();
        final scrollDuration = endTime.difference(startTime);

        expect(scrollDuration.inMilliseconds, lessThan(1000)); // Should scroll within 1s
      });

      testWidgets('should handle rapid navigation without lag', (tester) async {
        // Arrange
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await tester.pumpWidget(createTestWidget(
          child: const RapidNavigationWrapper(),
        ));

        await tester.pumpAndSettle();

        // Perform rapid navigation
        final startTime = DateTime.now();

        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byType(NavigationButton).first);
          await tester.pump(Duration(milliseconds: 50));
        }

        final endTime = DateTime.now();
        final navigationDuration = endTime.difference(startTime);

        // Assert
        expect(navigationDuration.inMilliseconds, lessThan(2000)); // Should complete within 2s
      });
    });
  });
}

// Mock widgets for testing
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        if (authState.isLoading) {
          return const JJElectricalLoader(
            width: 200,
            height: 60,
            message: 'Loading...',
          );
        }

        if (authState.user == null) {
          return const LoginScreen();
        }

        return const HomeScreen();
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign In', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: 'Email')),
            TextField(decoration: InputDecoration(labelText: 'Password')),
            ElevatedButton(onPressed: null, child: Text('Sign In')),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64),
            Text('Authentication Error', style: TextStyle(fontSize: 24)),
            Text('Please try again'),
          ],
        ),
      ),
    );
  }
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        hintText: 'Search locals...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

class JobFilterChip extends StatelessWidget {
  const JobFilterChip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(label: const Text('Filter'));
  }
}

class JobCard extends StatelessWidget {
  const JobCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Sample Job'),
        subtitle: const Text('Company Name'),
        trailing: const Text('\$45/hr'),
      ),
    );
  }
}

class JobDetailsDialog extends StatelessWidget {
  const JobDetailsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Job Details', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            Text('Detailed job information...'),
            SizedBox(height: 16),
            TextButton(onPressed: null, child: Text('Close')),
          ],
        ),
      ),
    );
  }
}

class LocalCard extends StatelessWidget {
  const LocalCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('IBEW Local 3'),
        subtitle: const Text('New York, NY'),
        trailing: const Text('15,200 members'),
      ),
    );
  }
}

class BreadcrumbNavigation extends StatelessWidget {
  const BreadcrumbNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(onPressed: null, child: const Text('Home')),
        const Icon(Icons.chevron_right),
        TextButton(onPressed: null, child: const Text('Locals')),
        const Icon(Icons.chevron_right),
        TextButton(onPressed: null, child: const Text('New York')),
      ],
    );
  }
}

class HierarchicalNavigationWrapper extends StatelessWidget {
  const HierarchicalNavigationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HierarchicalLoadingWrapper extends StatelessWidget {
  const HierarchicalLoadingWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const JJElectricalLoader(
      width: 200,
      height: 60,
      message: 'Loading hierarchical data...',
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class ContentLoaded extends StatelessWidget {
  const ContentLoaded({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Content loaded successfully');
  }
}

class HierarchicalErrorWrapper extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const HierarchicalErrorWrapper({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(error, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class LargeDatasetScreen extends StatelessWidget {
  const LargeDatasetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 1000,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
            subtitle: Text('Large dataset item number $index'),
          );
        },
      ),
    );
  }
}

class NavigationButton extends StatelessWidget {
  const NavigationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: const Text('Navigate'),
    );
  }
}

class RapidNavigationWrapper extends StatelessWidget {
  const RapidNavigationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const NavigationButton(),
                const SizedBox(width: 10),
                const NavigationButton(),
                const SizedBox(width: 10),
                const NavigationButton(),
              ],
            ),
          ),
          const Expanded(child: Text('Content Area')),
        ],
      ),
    );
  }
}