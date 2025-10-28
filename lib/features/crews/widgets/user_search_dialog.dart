import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/users_record.dart';
import '../../../services/user_discovery_service.dart';
import '../../../widgets/jj_skeleton_loader.dart';
import '../providers/crews_riverpod_provider.dart';

/// Dialog for searching and selecting users for crew invitations.
///
/// This widget provides an intuitive interface for discovering and inviting
/// users to join crews. It features real-time search with debouncing,
/// suggested users display, and comprehensive user information cards.
///
/// Features:
/// - Real-time search with debouncing to optimize performance
/// - Suggested users based on IBEW local and shared characteristics
/// - User cards with avatars, names, locals, and certifications
/// - Loading states and error handling
/// - Electrical theme integration
/// - Accessibility support
class UserSearchDialog extends ConsumerStatefulWidget {
  /// Current crew ID (for excluding existing members)
  final String crewId;

  /// Callback when a user is selected for invitation
  final Function(UsersRecord user) onUserSelected;

  /// Optional custom title for the dialog
  final String? title;

  /// Maximum number of search results to display
  final int maxResults;

  const UserSearchDialog({
    Key? key,
    required this.crewId,
    required this.onUserSelected,
    this.title,
    this.maxResults = 20,
  }) : super(key: key);

  @override
  ConsumerState<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends ConsumerState<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final UserDiscoveryService _discoveryService = UserDiscoveryService(
    firestore: FirebaseFirestore.instance,
  );

  List<UsersRecord> _searchResults = [];
  List<UsersRecord> _suggestedUsers = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestedUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _discoveryService.dispose();
    super.dispose();
  }

  /// Loads suggested users based on current user's profile.
  Future<void> _loadSuggestedUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = ref.watch(authRiverpodProvider);
      if (currentUser?.uid == null) return;

      final suggestions = await _discoveryService.getSuggestedUsers(
        userId: currentUser!.uid,
        crewId: widget.crewId,
        limit: 8,
      );

      if (mounted) {
        setState(() {
          _suggestedUsers = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load suggestions: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Handles search text changes with debouncing.
  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    // Use debounced search to optimize performance
    _discoveryService.searchUsersDebounced(
      query: query,
      limit: widget.maxResults,
      excludeUserId: ref.read(authRiverpodProvider)?.uid,
      onResults: (results) {
        if (mounted) {
          setState(() {
            _searchResults = results.users;
            _isSearching = false;
            _error = null;
          });
        }
      },
    );

    setState(() {
      _isSearching = true;
      _error = null;
    });
  }

  /// Clears search results and resets state.
  void _clearSearchResults() {
    setState(() {
      _searchResults.clear();
      _isSearching = false;
      _error = null;
    });
  }

  /// Handles user selection for invitation.
  void _onUserTapped(UsersRecord user) {
    Navigator.of(context).pop();
    widget.onUserSelected(user);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentCopper.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the dialog header with title and close button.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryNavy,
            AppTheme.primaryNavy.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.group_add,
            color: AppTheme.accentCopper,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title ?? 'Invite Crew Members',
              style: AppTheme.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: AppTheme.accentCopper,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the search input field.
  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        style: AppTheme.bodyText.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by name, email, or IBEW local...',
          hintStyle: AppTheme.bodyText.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.accentCopper,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _clearSearchResults();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.accentCopper,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.accentCopper.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.accentCopper,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.accentCopper.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main content area with search results or suggestions.
  Widget _buildContent() {
    if (_error != null) {
      return _buildErrorState();
    }

    if (_isSearching) {
      return _buildSearchingState();
    }

    if (_searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }

    return _buildSuggestedUsers();
  }

  /// Builds the searching/loading state.
  Widget _buildSearchingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          JJSkeletonLoader(
            width: double.infinity,
            height: 80,
            borderRadius: 12,
            showCircuitPattern: true,
          ),
          const SizedBox(height: 12),
          JJSkeletonLoader(
            width: double.infinity,
            height: 80,
            borderRadius: 12,
            showCircuitPattern: true,
          ),
          const SizedBox(height: 12),
          JJSkeletonLoader(
            width: double.infinity,
            height: 80,
            borderRadius: 12,
            showCircuitPattern: true,
          ),
        ],
      ),
    );
  }

  /// Builds the error state display.
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withOpacity(0.7),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTheme.bodyText.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadSuggestedUsers,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the search results list.
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No users found',
        message: 'Try searching with different keywords or check the spelling.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Search Results (${_searchResults.length})',
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final user = _searchResults[index];
              return UserResultCard(
                user: user,
                onTap: () => _onUserTapped(user),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the suggested users section.
  Widget _buildSuggestedUsers() {
    if (_isLoading) {
      return _buildSearchingState();
    }

    if (_suggestedUsers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No suggestions available',
        message: 'Start searching for users to invite to your crew.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accentCopper,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggested for You',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _suggestedUsers.length,
            itemBuilder: (context, index) {
              final user = _suggestedUsers[index];
              return UserResultCard(
                user: user,
                onTap: () => _onUserTapped(user),
                isSuggested: true,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds an empty state display.
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.headingMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyText.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget displaying user information in search results.
class UserResultCard extends StatelessWidget {
  final UsersRecord user;
  final VoidCallback onTap;
  final bool isSuggested;

  const UserResultCard({
    Key? key,
    required this.user,
    required this.onTap,
    this.isSuggested = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuggested
              ? AppTheme.accentCopper.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUserInfo(),
                ),
                _buildActionIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the user avatar with electrical theme.
  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentCopper,
            AppTheme.accentCopper.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : 'U',
              style: AppTheme.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isSuggested)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryNavy,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the user information section.
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.displayName,
          style: AppTheme.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (user.localNumber != null)
          Text(
            'IBEW Local ${user.localNumber}',
            style: AppTheme.caption.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (user.certifications != null && user.certifications!.isNotEmpty)
          Text(
            user.certifications!.take(2).join(' • '),
            style: AppTheme.caption.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (user.yearsExperience != null)
          Text(
            '${user.yearsExperience} years experience',
            style: AppTheme.caption.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  /// Builds the action indicator (invite button).
  Widget _buildActionIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.add_circle_outline,
        color: AppTheme.accentCopper,
        size: 24,
      ),
    );
  }
}

/// Extension to capitalize strings for display.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}