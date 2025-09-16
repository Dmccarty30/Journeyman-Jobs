// MEMORY LEAK FIX - ContactPicker
// CRITICAL: TextEditingController and stream subscription memory leak fix

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../../design_system/app_theme.dart';

/// FIXED: Added proper dispose() method to prevent battery drain
/// during job sharing and viral growth flows
class ContactPicker extends StatefulWidget {
  final Function(List<Contact>) onContactsSelected;
  final bool allowMultipleSelection;
  final String? searchHint;

  const ContactPicker({
    Key? key,
    required this.onContactsSelected,
    this.allowMultipleSelection = true,
    this.searchHint,
  }) : super(key: key);

  @override
  State<ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends State<ContactPicker>
    with TickerProviderStateMixin {
  // Controllers that need disposal
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Animation controllers that need disposal
  late AnimationController _loadingAnimationController;
  late AnimationController _selectionAnimationController;

  // Stream subscriptions that need cancellation
  StreamSubscription<String>? _searchSubscription;
  Timer? _debounceTimer;

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  Set<Contact> _selectedContacts = {};
  bool _isLoading = true;
  bool _hasPermission = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _loadingAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _selectionAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _requestPermissionAndLoadContacts();
    _setupSearchStream();
  }

  void _setupSearchStream() {
    // Setup search debouncing stream
    _searchSubscription = Stream.fromFuture(
      Future.delayed(Duration.zero, () => _searchController.text),
    ).listen((_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 300), () {
        if (mounted) {
          _filterContacts(_searchController.text);
        }
      });
    });

    // Listen to search field changes
    _searchController.addListener(() {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 300), () {
        if (mounted) {
          _filterContacts(_searchController.text);
        }
      });
    });
  }

  Future<void> _requestPermissionAndLoadContacts() async {
    _loadingAnimationController.repeat();

    final permission = await Permission.contacts.request();

    if (permission.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      await _loadContacts();
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }

    _loadingAnimationController.stop();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await ContactsService.getContacts(
        withThumbnails: false,
        photoHighResolution: false,
      );

      if (mounted) {
        setState(() {
          _allContacts = contacts.where((contact) {
            return contact.phones?.isNotEmpty == true &&
                   contact.displayName?.isNotEmpty == true;
          }).toList();
          _filteredContacts = List.from(_allContacts);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredContacts = List.from(_allContacts);
      } else {
        _filteredContacts = _allContacts.where((contact) {
          final name = contact.displayName?.toLowerCase() ?? '';
          final phones = contact.phones?.map((p) => p.value ?? '').join(' ') ?? '';
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) || phones.contains(searchLower);
        }).toList();
      }
    });
  }

  // CRITICAL MEMORY LEAK FIX: Proper disposal of all resources
  @override
  void dispose() {
    // Dispose controllers
    _searchController.dispose();
    _scrollController.dispose();

    // Dispose animation controllers
    _loadingAnimationController.dispose();
    _selectionAnimationController.dispose();

    // Cancel stream subscriptions
    _searchSubscription?.cancel();

    // Cancel timers
    _debounceTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Select Contacts',
          style: AppTheme.headingMedium.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedContacts.isNotEmpty)
            TextButton(
              onPressed: _confirmSelection,
              child: Text(
                'Done (${_selectedContacts.length})',
                style: TextStyle(color: AppTheme.accentCopper),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHint ?? 'Search contacts...',
                hintStyle: TextStyle(color: Colors.white60),
                prefixIcon: Icon(Icons.search, color: Colors.white60),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white60),
                        onPressed: () {
                          _searchController.clear();
                          _filterContacts('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.accentCopper),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _loadingAnimationController,
              child: Icon(
                Icons.contacts,
                size: 48,
                color: AppTheme.accentCopper,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading contacts...',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.contacts_outlined,
                size: 64,
                color: Colors.white60,
              ),
              SizedBox(height: 24),
              Text(
                'Contacts Permission Required',
                style: AppTheme.headingMedium.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'To share jobs with your contacts, we need access to your contact list.',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestPermissionAndLoadContacts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                ),
                child: Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.white60,
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No contacts found' : 'No matching contacts',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final isSelected = _selectedContacts.contains(contact);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentCopper.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.accentCopper : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.accentCopper,
              child: Text(
                (contact.displayName?.isNotEmpty == true
                    ? contact.displayName![0].toUpperCase()
                    : '?'),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              contact.displayName ?? 'Unknown',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              contact.phones?.first.value ?? '',
              style: AppTheme.bodySmall.copyWith(color: Colors.white70),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: AppTheme.accentCopper,
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.white60,
                  ),
            onTap: () => _toggleContactSelection(contact),
          ),
        );
      },
    );
  }

  void _toggleContactSelection(Contact contact) {
    _selectionAnimationController.forward().then((_) {
      _selectionAnimationController.reset();
    });

    setState(() {
      if (widget.allowMultipleSelection) {
        if (_selectedContacts.contains(contact)) {
          _selectedContacts.remove(contact);
        } else {
          _selectedContacts.add(contact);
        }
      } else {
        _selectedContacts.clear();
        _selectedContacts.add(contact);
        // For single selection, immediately confirm
        _confirmSelection();
      }
    });
  }

  void _confirmSelection() {
    widget.onContactsSelected(_selectedContacts.toList());
    Navigator.pop(context);
  }
}