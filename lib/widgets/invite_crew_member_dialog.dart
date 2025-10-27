import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/services/enhanced_crew_service.dart';
import 'package:journeyman_jobs/widgets/electrical_components.dart';

/// Dialog for inviting a user to join a crew
///
/// This dialog provides:
/// - User search and selection
/// - Custom invitation message
/// - Real-time validation
/// - Electrical themed UI with loading states
class InviteCrewMemberDialog extends StatefulWidget {
  final String crewId;
  final String crewName;

  const InviteCrewMemberDialog({
    super.key,
    required this.crewId,
    required this.crewName,
  });

  @override
  State<InviteCrewMemberDialog> createState() => _InviteCrewMemberDialogState();
}

class _InviteCrewMemberDialogState extends State<InviteCrewMemberDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final EnhancedCrewService _crewService = EnhancedCrewService();

  bool _isSearching = false;
  bool _isInviting = false;
  List<UserModel> _searchResults = [];
  UserModel? _selectedUser;
  String _searchError = '';

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppTheme.durationElectricalSlide,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppTheme.curveElectricalSlide,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _fadeController.forward();

    // Set default invitation message
    _messageController.text = 'I\'d like to invite you to join our crew ${widget.crewName}.';
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingXl,
            ),
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthCopper,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.electricalGlowInfo.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserSearch(),
                        const SizedBox(height: AppTheme.spacingLg),
                        _buildInvitationMessage(),
                      ],
                    ),
                  ),
                ),

                // Actions
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusXl),
          topRight: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      child: Stack(
        children: [
          // Circuit pattern background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusXl),
                topRight: Radius.circular(AppTheme.radiusXl),
              ),
              child: CircuitPatternBackground(
                opacity: 0.05,
                color: AppTheme.electricalCircuitTrace,
              ),
            ),
          ),

          // Header content
          Row(
            children: [
              // Crew icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.electricalGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricalGlowInfo.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.group_add,
                  color: AppTheme.white,
                  size: AppTheme.iconLg,
                ),
              ),

              const SizedBox(width: AppTheme.spacingMd),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite to ${widget.crewName}',
                      style: AppTheme.headlineMedium.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Search for IBEW members to invite',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Close button
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                color: AppTheme.white,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Member',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),

        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by name, email, or local...',
            prefixIcon: Icon(Icons.search, color: AppTheme.textLight),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: _clearSearch,
                    icon: Icon(Icons.clear, color: AppTheme.textLight),
                  )
                : null,
            filled: true,
            fillColor: AppTheme.offWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthThick,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.errorRed),
            ),
            errorText: _searchError.isNotEmpty ? _searchError : null,
          ),
          onChanged: _onSearchChanged,
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Loading indicator
        if (_isSearching)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: JJElectricalLoader(
                width: 200,
                height: 40,
                message: 'Searching...',
              ),
            ),
          ),

        // Search results
        if (!_isSearching && _searchResults.isNotEmpty)
          _buildSearchResults(),

        // No results
        if (!_isSearching && _searchController.text.isNotEmpty && _searchResults.isEmpty)
          _buildNoResults(),

        // Selected user display
        if (_selectedUser != null)
          _buildSelectedUser(),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppTheme.borderLight,
        ),
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          final isSelected = _selectedUser?.uid == user.uid;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryNavy,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.displayNameStr.isNotEmpty
                          ? user.displayNameStr[0].toUpperCase()
                          : 'U',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.white,
                      ),
                    )
                  : null,
            ),
            title: Text(
              user.displayNameStr,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${user.classification} • Local ${user.homeLocal}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: AppTheme.successGreen,
                    size: AppTheme.iconLg,
                  )
                : Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.textLight,
                    size: AppTheme.iconLg,
                  ),
            onTap: () => _selectUser(user),
            selected: isSelected,
            selectedTileColor: AppTheme.accentCopper.withValues(alpha: 0.1),
          );
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'No members found',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Try searching with different terms',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedUser() {
    final user = _selectedUser!;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withValues(alpha: 0.1),
        border: Border.all(
          color: AppTheme.successGreen.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.successGreen,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.displayNameStr.isNotEmpty
                        ? user.displayNameStr[0].toUpperCase()
                        : 'U',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayNameStr,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${user.classification} • Local ${user.homeLocal}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearSelectedUser,
            icon: Icon(Icons.clear, color: AppTheme.textLight),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.successGreen.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invitation Message (Optional)',
          style: AppTheme.titleMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),

        TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a personal message...',
            filled: true,
            fillColor: AppTheme.offWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthThick,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXl),
          bottomRight: Radius.circular(AppTheme.radiusXl),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _isInviting ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTheme.buttonMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedUser != null && !_isInviting ? _sendInvitation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                elevation: 2,
              ),
              child: _isInviting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Inviting...',
                          style: AppTheme.buttonMedium.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Send Invitation',
                      style: AppTheme.buttonMedium.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _searchError = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = '';
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      // This is a mock search implementation
      // In a real app, you would search against your user database
      final mockUsers = _getMockUsers();
      final results = mockUsers.where((user) {
        final searchLower = query.toLowerCase();
        return user.displayNameStr.toLowerCase().contains(searchLower) ||
               user.email.toLowerCase().contains(searchLower) ||
               user.classification.toLowerCase().contains(searchLower) ||
               user.homeLocal.toString().contains(searchLower);
      }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchError = 'Search failed: $e';
      });
    }
  }

  List<UserModel> _getMockUsers() {
    // Mock users for demonstration
    // In a real app, this would be a database query
    return [
      UserModel(
        uid: '1',
        username: 'johndoe',
        classification: 'Journeyman Lineman',
        homeLocal: 26,
        role: 'electrician',
        email: 'john.doe@example.com',
        displayName: 'John Doe',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '555-0101',
        address1: '123 Main St',
        city: 'Washington',
        state: 'DC',
        zipcode: 20001,
        ticketNumber: 'JL123456',
        networkWithOthers: true,
        careerAdvancements: false,
        betterBenefits: true,
        higherPayRate: true,
        learnNewSkill: false,
        travelToNewLocation: true,
        findLongTermWork: false,
        lastActive: DateTime.now(),
      ),
      UserModel(
        uid: '2',
        username: 'janesmith',
        classification: 'Journeyman Wireman',
        homeLocal: 103,
        role: 'electrician',
        email: 'jane.smith@example.com',
        displayName: 'Jane Smith',
        firstName: 'Jane',
        lastName: 'Smith',
        phoneNumber: '555-0102',
        address1: '456 Oak Ave',
        city: 'Boston',
        state: 'MA',
        zipcode: 02108,
        ticketNumber: 'JW789012',
        networkWithOthers: true,
        careerAdvancements: true,
        betterBenefits: false,
        higherPayRate: false,
        learnNewSkill: true,
        travelToNewLocation: false,
        findLongTermWork: true,
        lastActive: DateTime.now(),
      ),
    ];
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults.clear();
      _searchError = '';
    });
  }

  void _selectUser(UserModel user) {
    setState(() {
      _selectedUser = user;
    });
  }

  void _clearSelectedUser() {
    setState(() {
      _selectedUser = null;
    });
  }

  Future<void> _sendInvitation() async {
    if (_selectedUser == null) return;

    final currentUser = Provider.of<UserModel>(context, listen: false);
    final message = _messageController.text.trim();

    setState(() {
      _isInviting = true;
    });

    try {
      await _crewService.inviteMemberToCrew(
        crewId: widget.crewId,
        foreman: currentUser,
        invitee: _selectedUser!,
        message: message.isNotEmpty ? message : null,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.white, size: 20),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text('Invitation sent to ${_selectedUser!.displayNameStr}'),
              ),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          margin: const EdgeInsets.all(AppTheme.spacingMd),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: AppTheme.white, size: 20),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(child: Text('Failed to send invitation: $e')),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          margin: const EdgeInsets.all(AppTheme.spacingMd),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isInviting = false;
        });
      }
    }
  }
}