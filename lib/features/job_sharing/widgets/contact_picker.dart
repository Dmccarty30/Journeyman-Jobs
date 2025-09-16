
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/app_theme.dart';

/// A widget that displays a contact picker for selecting contacts to share jobs with.
/// Handles permissions, loads contacts, provides search/filter functionality,
/// and supports multi-selection with visual distinction for existing platform users.
class JJContactPicker extends ConsumerStatefulWidget {
  /// Callback when contacts are selected
  final Function(List<Contact>) onContactsSelected;
  
  /// Optional list of existing platform users (emails/phone numbers)
  final List<String>? existingPlatformUsers;
  
  /// Whether to allow multi-selection
  final bool allowMultiSelect;
  
  /// Maximum number of contacts that can be selected
  final int maxSelection;

  const JJContactPicker({
    super.key,
    required this.onContactsSelected,
    this.existingPlatformUsers,
    this.allowMultiSelect = true,
    this.maxSelection = 10,
  });

  @override
  ConsumerState<JJContactPicker> createState() => _JJContactPickerState();
}

class _JJContactPickerState extends ConsumerState<JJContactPicker> {
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  List<Contact> _selectedContacts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasPermission = false;
  String? _errorMessage;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Check contacts permission and load contacts if granted
  Future<void> _checkPermissionAndLoadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await Permission.contacts.status;
      
      if (status.isGranted) {
        _hasPermission = true;
        await _loadContacts();
      } else if (status.isDenied) {
        await _requestPermission();
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _hasPermission = false;
          _errorMessage = 'Contacts permission is permanently denied. Please enable it in Settings.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check contacts permission: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Request contacts permission
  Future<void> _requestPermission() async {
    final status = await Permission.contacts.request();
    
    if (status.isGranted) {
      _hasPermission = true;
      await _loadContacts();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _hasPermission = false;
        _errorMessage = 'Contacts permission is required to share jobs with your contacts. Please enable it in Settings.';
      });
    } else {
      setState(() {
        _hasPermission = false;
        _errorMessage = 'Contacts permission denied. You can still share jobs using other methods.';
      });
    }
  }

  /// Load contacts from device
  Future<void> _loadContacts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final contacts = await ContactsService.getContacts(
        withThumbnails: false, // For performance
        photoHighResolution: false,
      );

      // Filter contacts that have email or phone
      final validContacts = contacts.where((contact) {
        final hasEmail = contact.emails?.isNotEmpty == true;
        final hasPhone = contact.phones?.isNotEmpty == true;
        final hasName = contact.displayName?.isNotEmpty == true;
        return (hasEmail || hasPhone) && hasName;
      }).toList();

      // Sort alphabetically by display name
      validContacts.sort((a, b) {
        final nameA = a.displayName ?? '';
        final nameB = b.displayName ?? '';
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      });

      setState(() {
        _allContacts = validContacts;
        _filteredContacts = validContacts;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load contacts: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Filter contacts based on search query
  void _filterContacts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts.where((contact) {
          final name = contact.displayName?.toLowerCase() ?? '';
          final emails = contact.emails?.map((e) => e.value?.toLowerCase() ?? '').join(' ') ?? '';
          final phones = contact.phones?.map((p) => p.value?.toLowerCase() ?? '').join(' ') ?? '';
          final searchLower = query.toLowerCase();
          
          return name.contains(searchLower) || 
                 emails.contains(searchLower) || 
                 phones.contains(searchLower);
        }).toList();
      }
    });
  }

  /// Toggle contact selection
  void _toggleContact(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        if (widget.allowMultiSelect) {
          if (_selectedContacts.length < widget.maxSelection) {
            _selectedContacts.add(contact);
          }
        } else {
          _selectedContacts = [contact];
        }
      }
    });
    
    widget.onContactsSelected(_selectedContacts);
  }

  /// Check if contact is an existing platform user
  bool _isExistingPlatformUser(Contact contact) {
    if (widget.existingPlatformUsers == null) return false;
    
    final emails = contact.emails?.map((e) => e.value?.toLowerCase()).where((e) => e != null).toList() ?? [];
    final phones = contact.phones?.map((p) => p.value?.replaceAll(RegExp(r'\D'), '')).where((p) => p != null).toList() ?? [];
    
    for (final user in widget.existingPlatformUsers!) {
      final userLower = user.toLowerCase();
      if (emails.contains(userLower) || phones.any((phone) => phone!.endsWith(userLower.replaceAll(RegExp(r'\D'), '')))) {
        return true;
      }
    }
    
    return false;
  }

  /// Generate initials for contact avatar
  String _getContactInitials(Contact contact) {
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

  /// Build contact avatar
  Widget _buildContactAvatar(Contact contact) {
    final initials = _getContactInitials(contact);
    final isExistingUser = _isExistingPlatformUser(contact);
    
    return CircleAvatar(
      radius: 24,
      backgroundColor: isExistingUser ? AppTheme.successGreen : AppTheme.accentCopper,
      child: contact.avatar != null && contact.avatar!.isNotEmpty
          ? ClipOval(
              child: Image.memory(
                contact.avatar!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    initials,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            )
          : Text(
              initials,
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  /// Build contact info text
  Widget _buildContactInfo(Contact contact) {
    final isExistingUser = _isExistingPlatformUser(contact);
    
    List<String> info = [];
    
    // Add primary email
    if (contact.emails?.isNotEmpty == true) {
      info.add(contact.emails!.first.value ?? '');
    }
    
    // Add primary phone
    if (contact.phones?.isNotEmpty == true) {
      info.add(contact.phones!.first.value ?? '');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              contact.displayName ?? 'Unknown Contact',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            if (isExistingUser) ...[
              const SizedBox(width: AppTheme.spacingSm),
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
          ],
        ),
        if (info.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            info.join(' • '),
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Build permission denied view
  Widget _buildPermissionDeniedView() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contacts_outlined,
            size: AppTheme.iconXxl * 2,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Contacts Access Required',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            _errorMessage ?? 'This app needs access to your contacts to help you share job opportunities with your IBEW brothers and sisters.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ElevatedButton.icon(
            onPressed: () async {
              await openAppSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          TextButton(
            onPressed: _checkPermissionAndLoadContacts,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Build loading view
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.accentCopper,
          ),
          SizedBox(height: AppTheme.spacingLg),
          Text(
            'Loading contacts...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build empty contacts view
  Widget _buildEmptyContactsView() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contact_phone_outlined,
            size: AppTheme.iconXxl * 2,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            _searchQuery.isEmpty ? 'No Contacts Found' : 'No Matching Contacts',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            _searchQuery.isEmpty 
                ? 'No contacts with email addresses or phone numbers found on your device.'
                : 'Try adjusting your search terms.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterContacts('');
                  },
                )
              : null,
        ),
        onChanged: _filterContacts,
      ),
    );
  }

  /// Build selected contacts header
  Widget _buildSelectedContactsHeader() {
    if (_selectedContacts.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      color: AppTheme.accentCopper.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.accentCopper,
            size: AppTheme.iconSm,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            '${_selectedContacts.length} contact${_selectedContacts.length == 1 ? '' : 's'} selected',
            style: AppTheme.titleSmall.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.maxSelection > 1) ...[
            Text(
              ' (max ${widget.maxSelection})',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build contact list item
  Widget _buildContactItem(Contact contact) {
    final isSelected = _selectedContacts.contains(contact);
    _isExistingPlatformUser(contact);
    final canSelect = widget.allowMultiSelect 
        ? _selectedContacts.length < widget.maxSelection || isSelected
        : true;
    
    return ListTile(
      leading: _buildContactAvatar(contact),
      title: _buildContactInfo(contact),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: AppTheme.accentCopper,
            )
          : canSelect
              ? Icon(
                  Icons.radio_button_unchecked,
                  color: AppTheme.mediumGray,
                )
              : Icon(
                  Icons.block,
                  color: AppTheme.mediumGray,
                ),
      onTap: canSelect ? () => _toggleContact(contact) : null,
      selected: isSelected,
      selectedTileColor: AppTheme.accentCopper.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contacts'),
        elevation: 0,
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
        actions: [
          if (_selectedContacts.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedContacts);
              },
              child: Text(
                'Done',
                style: AppTheme.buttonMedium.copyWith(
                  color: AppTheme.white,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasPermission && !_isLoading) 
            Expanded(child: _buildPermissionDeniedView())
          else if (_isLoading)
            Expanded(child: _buildLoadingView())
          else if (_allContacts.isEmpty)
            Expanded(child: _buildEmptyContactsView())
          else ...[
            _buildSearchBar(),
            _buildSelectedContactsHeader(),
            Expanded(
              child: _filteredContacts.isEmpty
                  ? _buildEmptyContactsView()
                  : ListView.builder(
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        return _buildContactItem(_filteredContacts[index]);
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}