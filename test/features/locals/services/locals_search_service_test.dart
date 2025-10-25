import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/features/locals/services/locals_search_service.dart';
import 'package:journeyman_jobs/models/locals_record.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late LocalsSearchService searchService;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    searchService = LocalsSearchService(
      debounceDuration: 100, // Short for testing
      maxResults: 10,
      firestore: fakeFirestore,
    );

    // Add test data with lowercase fields
    await _addTestLocalsWithLowercase(fakeFirestore);
  });

  tearDown(() {
    searchService.dispose();
  });

  group('LocalsSearchService', () {
    test('debounces search queries', () async {
      final List<List<LocalsRecord>> results = [];

      // Make multiple rapid searches
      searchService.searchLocals('134', results.add);
      await Future.delayed(const Duration(milliseconds: 50));
      searchService.searchLocals('13', results.add);
      await Future.delayed(const Duration(milliseconds: 50));
      searchService.searchLocals('1', results.add);

      // Wait for debounce to complete
      await Future.delayed(const Duration(milliseconds: 200));

      // Only the last search should execute
      expect(results.length, 1);
    });

    test('searches by local number immediately', () async {
      final results = await searchService.searchImmediate('134');

      expect(results.isNotEmpty, true);
      expect(results.any((l) => l.localNumber == '134'), true);
    });

    test('searches by local number with prefix match', () async {
      final results = await searchService.searchImmediate('1');

      expect(results.length, greaterThan(1));
      // Should find 1, 11, 134
      expect(results.any((l) => l.localNumber.startsWith('1')), true);
    });

    test('searches by local name (case-insensitive)', () async {
      final results = await searchService.searchImmediate('chicago');

      expect(results.isNotEmpty, true);
      expect(
        results.any((l) => l.localName.toLowerCase().contains('chicago')),
        true,
      );
    });

    test('searches by city (case-insensitive)', () async {
      final results = await searchService.searchImmediate('los');

      expect(results.isNotEmpty, true);
      expect(
        results.any((l) => l.city.toLowerCase().startsWith('los')),
        true,
      );
    });

    test('filters by state correctly', () async {
      final results = await searchService.searchImmediate(
        '1',
        stateFilter: 'CA',
      );

      expect(results.isNotEmpty, true);
      for (final local in results) {
        expect(local.state, 'CA');
      }
    });

    test('returns empty list for empty query', () async {
      final results = await searchService.searchImmediate('');

      expect(results.isEmpty, true);
    });

    test('deduplicates results from multiple search queries', () async {
      // Search for '1' which might match local_union and local_name
      final results = await searchService.searchImmediate('1');

      // Extract IDs and check for uniqueness
      final ids = results.map((l) => l.id).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, uniqueIds.length); // No duplicates
    });

    test('sorts exact matches first', () async {
      final results = await searchService.searchImmediate('134');

      // Exact match should be first
      expect(results.first.localNumber, '134');
    });

    test('sorts prefix matches before partial matches', () async {
      final results = await searchService.searchImmediate('1');

      // Results starting with '1' should come before those containing '1'
      final firstResult = results.first.localNumber;
      expect(firstResult.startsWith('1'), true);
    });

    test('respects maxResults limit', () async {
      // Create service with small limit
      final limitedService = LocalsSearchService(
        maxResults: 2,
        firestore: fakeFirestore,
      );

      final results = await limitedService.searchImmediate('1');

      expect(results.length, lessThanOrEqualTo(2));
    });

    test('handles no results gracefully', () async {
      final results = await searchService.searchImmediate('99999');

      expect(results.isEmpty, true);
    });

    test('cancelPendingSearch cancels debounced search', () async {
      final List<List<LocalsRecord>> results = [];

      searchService.searchLocals('134', results.add);

      // Cancel before debounce completes
      await Future.delayed(const Duration(milliseconds: 50));
      searchService.cancelPendingSearch();

      // Wait for original debounce duration
      await Future.delayed(const Duration(milliseconds: 150));

      // Search should have been cancelled
      expect(results.isEmpty, true);
    });

    test('dispose cancels pending searches', () async {
      final List<List<LocalsRecord>> results = [];

      searchService.searchLocals('134', results.add);

      // Dispose before debounce completes
      await Future.delayed(const Duration(milliseconds: 50));
      searchService.dispose();

      // Wait for original debounce duration
      await Future.delayed(const Duration(milliseconds: 150));

      // Search should have been cancelled
      expect(results.isEmpty, true);
    });

    test('searches work after reset', () async {
      // First search
      await searchService.searchImmediate('134');

      // Dispose and recreate
      searchService.dispose();

      // New service
      final newService = LocalsSearchService(firestore: fakeFirestore);
      final results = await newService.searchImmediate('134');

      expect(results.isNotEmpty, true);

      newService.dispose();
    });
  });
}

/// Helper function to add test locals with lowercase fields
Future<void> _addTestLocalsWithLowercase(FakeFirebaseFirestore firestore) async {
  final testLocals = [
    {
      'local_union': '1',
      'local_name': 'St. Louis Electrical Workers',
      'local_name_lowercase': 'st. louis electrical workers',
      'city': 'St. Louis',
      'city_lowercase': 'st. louis',
      'state': 'MO',
      'email': 'info@ibewlocal1.org',
      'phone': '(314) 555-0001',
      'classification': 'Inside Wireman',
      'memberCount': 3500,
      'specialties': ['Commercial', 'Industrial'],
      'isActive': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    {
      'local_union': '11',
      'local_name': 'Los Angeles Electrical Workers',
      'local_name_lowercase': 'los angeles electrical workers',
      'city': 'Los Angeles',
      'city_lowercase': 'los angeles',
      'state': 'CA',
      'address': '297 N Marengo Ave, Pasadena, CA 91101',
      'email': 'contact@local11.org',
      'phone': '(213) 555-0011',
      'website': 'https://www.ibew11.org',
      'classification': 'Inside Wireman',
      'memberCount': 9800,
      'specialties': ['Commercial', 'Solar', 'Industrial'],
      'isActive': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    {
      'local_union': '134',
      'local_name': 'Chicago Electrical Workers',
      'local_name_lowercase': 'chicago electrical workers',
      'city': 'Chicago',
      'city_lowercase': 'chicago',
      'state': 'IL',
      'address': '600 W Washington Blvd, Chicago, IL 60661',
      'email': 'contact@local134.org',
      'phone': '(312) 555-0134',
      'website': 'https://www.local134.org',
      'classification': 'Inside Wireman',
      'memberCount': 12500,
      'specialties': ['Commercial', 'Industrial', 'Residential'],
      'isActive': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    {
      'local_union': '340',
      'local_name': 'Sacramento Electrical Workers',
      'local_name_lowercase': 'sacramento electrical workers',
      'city': 'Sacramento',
      'city_lowercase': 'sacramento',
      'state': 'CA',
      'email': 'info@ibew340.org',
      'phone': '(916) 555-0340',
      'classification': 'Lineman',
      'memberCount': 2800,
      'specialties': ['Utility', 'Transmission'],
      'isActive': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
  ];

  for (final local in testLocals) {
    await firestore.collection('locals').add(local);
  }
}
