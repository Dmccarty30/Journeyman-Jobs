import 'dart:async';
import 'dart:developer' as dev;

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/contact_service.dart';

/// Provider for ContactService instance
final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService.instance;
});

/// State class for contact-related data
class ContactState {
  final bool isLoading;
  final bool hasPermission;
  final List<Contact> allContacts;
  final List<Contact> filteredContacts;
  final List<Contact> selectedContacts;
  final String searchQuery;
  final String? errorMessage;
  final List<String> existingPlatformUsers;

  const ContactState({
    this.isLoading = false,
    this.hasPermission = false,
    this.allContacts = const [],
    this.filteredContacts = const [],
    this.selectedContacts = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.existingPlatformUsers = const [],
  });

  ContactState copyWith({
    bool? isLoading,
    bool? hasPermission,
    List<Contact>? allContacts,
    List<Contact>? filteredContacts,
    List<Contact>? selectedContacts,
    String? searchQuery,
    String? errorMessage,
    List<String>? existingPlatformUsers,
  }) {
    return ContactState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      allContacts: allContacts ?? this.allContacts,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      selectedContacts: selectedContacts ?? this.selectedContacts,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      existingPlatformUsers: existingPlatformUsers ?? this.existingPlatformUsers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactState &&
        other.isLoading == isLoading &&
        other.hasPermission == hasPermission &&
        other.allContacts == allContacts &&
        other.filteredContacts == filteredContacts &&
        other.selectedContacts == selectedContacts &&
        other.searchQuery == searchQuery &&
        other.errorMessage == errorMessage &&
        other.existingPlatformUsers == existingPlatformUsers;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      hasPermission,
      allContacts,
      filteredContacts,
      selectedContacts,
      searchQuery,
      errorMessage,
      existingPlatformUsers,
    );
  }
}

/// Provider for managing contact state
class ContactNotifier extends StateNotifier<ContactState> {
  final ContactService _contactService;
  Timer? _searchDebounceTimer;

  ContactNotifier(this._contactService) : super(const ContactState());

  /// Initialize contact provider by checking permissions and loading contacts
  Future<void> initialize({List<String> existingPlatformUsers = const []}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      existingPlatformUsers: existingPlatformUsers,
    );

    try {
      final hasPermission = await _contactService.hasContactsPermission();
      
      if (hasPermission) {
        state = state.copyWith(hasPermission: true);
        await loadContacts();
      } else {
        state = state.copyWith(
          hasPermission: false,
          isLoading: false,
        );
      }
    } catch (e) {
      dev.log('Error initializing contacts: $e', name: 'ContactNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize contacts: $e',
      );
    }
  }

  /// Request contacts permission
  Future<bool> requestPermission() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _contactService.requestContactsPermission();
      
      switch (result) {
        case ContactPermissionResult.granted:
          state = state.copyWith(hasPermission: true);
          await loadContacts();
          return true;
          
        case ContactPermissionResult.denied:
          state = state.copyWith(
            isLoading: false,
            hasPermission: false,
            errorMessage: 'Contacts permission denied. You can still share jobs using other methods.',
          );
          return false;
          
        case ContactPermissionResult.permanentlyDenied:
          state = state.copyWith(
            isLoading: false,
            hasPermission: false,
            errorMessage: 'Contacts permission is permanently denied. Please enable it in Settings.',
          );
          return false;
          
        case ContactPermissionResult.error:
          state = state.copyWith(
            isLoading: false,
            hasPermission: false,
            errorMessage: 'Failed to request contacts permission.',
          );
          return false;
      }
    } catch (e) {
      dev.log('Error requesting permission: $e', name: 'ContactNotifier');
      state = state.copyWith(
        isLoading: false,
        hasPermission: false,
        errorMessage: 'Failed to request contacts permission: $e',
      );
      return false;
    }
  }

  /// Load contacts from device
  Future<void> loadContacts() async {
    if (!state.hasPermission) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Contacts permission not granted',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _contactService.loadContacts(
        requireEmailOrPhone: true,
        withThumbnails: false, // For performance
        photoHighResolution: false,
      );

      if (result.isSuccess && result.contacts != null) {
        final contacts = result.contacts!;
        state = state.copyWith(
          isLoading: false,
          allContacts: contacts,
          filteredContacts: contacts,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? 'Failed to load contacts',
        );
      }
    } catch (e) {
      dev.log('Error loading contacts: $e', name: 'ContactNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load contacts: $e',
      );
    }
  }

  /// Filter contacts based on search query with debouncing
  void searchContacts(String query) {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();
    
    // Set immediate state update for UI responsiveness
    state = state.copyWith(searchQuery: query);
    
    // Debounce the actual filtering
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  /// Perform the actual search filtering
  void _performSearch(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        filteredContacts: state.allContacts,
      );
    } else {
      final filtered = state.allContacts.where((contact) {
        final name = contact.displayName?.toLowerCase() ?? '';
        final emails = contact.emails?.map((e) => e.value?.toLowerCase() ?? '').join(' ') ?? '';
        final phones = contact.phones?.map((p) => p.value?.toLowerCase() ?? '').join(' ') ?? '';
        final searchLower = query.toLowerCase();
        
        return name.contains(searchLower) || 
               emails.contains(searchLower) || 
               phones.contains(searchLower);
      }).toList();

      state = state.copyWith(
        filteredContacts: filtered,
      );
    }
  }

  /// Clear search query and show all contacts
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    state = state.copyWith(
      searchQuery: '',
      filteredContacts: state.allContacts,
    );
  }

  /// Select/deselect a contact
  void toggleContact(Contact contact, {bool allowMultiSelect = true, int maxSelection = 10}) {
    final selectedList = List<Contact>.from(state.selectedContacts);
    
    if (selectedList.contains(contact)) {
      selectedList.remove(contact);
    } else {
      if (allowMultiSelect) {
        if (selectedList.length < maxSelection) {
          selectedList.add(contact);
        }
      } else {
        selectedList.clear();
        selectedList.add(contact);
      }
    }
    
    state = state.copyWith(selectedContacts: selectedList);
  }

  /// Clear all selected contacts
  void clearSelection() {
    state = state.copyWith(selectedContacts: []);
  }

  /// Set existing platform users for highlighting
  void setExistingPlatformUsers(List<String> users) {
    state = state.copyWith(existingPlatformUsers: users);
  }

  /// Check if a contact is an existing platform user
  bool isExistingPlatformUser(Contact contact) {
    return _contactService.isExistingPlatformUser(contact, state.existingPlatformUsers);
  }

  /// Extract contact information from selected contacts
  List<ContactInfo> getSelectedContactInfo() {
    return _contactService.extractContactInfo(state.selectedContacts);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for contact state management
final contactProvider = StateNotifierProvider<ContactNotifier, ContactState>((ref) {
  final contactService = ref.watch(contactServiceProvider);
  return ContactNotifier(contactService);
});

/// Provider for checking if contacts permission is granted
final contactPermissionProvider = FutureProvider<bool>((ref) async {
  final contactService = ref.watch(contactServiceProvider);
  return contactService.hasContactsPermission();
});

/// Provider for selected contact count
final selectedContactCountProvider = Provider<int>((ref) {
  final contactState = ref.watch(contactProvider);
  return contactState.selectedContacts.length;
});

/// Provider for filtered contact count
final filteredContactCountProvider = Provider<int>((ref) {
  final contactState = ref.watch(contactProvider);
  return contactState.filteredContacts.length;
});

/// Provider for checking if search is active
final hasActiveSearchProvider = Provider<bool>((ref) {
  final contactState = ref.watch(contactProvider);
  return contactState.searchQuery.isNotEmpty;
});