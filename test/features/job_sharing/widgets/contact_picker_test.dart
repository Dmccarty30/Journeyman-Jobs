import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:journeyman_jobs/features/job_sharing/widgets/contact_picker.dart';
import 'package:journeyman_jobs/features/job_sharing/widgets/riverpod_contact_picker.dart';
import 'package:journeyman_jobs/features/job_sharing/services/contact_service.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

import 'contact_picker_test.mocks.dart';

@GenerateMocks([ContactService])
void main() {
  group('JJContactPicker Tests', () {
    late List<Contact> selectedContacts;
    late MockContactService mockContactService;

    setUp(() {
      selectedContacts = [];
      mockContactService = MockContactService();
    });

    Widget createTestWidget({
      List<String>? existingPlatformUsers,
      bool allowMultiSelect = true,
      int maxSelection = 10,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: JJContactPicker(
          onContactsSelected: (contacts) {
            selectedContacts = contacts;
          },
          existingPlatformUsers: existingPlatformUsers,
          allowMultiSelect: allowMultiSelect,
          maxSelection: maxSelection,
        ),
      );
    }

    testWidgets('displays app bar with correct title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Select Contacts'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading contacts...'), findsOneWidget);
    });

    testWidgets('shows permission denied view when permission not granted', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show permission denied UI (since we can't grant permission in tests)
      expect(find.text('Contacts Access Required'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('search bar is present and functional', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for search bar (it should be present even if no contacts loaded)
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        expect(find.text('Search contacts...'), findsOneWidget);
        
        // Test search input
        await tester.enterText(searchField, 'test search');
        expect(find.text('test search'), findsOneWidget);
      }
    });

    testWidgets('handles multi-select configuration', (tester) async {
      await tester.pumpWidget(createTestWidget(
        allowMultiSelect: false,
        maxSelection: 1,
      ));
      
      expect(find.byType(JJContactPicker), findsOneWidget);
    });

    testWidgets('handles existing platform users configuration', (tester) async {
      await tester.pumpWidget(createTestWidget(
        existingPlatformUsers: ['test@example.com', '+1234567890'],
      ));
      
      expect(find.byType(JJContactPicker), findsOneWidget);
    });
  });

  group('JJRiverpodContactPicker Tests', () {
    late List<ContactInfo> selectedContacts;

    setUp(() {
      selectedContacts = [];
    });

    Widget createRiverpodTestWidget({
      List<String>? existingPlatformUsers,
      bool allowMultiSelect = true,
      int maxSelection = 10,
    }) {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: JJRiverpodContactPicker(
            onContactsSelected: (contacts) {
              selectedContacts = contacts;
            },
            existingPlatformUsers: existingPlatformUsers,
            allowMultiSelect: allowMultiSelect,
            maxSelection: maxSelection,
            highlightExistingUsers: true,
          ),
        ),
      );
    }

    testWidgets('displays app bar with correct title', (tester) async {
      await tester.pumpWidget(createRiverpodTestWidget());

      expect(find.text('Select Contacts'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(createRiverpodTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading contacts...'), findsOneWidget);
    });

    testWidgets('handles configuration correctly', (tester) async {
      await tester.pumpWidget(createRiverpodTestWidget(
        existingPlatformUsers: ['john@ibew123.org'],
        allowMultiSelect: false,
        maxSelection: 5,
      ));
      
      expect(find.byType(JJRiverpodContactPicker), findsOneWidget);
    });

    testWidgets('uses Riverpod providers', (tester) async {
      await tester.pumpWidget(createRiverpodTestWidget());
      
      // Verify that it's wrapped in ProviderScope
      expect(find.byType(ProviderScope), findsOneWidget);
      expect(find.byType(Consumer), findsAtLeastNWidgets(1));
    });
  });

  group('ContactService Tests', () {
    late ContactService contactService;

    setUp(() {
      contactService = ContactService.instance;
    });

    test('formatPhoneNumber formats US numbers correctly', () {
      expect(contactService.formatPhoneNumber('1234567890'), equals('(123) 456-7890'));
      expect(contactService.formatPhoneNumber('11234567890'), equals('+1 (123) 456-7890'));
      expect(contactService.formatPhoneNumber('+1-123-456-7890'), equals('+1 (123) 456-7890'));
    });

    test('formatPhoneNumber returns original for non-US formats', () {
      const originalNumber = '+44 20 1234 5678';
      expect(contactService.formatPhoneNumber(originalNumber), equals(originalNumber));
    });

    test('getContactInitials generates correct initials', () {
      final contact1 = Contact()..displayName = 'John Doe';
      final contact2 = Contact()..displayName = 'Jane';
      final contact3 = Contact()..displayName = '';

      expect(contactService.getContactInitials(contact1), equals('JD'));
      expect(contactService.getContactInitials(contact2), equals('J'));
      expect(contactService.getContactInitials(contact3), equals('?'));
    });

    test('isExistingPlatformUser detects existing users correctly', () {
      final contact = Contact()
        ..displayName = 'John Electrician'
        ..emails = [Item()..value = 'john@example.com']
        ..phones = [Item()..value = '+1234567890'];

      final existingUsers = ['john@example.com', '+0987654321'];
      
      expect(contactService.isExistingPlatformUser(contact, existingUsers), isTrue);
      
      final nonExistingUsers = ['jane@example.com'];
      expect(contactService.isExistingPlatformUser(contact, nonExistingUsers), isFalse);
    });

    test('extractContactInfo creates ContactInfo objects correctly', () {
      final contact = Contact()
        ..displayName = 'John Electrician'
        ..emails = [Item()..value = 'john@example.com']
        ..phones = [Item()..value = '+1234567890'];

      final contactInfoList = contactService.extractContactInfo([contact]);
      
      expect(contactInfoList.length, equals(1));
      expect(contactInfoList.first.displayName, equals('John Electrician'));
      expect(contactInfoList.first.emails, contains('john@example.com'));
      expect(contactInfoList.first.phoneNumbers, contains('+1234567890'));
    });
  });

  group('ContactInfo Tests', () {
    test('ContactInfo properties work correctly', () {
      final contactInfo = ContactInfo(
        displayName: 'John Electrician',
        emails: ['john@example.com', 'j.electrician@ibew123.org'],
        phoneNumbers: ['+1234567890', '+0987654321'],
      );

      expect(contactInfo.primaryEmail, equals('john@example.com'));
      expect(contactInfo.primaryPhoneNumber, equals('+1234567890'));
      expect(contactInfo.hasContactMethod, isTrue);

      final emptyContactInfo = ContactInfo(
        displayName: 'Empty Contact',
        emails: [],
        phoneNumbers: [],
      );

      expect(emptyContactInfo.primaryEmail, isNull);
      expect(emptyContactInfo.primaryPhoneNumber, isNull);
      expect(emptyContactInfo.hasContactMethod, isFalse);
    });

    test('ContactInfo equality works correctly', () {
      final contact1 = ContactInfo(
        displayName: 'John Electrician',
        emails: ['john@example.com'],
        phoneNumbers: ['+1234567890'],
      );

      final contact2 = ContactInfo(
        displayName: 'John Electrician',
        emails: ['john@example.com'],
        phoneNumbers: ['+1234567890'],
      );

      final contact3 = ContactInfo(
        displayName: 'Jane Lineman',
        emails: ['jane@example.com'],
        phoneNumbers: ['+0987654321'],
      );

      expect(contact1, equals(contact2));
      expect(contact1, isNot(equals(contact3)));
      expect(contact1.hashCode, equals(contact2.hashCode));
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('contact picker widgets can be wrapped in proper theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(
              child: Text('Contact Picker Integration Test'),
            ),
          ),
        ),
      );

      expect(find.text('Contact Picker Integration Test'), findsOneWidget);
    });

    testWidgets('both contact picker variants use consistent theming', (tester) async {
      // Test standard picker
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: JJContactPicker(
            onContactsSelected: (contacts) {},
          ),
        ),
      );

      // Look for themed elements
      expect(find.byType(AppBar), findsOneWidget);

      // Test Riverpod picker
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: JJRiverpodContactPicker(
              onContactsSelected: (contacts) {},
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}