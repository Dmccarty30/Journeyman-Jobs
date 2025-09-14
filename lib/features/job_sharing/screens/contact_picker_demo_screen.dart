import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/app_theme.dart';
import '../widgets/contact_picker.dart';
import '../widgets/riverpod_contact_picker.dart';
import '../services/contact_service.dart';

/// Demo screen showcasing the contact picker functionality
class ContactPickerDemoScreen extends ConsumerStatefulWidget {
  const ContactPickerDemoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContactPickerDemoScreen> createState() => _ContactPickerDemoScreenState();
}

class _ContactPickerDemoScreenState extends ConsumerState<ContactPickerDemoScreen> {
  List<ContactInfo> _selectedContacts = [];
  final List<String> _mockExistingUsers = [
    'john.electrician@ibew123.org',
    'sarah.lineman@ibew456.org',
    '+15551234567',
    '+15559876543',
  ];

  /// Show the standard contact picker
  Future<void> _showStandardContactPicker() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JJContactPicker(
          onContactsSelected: (contacts) {
            // This gets called as contacts are selected
          },
          existingPlatformUsers: _mockExistingUsers,
          allowMultiSelect: true,
          maxSelection: 5,
        ),
      ),
    );
    
    if (result != null && result is List) {
      // Convert Contact objects to ContactInfo
      final contactService = ContactService.instance;
      final contactInfos = contactService.extractContactInfo(result);
      setState(() {
        _selectedContacts = contactInfos;
      });
    }
  }

  /// Show the Riverpod-powered contact picker
  Future<void> _showRiverpodContactPicker() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JJRiverpodContactPicker(
          onContactsSelected: (contacts) {
            // This gets called as contacts are selected
          },
          existingPlatformUsers: _mockExistingUsers,
          allowMultiSelect: true,
          maxSelection: 8,
          highlightExistingUsers: true,
        ),
      ),
    );
    
    if (result != null && result is List<ContactInfo>) {
      setState(() {
        _selectedContacts = result;
      });
    }
  }

  /// Build selected contacts list
  Widget _buildSelectedContactsList() {
    if (_selectedContacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          children: [
            Icon(
              Icons.contact_phone_outlined,
              size: AppTheme.iconXxl,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No contacts selected',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Use one of the buttons above to select contacts',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Contacts (${_selectedContacts.length})',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedContacts.clear();
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedContacts.length,
            itemBuilder: (context, index) {
              final contact = _selectedContacts[index];
              return _buildContactInfoCard(contact);
            },
          ),
        ),
      ],
    );
  }

  /// Build contact info card
  Widget _buildContactInfoCard(ContactInfo contact) {
    final isExistingUser = _mockExistingUsers.any((user) {
      return contact.emails.contains(user.toLowerCase()) ||
          contact.phoneNumbers.any((phone) => 
              phone.replaceAll(RegExp(r'\D'), '').endsWith(user.replaceAll(RegExp(r'\D'), '')));
    });

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExistingUser ? AppTheme.successGreen : AppTheme.accentCopper,
          child: Text(
            _getInitials(contact.displayName),
            style: AppTheme.titleSmall.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.displayName,
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (isExistingUser)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  'IBEW',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.emails.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingXs),
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: AppTheme.iconSm,
                    color: AppTheme.mediumGray,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: Text(
                      contact.emails.first,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (contact.phoneNumbers.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingXs),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: AppTheme.iconSm,
                    color: AppTheme.mediumGray,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: Text(
                      ContactService.instance.formatPhoneNumber(contact.phoneNumbers.first),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.close,
            color: AppTheme.mediumGray,
            size: AppTheme.iconSm,
          ),
          onPressed: () {
            setState(() {
              _selectedContacts.remove(contact);
            });
          },
        ),
      ),
    );
  }

  /// Generate initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words.first[0].toUpperCase()}${words.last[0].toUpperCase()}';
    } else if (words.isNotEmpty) {
      return words.first[0].toUpperCase();
    }
    
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Picker Demo'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
      ),
      body: Column(
        children: [
          // Demo buttons
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Contact Picker Demo',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Test the contact picker implementation for job sharing. The picker will request contacts permission and show available contacts with highlighting for existing IBEW platform users.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingLg),
                ElevatedButton.icon(
                  onPressed: _showStandardContactPicker,
                  icon: const Icon(Icons.contacts),
                  label: const Text('Standard Contact Picker'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMd,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                ElevatedButton.icon(
                  onPressed: _showRiverpodContactPicker,
                  icon: const Icon(Icons.contact_phone),
                  label: const Text('Riverpod Contact Picker'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMd,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Selected contacts display
          Expanded(
            child: _buildSelectedContactsList(),
          ),
        ],
      ),
    );
  }
}