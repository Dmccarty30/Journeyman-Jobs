import 'dart:developer' as dev;

import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service class for handling contact-related operations
class ContactService {
  static ContactService? _instance;
  static ContactService get instance => _instance ??= ContactService._();
  ContactService._();

  /// Check if contacts permission is granted
  Future<bool> hasContactsPermission() async {
    try {
      final status = await Permission.contacts.status;
      return status.isGranted;
    } catch (e) {
      dev.log('Error checking contacts permission: $e', name: 'ContactService');
      return false;
    }
  }

  /// Request contacts permission
  Future<ContactPermissionResult> requestContactsPermission() async {
    try {
      final status = await Permission.contacts.status;
      
      if (status.isGranted) {
        return ContactPermissionResult.granted;
      } else if (status.isPermanentlyDenied) {
        return ContactPermissionResult.permanentlyDenied;
      } else if (status.isDenied) {
        final requestResult = await Permission.contacts.request();
        
        if (requestResult.isGranted) {
          return ContactPermissionResult.granted;
        } else if (requestResult.isPermanentlyDenied) {
          return ContactPermissionResult.permanentlyDenied;
        } else {
          return ContactPermissionResult.denied;
        }
      }
      
      return ContactPermissionResult.denied;
    } catch (e) {
      dev.log('Error requesting contacts permission: $e', name: 'ContactService');
      return ContactPermissionResult.error;
    }
  }

  /// Load contacts from device with optional filtering
  Future<ContactLoadResult> loadContacts({
    bool requireEmailOrPhone = true,
    bool withThumbnails = false,
    bool photoHighResolution = false,
    String? searchQuery,
  }) async {
    try {
      // Check permission first
      final hasPermission = await hasContactsPermission();
      if (!hasPermission) {
        return ContactLoadResult.error('Contacts permission not granted');
      }

      // Load contacts
      final contacts = await ContactsService.getContacts(
        withThumbnails: withThumbnails,
        photoHighResolution: photoHighResolution,
      );

      List<Contact> processedContacts = contacts;

      // Filter contacts that have email or phone if required
      if (requireEmailOrPhone) {
        processedContacts = contacts.where((contact) {
          final hasEmail = contact.emails?.isNotEmpty == true;
          final hasPhone = contact.phones?.isNotEmpty == true;
          final hasName = contact.displayName?.isNotEmpty == true;
          return (hasEmail || hasPhone) && hasName;
        }).toList();
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        processedContacts = processedContacts.where((contact) {
          final name = contact.displayName?.toLowerCase() ?? '';
          final emails = contact.emails?.map((e) => e.value?.toLowerCase() ?? '').join(' ') ?? '';
          final phones = contact.phones?.map((p) => p.value?.toLowerCase() ?? '').join(' ') ?? '';
          final searchLower = searchQuery.toLowerCase();
          
          return name.contains(searchLower) || 
                 emails.contains(searchLower) || 
                 phones.contains(searchLower);
        }).toList();
      }

      // Sort alphabetically by display name
      processedContacts.sort((a, b) {
        final nameA = a.displayName ?? '';
        final nameB = b.displayName ?? '';
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      });

      return ContactLoadResult.success(processedContacts);
    } catch (e) {
      dev.log('Error loading contacts: $e', name: 'ContactService');
      return ContactLoadResult.error('Failed to load contacts: $e');
    }
  }

  /// Check if a contact is an existing platform user
  bool isExistingPlatformUser(Contact contact, List<String> existingUsers) {
    final emails = contact.emails?.map((e) => e.value?.toLowerCase()).where((e) => e != null).toList() ?? [];
    final phones = contact.phones?.map((p) => p.value?.replaceAll(RegExp(r'\D'), '')).where((p) => p != null).toList() ?? [];
    
    for (final user in existingUsers) {
      final userLower = user.toLowerCase();
      if (emails.contains(userLower) || phones.any((phone) => phone!.endsWith(userLower.replaceAll(RegExp(r'\D'), '')))) {
        return true;
      }
    }
    
    return false;
  }

  /// Extract contact information for sharing
  List<ContactInfo> extractContactInfo(List<Contact> contacts) {
    return contacts.map((contact) {
      final emails = contact.emails?.map((e) => e.value).where((e) => e != null).cast<String>().toList() ?? [];
      final phones = contact.phones?.map((p) => p.value).where((p) => p != null).cast<String>().toList() ?? [];
      
      return ContactInfo(
        displayName: contact.displayName ?? 'Unknown Contact',
        emails: emails,
        phoneNumbers: phones,
        avatar: contact.avatar,
      );
    }).toList();
  }

  /// Generate initials from contact name
  String getContactInitials(Contact contact) {
    final name = contact.displayName ?? '';
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words.first[0].toUpperCase()}${words.last[0].toUpperCase()}';
    } else if (words.isNotEmpty) {
      return words.first[0].toUpperCase();
    }
    
    return '?';
  }

  /// Format phone number for display
  String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length == 10) {
      // US format: (XXX) XXX-XXXX
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      // US format with country code: +1 (XXX) XXX-XXXX
      return '+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    }
    
    // Return original if we can't format it
    return phoneNumber;
  }
}

/// Result of contact permission request
enum ContactPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  error,
}

/// Result of loading contacts
class ContactLoadResult {
  final bool isSuccess;
  final List<Contact>? contacts;
  final String? error;

  ContactLoadResult._({
    required this.isSuccess,
    this.contacts,
    this.error,
  });

  factory ContactLoadResult.success(List<Contact> contacts) {
    return ContactLoadResult._(
      isSuccess: true,
      contacts: contacts,
    );
  }

  factory ContactLoadResult.error(String error) {
    return ContactLoadResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// Simplified contact information for sharing
class ContactInfo {
  final String displayName;
  final List<String> emails;
  final List<String> phoneNumbers;
  final List<int>? avatar;

  ContactInfo({
    required this.displayName,
    required this.emails,
    required this.phoneNumbers,
    this.avatar,
  });

  /// Get primary email address
  String? get primaryEmail => emails.isNotEmpty ? emails.first : null;

  /// Get primary phone number
  String? get primaryPhoneNumber => phoneNumbers.isNotEmpty ? phoneNumbers.first : null;

  /// Check if contact has any email or phone
  bool get hasContactMethod => emails.isNotEmpty || phoneNumbers.isNotEmpty;

  @override
  String toString() {
    return 'ContactInfo(displayName: $displayName, emails: $emails, phoneNumbers: $phoneNumbers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactInfo &&
        other.displayName == displayName &&
        other.emails.toString() == emails.toString() &&
        other.phoneNumbers.toString() == phoneNumbers.toString();
  }

  @override
  int get hashCode {
    return displayName.hashCode ^
        emails.toString().hashCode ^
        phoneNumbers.toString().hashCode;
  }
}