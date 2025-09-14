import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

import '../../../design_system/app_theme.dart';
import '../providers/contact_provider.dart';
import '../services/contact_service.dart';

/// A Riverpod-powered contact picker widget for selecting contacts to share jobs with.
/// Uses ContactNotifier for state management and provides better performance and
/// separation of concerns.
class JJRiverpodContactPicker extends ConsumerStatefulWidget {
  /// Callback when contacts are selected
  final Function(List<ContactInfo>) onContactsSelected;
  
  /// Optional list of existing platform users (emails/phone numbers)
  final List<String>? existingPlatformUsers;
  
  /// Whether to allow multi-selection
  final bool allowMultiSelect;
  
  /// Maximum number of contacts that can be selected
  final int maxSelection;
  
  /// Whether to show existing platform users differently
  final bool highlightExistingUsers;

  const JJRiverpodContactPicker({
    Key? key,
    required this.onContactsSelected,
    this.existingPlatformUsers,
    this.allowMultiSelect = true,
    this.maxSelection = 10,
    this.highlightExistingUsers = true,
  }) : super(key: key);

  @override
  ConsumerState<JJRiverpodContactPicker> createState() => _JJRiverpodContactPickerState();
}

class _JJRiverpodContactPickerState extends ConsumerState<JJRiverpodContactPicker> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize the contact provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactProvider.notifier).initialize(
        existingPlatformUsers: widget.existingPlatformUsers ?? [],
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Handle contact selection
  void _handleContactSelection(Contact contact) {
    ref.read(contactProvider.notifier).toggleContact(
      contact,
      allowMultiSelect: widget.allowMultiSelect,
      maxSelection: widget.maxSelection,
    );
    
    // Get updated contact info and notify parent
    final selectedContacts = ref.read(contactProvider.notifier).getSelectedContactInfo();
    widget.onContactsSelected(selectedContacts);
  }

  /// Handle search input
  void _handleSearchChanged(String query) {
    ref.read(contactProvider.notifier).searchContacts(query);
  }

  /// Clear search
  void _clearSearch() {
    _searchController.clear();
    ref.read(contactProvider.notifier).clearSearch();
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
  Widget _buildContactAvatar(Contact contact, bool isExistingUser) {
    final initials = _getContactInitials(contact);
    
    return CircleAvatar(
      radius: 24,
      backgroundColor: isExistingUser && widget.highlightExistingUsers 
          ? AppTheme.successGreen 
          : AppTheme.accentCopper,
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

  /// Build contact info section
  Widget _buildContactInfo(Contact contact, bool isExistingUser) {
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
            Expanded(
              child: Text(
                contact.displayName ?? 'Unknown Contact',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isExistingUser && widget.highlightExistingUsers) ...[
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
  Widget _buildPermissionDeniedView(ContactState state) {
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
            state.errorMessage ?? 'This app needs access to your contacts to help you share job opportunities with your IBEW brothers and sisters.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ElevatedButton.icon(
            onPressed: () async {
              final granted = await ref.read(contactProvider.notifier).requestPermission();
              if (!granted) {
                await openAppSettings();
              }
            },
            icon: const Icon(Icons.settings),
            label: const Text('Grant Permission'),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          TextButton(
            onPressed: () {
              ref.read(contactProvider.notifier).initialize(
                existingPlatformUsers: widget.existingPlatformUsers ?? [],
              );
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Build loading view
  Widget _buildLoadingView() {
    return const Center(
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
  Widget _buildEmptyContactsView(bool hasSearch) {
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
            hasSearch ? 'No Matching Contacts' : 'No Contacts Found',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            hasSearch 
                ? 'Try adjusting your search terms.'
                : 'No contacts with email addresses or phone numbers found on your device.',
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
          suffixIcon: Consumer(
            builder: (context, ref, child) {
              final hasActiveSearch = ref.watch(hasActiveSearchProvider);
              return hasActiveSearch
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : const SizedBox.shrink();
            },
          ),
        ),
        onChanged: _handleSearchChanged,
      ),
    );
  }

  /// Build selected contacts header
  Widget _buildSelectedContactsHeader() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedCount = ref.watch(selectedContactCountProvider);
        
        if (selectedCount == 0) return const SizedBox.shrink();
        
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
                '$selectedCount contact${selectedCount == 1 ? '' : 's'} selected',
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
      },
    );
  }

  /// Build contact list item
  Widget _buildContactItem(Contact contact, ContactState state) {
    final isSelected = state.selectedContacts.contains(contact);
    final isExistingUser = ref.read(contactProvider.notifier).isExistingPlatformUser(contact);
    final canSelect = widget.allowMultiSelect 
        ? state.selectedContacts.length < widget.maxSelection || isSelected
        : true;
    
    return ListTile(
      leading: _buildContactAvatar(contact, isExistingUser),
      title: _buildContactInfo(contact, isExistingUser),
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
      onTap: canSelect ? () => _handleContactSelection(contact) : null,
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
    return Consumer(
      builder: (context, ref, child) {
        final contactState = ref.watch(contactProvider);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Contacts'),
            elevation: 0,
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: AppTheme.white,
            actions: [
              if (contactState.selectedContacts.isNotEmpty)
                TextButton(
                  onPressed: () {
                    final selectedContactsInfo = ref.read(contactProvider.notifier).getSelectedContactInfo();
                    Navigator.of(context).pop(selectedContactsInfo);
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
              if (!contactState.hasPermission && !contactState.isLoading) 
                Expanded(child: _buildPermissionDeniedView(contactState))
              else if (contactState.isLoading)
                Expanded(child: _buildLoadingView())
              else if (contactState.allContacts.isEmpty)
                Expanded(child: _buildEmptyContactsView(false))
              else ...[
                _buildSearchBar(),
                _buildSelectedContactsHeader(),
                Expanded(
                  child: contactState.filteredContacts.isEmpty
                      ? _buildEmptyContactsView(contactState.searchQuery.isNotEmpty)
                      : ListView.builder(
                          itemCount: contactState.filteredContacts.length,
                          itemBuilder: (context, index) {
                            return _buildContactItem(
                              contactState.filteredContacts[index],
                              contactState,
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}