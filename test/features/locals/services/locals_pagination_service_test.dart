import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/features/locals/services/locals_pagination_service.dart';
import 'package:journeyman_jobs/models/locals_record.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late LocalsPaginationService paginationService;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    paginationService = LocalsPaginationService(
      pageSize: 2, // Small page size for testing
      firestore: fakeFirestore,
    );

    // Add test data
    await _addTestLocals(fakeFirestore);
  });

  group('LocalsPaginationService', () {
    test('loads first page successfully', () async {
      final locals = await paginationService.loadNextPage();

      expect(locals.length, 2);
      expect(paginationService.hasMore, true);
      expect(locals[0].localNumber, '1');
      expect(locals[1].localNumber, '11');
    });

    test('loads multiple pages sequentially', () async {
      // Load first page
      final page1 = await paginationService.loadNextPage();
      expect(page1.length, 2);
      expect(paginationService.hasMore, true);

      // Load second page
      final page2 = await paginationService.loadNextPage();
      expect(page2.length, 2);
      expect(paginationService.hasMore, true);

      // Load third page (only 1 item left)
      final page3 = await paginationService.loadNextPage();
      expect(page3.length, 1);
      expect(paginationService.hasMore, false);

      // Verify no duplicates across pages
      final allLocalNumbers = [
        ...page1.map((l) => l.localNumber),
        ...page2.map((l) => l.localNumber),
        ...page3.map((l) => l.localNumber),
      ];
      expect(allLocalNumbers.toSet().length, 5); // All unique
    });

    test('returns empty list when no more data', () async {
      // Load all pages
      await paginationService.loadNextPage();
      await paginationService.loadNextPage();
      await paginationService.loadNextPage();

      // Try to load beyond end
      final emptyPage = await paginationService.loadNextPage();

      expect(emptyPage.isEmpty, true);
      expect(paginationService.hasMore, false);
    });

    test('filters by state correctly', () async {
      final caLocals = await paginationService.loadNextPage(stateFilter: 'CA');

      expect(caLocals.length, 2);
      for (final local in caLocals) {
        expect(local.state, 'CA');
      }
    });

    test('filters by classification correctly', () async {
      final wiremen = await paginationService.loadNextPage(
        classificationFilter: 'Inside Wireman',
      );

      expect(wiremen.isNotEmpty, true);
      for (final local in wiremen) {
        expect(local.classification, 'Inside Wireman');
      }
    });

    test('resets pagination when filters change', () async {
      // Load first page without filter
      final page1 = await paginationService.loadNextPage();
      expect(page1.length, 2);

      // Load with state filter - should reset and start over
      final caPage1 = await paginationService.loadNextPage(stateFilter: 'CA');
      expect(caPage1.length, 2);
      expect(caPage1[0].state, 'CA');
    });

    test('reset() clears pagination state', () async {
      // Load some pages
      await paginationService.loadNextPage();
      await paginationService.loadNextPage();

      // Reset
      paginationService.reset();

      expect(paginationService.hasMore, true);
      expect(paginationService.lastDocument, null);

      // Should load first page again
      final page = await paginationService.loadNextPage();
      expect(page[0].localNumber, '1');
    });

    test('refresh() reloads first page', () async {
      // Load some pages
      await paginationService.loadNextPage();
      await paginationService.loadNextPage();

      // Refresh
      final refreshedPage = await paginationService.refresh();

      expect(refreshedPage[0].localNumber, '1');
      expect(paginationService.hasMore, true);
    });

    test('handles empty collection gracefully', () async {
      // Clear all data
      final snapshot = await fakeFirestore.collection('locals').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      final locals = await paginationService.loadNextPage();

      expect(locals.isEmpty, true);
      expect(paginationService.hasMore, false);
    });

    test('maintains order by local_union', () async {
      final page = await paginationService.loadNextPage();

      // Check that local numbers are in order
      expect(page[0].localNumber, '1');
      expect(page[1].localNumber, '11');
    });
  });
}

/// Helper function to add test locals to Firestore
Future<void> _addTestLocals(FakeFirebaseFirestore firestore) async {
  final testLocals = [
    {
      'local_union': '1',
      'local_name': 'St. Louis Electrical Workers',
      'city': 'St. Louis',
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
      'city': 'Los Angeles',
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
      'local_union': '98',
      'local_name': 'Philadelphia Electrical Workers',
      'city': 'Philadelphia',
      'state': 'PA',
      'email': 'info@ibew98.org',
      'phone': '(215) 555-0098',
      'classification': 'Inside Wireman',
      'memberCount': 4500,
      'specialties': ['Commercial', 'Residential'],
      'isActive': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    {
      'local_union': '134',
      'local_name': 'Chicago Electrical Workers',
      'city': 'Chicago',
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
      'city': 'Sacramento',
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
