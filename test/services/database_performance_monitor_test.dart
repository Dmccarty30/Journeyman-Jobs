import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import '../../lib/services/database_performance_monitor.dart';

void main() {
  group('DatabasePerformanceMonitor', () {
    late DatabasePerformanceMonitor monitor;

    setUp(() {
      monitor = DatabasePerformanceMonitor();
    });

    tearDown(() {
      monitor.dispose();
    });

    group('Query Monitoring', () {
      test('should track query start and completion', () async {
        // Arrange
        final queryMonitor = monitor.startQuery(
          queryName: 'testQuery',
          operation: 'get',
          parameters: {'limit': 20},
          collection: 'testCollection',
        );

        // Act
        final mockDocs = [
          MockQueryDocumentSnapshot(),
          MockQueryDocumentSnapshot(),
        ];
        queryMonitor.complete(mockDocs);

        // Assert
        final summary = monitor.getPerformanceSummary();
        expect(summary.totalQueries, equals(1));
        expect(summary.averageDuration.inMilliseconds, greaterThan(0));
      });

      test('should track query errors', () async {
        // Arrange
        final queryMonitor = monitor.startQuery(
          queryName: 'testQuery',
          operation: 'get',
          parameters: {'limit': 20},
          collection: 'testCollection',
        );

        // Act
        queryMonitor.error('Test error message');

        // Assert
        final summary = monitor.getPerformanceSummary();
        expect(summary.totalQueries, equals(1));
        expect(summary.errorRate, equals(1.0)); // 100% error rate
      });

      test('should create performance alerts for slow queries', () async {
        // Arrange
        final alertStream = monitoralerts.take(1);
        final queryMonitor = monitor.startQuery(
          queryName: 'slowQuery',
          operation: 'get',
          parameters: {'limit': 100},
          collection: 'testCollection',
        );

        // Act - Simulate slow query completion
        await Future.delayed(Duration(milliseconds: 1100)); // > slow threshold
        queryMonitor.complete([]);

        // Assert
        final alert = await alertStream.first;
        expect(alert.type, equals(AlertType.info));
        expect(alert.queryName, equals('slowQuery'));
        expect(alert.message, contains('1100ms'));
      });

      test('should create critical alerts for very slow queries', () async {
        // Arrange
        final alertStream = monitoralerts.take(1);
        final queryMonitor = monitor.startQuery(
          queryName: 'verySlowQuery',
          operation: 'get',
          parameters: {'limit': 500},
          collection: 'testCollection',
        );

        // Act - Simulate very slow query completion
        await Future.delayed(Duration(milliseconds: 3100)); // > critical threshold
        queryMonitor.complete([]);

        // Assert
        final alert = await alertStream.first;
        expect(alert.type, equals(AlertType.critical));
        expect(alert.queryName, equals('verySlowQuery'));
        expect(alert.message, contains('3100ms'));
        expect(alert.recommendation, isNotNull);
      });
    });

    group('Performance Summary', () {
      test('should calculate correct performance metrics', () async {
        // Arrange & Act - Create multiple queries with different performance
        for (int i = 0; i < 5; i++) {
          final queryMonitor = monitor.startQuery(
            queryName: 'query$i',
            operation: 'get',
            parameters: {'test': i},
            collection: 'testCollection',
          );

          // Simulate varying durations
          final delay = Duration(milliseconds: 100 + (i * 50));
          await Future.delayed(delay);
          queryMonitor.complete([]);
        }

        // Assert
        final summary = monitor.getPerformanceSummary();
        expect(summary.totalQueries, equals(5));
        expect(summary.averageDuration.inMilliseconds, greaterThan(0));
        expect(summary.errorRate, equals(0.0)); // All successful
      });

      test('should handle empty query history', () {
        // Act
        final summary = monitor.getPerformanceSummary();

        // Assert
        expect(summary.totalQueries, equals(0));
        expect(summary.averageDuration.inMilliseconds, equals(0));
        expect(summary.errorRate, equals(0.0));
        expect(summary.slowestQuery, isNull);
        expect(summary.fastestQuery, isNull);
      });

      test('should calculate error rate correctly', () async {
        // Arrange & Act - Mix of successful and failed queries
        for (int i = 0; i < 4; i++) {
          final queryMonitor = monitor.startQuery(
            queryName: 'query$i',
            operation: 'get',
            parameters: {},
            collection: 'testCollection',
          );

          if (i % 2 == 0) {
            await Future.delayed(Duration(milliseconds: 100));
            queryMonitor.complete([]);
          } else {
            queryMonitor.error('Test error $i');
          }
        }

        // Assert
        final summary = monitor.getPerformanceSummary();
        expect(summary.totalQueries, equals(4));
        expect(summary.errorRate, equals(0.5)); // 50% error rate
      });
    });

    group('Query Metrics Retrieval', () {
      test('should retrieve metrics for specific query name', () async {
        // Arrange
        final queryName = 'repeatedQuery';
        for (int i = 0; i < 3; i++) {
          final queryMonitor = monitor.startQuery(
            queryName: queryName,
            operation: 'get',
            parameters: {},
            collection: 'testCollection',
          );
          await Future.delayed(Duration(milliseconds: 100));
          queryMonitor.complete([]);
        }

        // Act
        final metrics = monitor.getQueryMetrics(queryName);

        // Assert
        expect(metrics.length, equals(3));
        expect(metrics.first.queryName, equals(queryName));
        expect(metrics.first.success, isTrue);
      });

      test('should return empty list for unknown query name', () {
        // Act
        final metrics = monitor.getQueryMetrics('unknownQuery');

        // Assert
        expect(metrics, isEmpty);
      });
    });

    group('Alert Management', () {
      test('should retrieve recent alerts with filtering', () async {
        // Arrange - Generate alerts of different types
        final queryMonitor1 = monitor.startQuery(
          queryName: 'infoQuery',
          operation: 'get',
          parameters: {},
          collection: 'testCollection',
        );

        final queryMonitor2 = monitor.startQuery(
          queryName: 'warningQuery',
          operation: 'get',
          parameters: {},
          collection: 'testCollection',
        );

        final queryMonitor3 = monitor.startQuery(
          queryName: 'criticalQuery',
          operation: 'get',
          parameters: {},
          collection: 'testCollection',
        );

        // Generate alerts with different severities
        await Future.delayed(Duration(milliseconds: 1100));
        queryMonitor1.complete([]); // Info alert

        await Future.delayed(Duration(milliseconds: 3100));
        queryMonitor2.complete([]); // Critical alert

        await Future.delayed(Duration(milliseconds: 5100));
        queryMonitor3.complete([]); // Critical alert

        // Act
        final allAlerts = monitor.getRecentAlerts();
        final criticalAlerts = monitor.getRecentAlerts(type: AlertType.critical);
        final infoAlerts = monitor.getRecentAlerts(type: AlertType.info);

        // Assert
        expect(allAlerts.length, equals(3));
        expect(criticalAlerts.length, equals(2));
        expect(infoAlerts.length, equals(1));
      });

      test('should limit number of alerts returned', () async {
        // Arrange - Generate more alerts than limit
        for (int i = 0; i < 15; i++) {
          final queryMonitor = monitor.startQuery(
            queryName: 'query$i',
            operation: 'get',
            parameters: {},
            collection: 'testCollection',
          );
          await Future.delayed(Duration(milliseconds: 1100));
          queryMonitor.complete([]); // Generate info alerts
        }

        // Act
        final limitedAlerts = monitor.getRecentAlerts(limit: 5);

        // Assert
        expect(limitedAlerts.length, equals(5));
      });

      test('should filter alerts by time range', () async {
        // Arrange - Generate alerts
        for (int i = 0; i < 3; i++) {
          final queryMonitor = monitor.startQuery(
            queryName: 'query$i',
            operation: 'get',
            parameters: {},
            collection: 'testCollection',
          );
          await Future.delayed(Duration(milliseconds: 1100));
          queryMonitor.complete([]);
        }

        // Act
        final recentAlerts = monitor.getRecentAlerts(
          since: Duration(minutes: 1),
        );

        // Assert
        expect(recentAlerts.length, equals(3));
        expect(recentAlerts.every((alert) =>
          alert.timestamp.isAfter(DateTime.now().subtract(Duration(minutes: 1)))), isTrue);
      });
    });

    group('Memory Management', () {
      test('should clean up old metrics automatically', () async {
        // This test would require generating many queries to trigger cleanup
        // For now, we'll verify the cleanup method exists

        // Act
        monitor.clearData();

        // Assert
        final summary = monitor.getPerformanceSummary();
        expect(summary.totalQueries, equals(0));
        expect(summary.recentAlerts, isEmpty);
      });

      test('should dispose resources properly', () {
        // Act
        monitor.dispose();

        // Assert - No exceptions should be thrown
        expect(() => monitor.getPerformanceSummary(), throwsA(anything));
      });
    });

    group('Stream Management', () {
      test('should provide alert stream for real-time monitoring', () async {
        // Arrange
        final alertStream = monitoralerts.take(1);
        final queryMonitor = monitor.startQuery(
          queryName: 'streamTest',
          operation: 'get',
          parameters: {},
          collection: 'testCollection',
        );

        // Act
        await Future.delayed(Duration(milliseconds: 1100));
        queryMonitor.complete([]);

        // Assert
        final alert = await alertStream.first;
        expect(alert, isA<PerformanceAlert>());
        expect(alert.queryName, equals('streamTest'));
      });
    });
  });
}

// Mock classes for testing
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}