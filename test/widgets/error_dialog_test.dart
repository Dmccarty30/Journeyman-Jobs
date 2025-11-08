import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../lib/widgets/error_dialog.dart';

void main() {
  group('ErrorDialog Widget Tests', () {
    testWidgets('displays basic error dialog', (WidgetTester tester) async {
      // Arrange
      final error = Exception('Test error message');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                    );
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('An Error Occurred'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('displays error with operation name', (WidgetTester tester) async {
      // Arrange
      final error = Exception('Test error');
      const operationName = 'Data Loading';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                      operationName: operationName,
                    );
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error in $operationName'), findsOneWidget);
    });

    testWidgets('displays network error correctly', (WidgetTester tester) async {
      // Arrange
      final error = SocketException('Network unreachable');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                    );
                  },
                  child: const Text('Show Network Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Network Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('displays permission error correctly', (WidgetTester tester) async {
      // Arrange
      final error = FirebaseAuthException(
        code: 'permission-denied',
        message: 'Access denied',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                    );
                  },
                  child: const Text('Show Permission Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Permission Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('shows retry button when provided', (WidgetTester tester) async {
      // Arrange
      var retryClicked = false;
      final error = Exception('Retryable error');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                      onRetry: () {
                        retryClicked = true;
                      },
                    );
                  },
                  child: const Text('Show Retryable Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Retryable Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Act - Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Assert
      expect(retryClicked, isTrue);
    });

    testWidgets('shows report button in debug mode', (WidgetTester tester) async {
      // Arrange
      var reportClicked = false;
      final error = Exception('Reportable error');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                      onReport: () {
                        reportClicked = true;
                      },
                    );
                  },
                  child: const Text('Show Reportable Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Reportable Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Report'), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);

      // Act - Tap report
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      // Assert
      expect(reportClicked, isTrue);
    });

    testWidgets('hides report button in release mode', (WidgetTester tester) async {
      // Arrange
      final error = Exception('Non-reportable error');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                      onReport: () {},
                      showStackTrace: false, // Simulate release mode
                    );
                  },
                  child: const Text('Show Non-reportable Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Non-reportable Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Report'), findsNothing);
      expect(find.text('Technical Details'), findsNothing);
    });

    testWidgets('shows technical details when expanded', (WidgetTester tester) async {
      // Arrange
      final error = Exception('Detailed error');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                      showStackTrace: true,
                      errorContext: {'key': 'value'},
                    );
                  },
                  child: const Text('Show Detailed Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Detailed Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Technical Details'), findsOneWidget);
      expect(find.text('Operation: Detailed error'), findsNothing);
      expect(find.text('Error Type: Exception'), findsOneWidget);
      expect(find.text('Context:'), findsOneWidget);
      expect(find.text('{key: value}'), findsOneWidget);

      // Act - Expand technical details
      await tester.tap(find.text('Technical Details'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Operation: Detailed error'), findsOneWidget);
    });

    testWidgets('displays validation error correctly', (WidgetTester tester) async {
      // Arrange
      final error = Exception('Validation failed');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                    );
                  },
                  child: const Text('Show Validation Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Validation Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays system error correctly', (WidgetTester tester) async {
      // Arrange
      final error = AssertionError('System assertion failed');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDialog.show(
                      context: context,
                      error: error,
                    );
                  },
                  child: const Text('Show System Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show System Error'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
    });

    testWidgets('ErrorSnackBar shows correctly', (WidgetTester tester) async {
      // Arrange
      const message = 'Test snackbar message';
      var actionClicked = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(
                      context: context,
                      message: message,
                      action: () {
                        actionClicked = true;
                      },
                    );
                  },
                  child: const Text('Show SnackBar'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show SnackBar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(message), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Fix'), findsOneWidget);

      // Act - Tap action
      await tester.tap(find.text('Fix'));
      await tester.pumpAndSettle();

      // Assert
      expect(actionClicked, isTrue);
    });

    testWidgets('ErrorSnackBar network error shows correctly', (WidgetTester tester) async {
      // Arrange
      var retryClicked = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.showNetworkError(
                      context: context,
                      onRetry: () {
                        retryClicked = true;
                      },
                    );
                  },
                  child: const Text('Show Network Error SnackBar'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Network Error SnackBar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Network error. Please check your connection.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Act - Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Assert
      expect(retryClicked, isTrue);
    });

    testWidgets('AsyncValueErrorHandler shows loading state', (WidgetTester tester) async {
      // Arrange
      final asyncValue = AsyncValue<void>.loading();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueErrorHandler<void>(
              asyncValue: asyncValue,
              builder: (data) => const Text('Loaded'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AsyncValueErrorHandler shows error state', (WidgetTester tester) async {
      // Arrange
      final error = Exception('Test error');
      final asyncValue = AsyncValue<void>.error(error, StackTrace.current);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueErrorHandler<void>(
              asyncValue: asyncValue,
              builder: (data) => const Text('Loaded'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Tap to see details'), findsOneWidget);
    });

    testWidgets('AsyncValueErrorHandler shows data state', (WidgetTester tester) async {
      // Arrange
      final asyncValue = AsyncValue<String>.data('Test data');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueErrorHandler<String>(
              asyncValue: asyncValue,
              builder: (data) => Text('Data: $data'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Data: Test data'), findsOneWidget);
    });

    testWidgets('AsyncValueErrorHandler uses custom error builder', (WidgetTester tester) async {
      // Arrange
      final error = Exception('Test error');
      final asyncValue = AsyncValue<void>.error(error, StackTrace.current);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueErrorHandler<void>(
              asyncValue: asyncValue,
              builder: (data) => const Text('Loaded'),
              errorBuilder: (error) {
                return Column(
                  children: [
                    const Icon(Icons.warning),
                    Text('Custom error: ${error.toString()}'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Custom error: Exception: Test error'), findsOneWidget);
    });

    testWidgets('AsyncValueErrorHandler uses custom loading builder', (WidgetTester tester) async {
      // Arrange
      final asyncValue = AsyncValue<void>.loading();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueErrorHandler<void>(
              asyncValue: asyncValue,
              builder: (data) => const Text('Loaded'),
              loadingBuilder: () {
                return const Column(
                  children: [
                    CircularProgressIndicator(),
                    Text('Custom loading...'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Custom loading...'), findsOneWidget);
    });
  });
}
