import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/user_model.dart';
import '../models/user_model_extensions.dart';

/// Widget for selecting and adding recipients for job sharing
/// 
/// Features:
/// - Search functionality with electrical-themed styling
/// - Selected recipients display with removal option
/// - Recent contacts prioritization
/// - Add new contact capability
/// - Electrical animations and visual feedback
class JJRecipientSelector extends StatefulWidget {
  /// List of available contacts
  final List<UserModel> contacts;
  
  /// Currently selected recipients
  final List<UserModel> selectedRecipients;
  
  /// Callback when selected recipients change
  final Function(List<UserModel>) onRecipientsChanged;
  
  /// Maximum number of recipients allowed
  final int maxRecipients;

  const JJRecipientSelector({
    super.key,
    required this.contacts,
    required this.selectedRecipients,
    required this.onRecipientsChanged,
    this.maxRecipients = 10,
  });

  @override
  State<JJRecipientSelector> createState() => _JJRecipientSelectorState();
}

class _JJRecipientSelectorState extends State<JJRecipientSelector>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  List<UserModel> _filteredContacts = [];
  bool _showSearchResults = false;
  late AnimationController _animationController;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    // Listen for search changes
    _searchController.addListener(_onSearchChanged);
    _searchFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = widget.contacts;
      } else {
        _filteredContacts = widget.contacts.where((contact) {
          return contact.name.toLowerCase().contains(query) ||
                 (contact.email.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSearchResults = _searchFocus.hasFocus;
    });
    if (_searchFocus.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _addRecipient(UserModel recipient) {
    if (!widget.selectedRecipients.contains(recipient) &&
        widget.selectedRecipients.length < widget.maxRecipients) {
      final updatedRecipients = [...widget.selectedRecipients, recipient];
      widget.onRecipientsChanged(updatedRecipients);
      
      // Clear search when adding
      _searchController.clear();
      _searchFocus.unfocus();
    }
  }

  void _removeRecipient(UserModel recipient) {
    final updatedRecipients = widget.selectedRecipients
        .where((r) => r.id != recipient.id)
        .toList();
    widget.onRecipientsChanged(updatedRecipients);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected recipients display
        if (widget.selectedRecipients.isNotEmpty)
          _buildSelectedRecipients(),
        
        if (widget.selectedRecipients.isNotEmpty)
          const SizedBox(height: AppTheme.spacingMd),
        
        // Search input
        _buildSearchInput(),
        
        // Search results
        if (_showSearchResults && _filteredContacts.isNotEmpty)
          _buildSearchResults(),
      ],
    );
  }

  Widget _buildSelectedRecipients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Recipients',
          style: AppTheme.labelMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingSm),
        
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: widget.selectedRecipients.map((recipient) {
            return _buildRecipientChip(recipient);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecipientChip(UserModel recipient) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.electricalGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCopper.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: recipient.profileImageUrl.isNotEmpty
                ? NetworkImage(recipient.profileImageUrl)
                : null,
            child: recipient.profileImageUrl.isEmpty
                ? Text(
                    recipient.name.isNotEmpty
                        ? recipient.name[0].toUpperCase()
                        : '?',
                    style: AppTheme.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: AppTheme.spacingSm),
          
          // Name
          Flexible(
            child: Text(
              recipient.name,
              style: AppTheme.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          
          const SizedBox(width: AppTheme.spacingXs),
          
          // Remove button
          GestureDetector(
            onTap: () => _removeRecipient(recipient),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    )
      .animate()
      .scale(
        begin: const Offset(0.8, 0.8),
        duration: 200.ms,
        curve: Curves.easeOut,
      )
      .fadeIn(duration: 200.ms);
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: _searchFocus.hasFocus
              ? AppTheme.accentCopper
              : AppTheme.borderLight,
          width: _searchFocus.hasFocus
              ? AppTheme.borderWidthMedium
              : AppTheme.borderWidthThin,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        decoration: InputDecoration(
          hintText: 'Search contacts or add email...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _searchFocus.hasFocus
                ? AppTheme.accentCopper
                : AppTheme.mediumGray,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: AppTheme.mediumGray,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppTheme.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingMd,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * _searchAnimation.value),
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: _searchAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(top: AppTheme.spacingSm),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: AppTheme.borderWidthThin,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  final isSelected = widget.selectedRecipients.contains(contact);
                  
                  return _buildContactItem(contact, isSelected);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactItem(UserModel contact, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingXs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSelected ? null : () => _addRecipient(contact),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentCopper.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.accentCopper.withValues(alpha: 0.3),
                      width: AppTheme.borderWidthThin,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.accentCopper.withValues(alpha: 0.1),
                  backgroundImage: contact.profileImageUrl.isNotEmpty
                      ? NetworkImage(contact.profileImageUrl)
                      : null,
                  child: contact.profileImageUrl.isEmpty
                      ? Text(
                          contact.name.isNotEmpty
                              ? contact.name[0].toUpperCase()
                              : '?',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.accentCopper,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                
                const SizedBox(width: AppTheme.spacingMd),
                
                // Contact info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: AppTheme.bodyMedium.copyWith(
                          color: isSelected
                              ? AppTheme.accentCopper
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ...[
                      const SizedBox(height: AppTheme.spacingXxs),
                      Text(
                        contact.email,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    ],
                  ),
                ),
                
                // Selection indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingXs),
                    decoration: const BoxDecoration(
                      color: AppTheme.accentCopper,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  )
                    .animate()
                    .scale(
                      begin: const Offset(0.0, 0.0),
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
