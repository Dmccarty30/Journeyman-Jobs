import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/crew_invitation_model.dart' as crew_model;
import '../../services/unified_crew_service.dart' as unified;
import 'package:journeyman_jobs/widgets/crew_invitation_card.dart';
import 'package:journeyman_jobs/widgets/electrical_components.dart';
import 'package:journeyman_jobs/widgets/jj_skeleton_loader.dart';

/// Screen displaying all crew invitations for the current user
///
/// This screen shows:
/// - Pending invitations with accept/decline actions
/// - Past invitations (accepted, declined, expired)
/// - Real-time updates when invitations change
/// - Electrical themed UI with circuit patterns
class CrewInvitationsScreen extends StatefulWidget {
  const CrewInvitationsScreen({super.key});

  @override
  State<CrewInvitationsScreen> createState() => _CrewInvitationsScreenState();
}

class _CrewInvitationsScreenState extends State<CrewInvitationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final unified.UnifiedCrewService _invitationService = unified.UnifiedCrewService();

  bool _isLoading = true;
  List<crew_model.CrewInvitation> allInvitations = [];
  List<crew_model.CrewInvitation> _pendingInvitations = [];
  List<crew_model.CrewInvitation> _pastInvitations = [];
  Map<String, bool> loadingStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: AppTheme.durationElectricalSlide,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController.forward();
    _loadInvitations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadInvitations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<UserModel>(context, listen: false);
      final List<unified.CrewInvitation> uInvitations = await _invitationService.getInvitationsForUser(user.uid);
 
      if (!mounted) return;
 
      // Convert unified service invitations to local model type expected by widgets
      final List<crew_model.CrewInvitation> modelInvitations = uInvitations.map((u) {
        return crew_model.CrewInvitation(
          id: u.id,
          crewId: u.crewId,
          inviterId: u.inviterId,
          inviteeId: u.inviteeId,
          status: crew_model.CrewInvitationStatus.values.firstWhere(
            (e) => e.toString().split('.').last == u.status.name,
            orElse: () => crew_model.CrewInvitationStatus.pending,
          ),
          createdAt: Timestamp.fromDate(u.createdAt),
          updatedAt: Timestamp.fromDate(u.updatedAt),
          expiresAt: Timestamp.fromDate(u.expiresAt),
          message: u.message,
          crewName: u.crewName,
          inviterName: u.inviterName,
          inviteeName: u.inviteeName,
          jobDetails: u.jobDetails,
        );
      }).toList();
 
      setState(() {
        allInvitations = modelInvitations;
        _pendingInvitations = modelInvitations
            .where((inv) => inv.status == crew_model.CrewInvitationStatus.pending && !inv.isExpired)
            .toList();
        _pastInvitations = modelInvitations
            .where((inv) => inv.status != crew_model.CrewInvitationStatus.pending || inv.isExpired)
            .toList();
        _isLoading = false;
      });

      // Start slide animation after data loads
      _slideController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load invitations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeController,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Crew Invitations',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppTheme.white,
        ),
      ),
      backgroundColor: AppTheme.primaryNavy,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppTheme.white),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.accentCopper,
        labelColor: AppTheme.accentCopper,
        unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
        labelStyle: AppTheme.buttonMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTheme.buttonMedium,
        tabs: [
          Tab(
            text: 'Pending',
            icon: Icon(Icons.pending_actions, size: AppTheme.iconSm),
          ),
          Tab(
            text: 'Past',
            icon: Icon(Icons.history, size: AppTheme.iconSm),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPendingInvitations(),
        _buildPastInvitations(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          // Skeleton for invitation cards
          for (int i = 0; i < 3; i++) ...[
            JJSkeletonLoader(
              width: double.infinity,
              height: 180,
              borderRadius: AppTheme.radiusLg,
              showCircuitPattern: true,
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingInvitations() {
    if (_pendingInvitations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: 'No Pending Invitations',
        subtitle: 'You don\'t have any crew invitations waiting for your response',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      color: AppTheme.accentCopper,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeOut,
        )),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          itemCount: _pendingInvitations.length,
          itemBuilder: (context, index) {
            final invitation = _pendingInvitations[index];
            final isLoading = loadingStates[invitation.id] ?? false;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(
                bottom: index == _pendingInvitations.length - 1
                    ? AppTheme.spacingXxl
                    : AppTheme.spacingSm,
              ),
              child: CrewInvitationCard(
                invitation: invitation,
                showActions: true,
                isLoading: isLoading,
                onAccept: () => _handleAcceptInvitation(invitation),
                onDecline: () => _handleDeclineInvitation(invitation),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPastInvitations() {
    if (_pastInvitations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_outlined,
        title: 'No Past Invitations',
        subtitle: 'Your invitation history will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      color: AppTheme.accentCopper,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        itemCount: _pastInvitations.length,
        itemBuilder: (context, index) {
          final invitation = _pastInvitations[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              bottom: index == _pastInvitations.length - 1
                  ? AppTheme.spacingXxl
                  : AppTheme.spacingSm,
            ),
            child: CrewInvitationCard(
              invitation: invitation,
              showActions: invitation.status == crew_model.CrewInvitationStatus.accepted ||
                           invitation.status == crew_model.CrewInvitationStatus.declined,
              onAccept: invitation.status == crew_model.CrewInvitationStatus.accepted
                  ? () => _navigateToCrew(invitation.crewId)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Electrical background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentCopper.withValues(alpha: 0.1),
                    AppTheme.primaryNavy.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.textLight,
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            Text(
              title,
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppTheme.spacingSm),

            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAcceptInvitation(crew_model.CrewInvitation invitation) async {
    final user = Provider.of<UserModel>(context, listen: false);

    setState(() {
      loadingStates[invitation.id] = true;
    });

    try {
      await _invitationService.acceptInvitation(invitation.id, user.uid);

      if (!mounted) return;

      _showSuccessSnackBar('Invitation accepted! You\'ve joined ${invitation.crewName}');
      _loadInvitations(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to accept invitation: $e');
    } finally {
      if (mounted) {
        setState(() {
          loadingStates[invitation.id] = false;
        });
      }
    }
  }

  Future<void> _handleDeclineInvitation(crew_model.CrewInvitation invitation) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Decline Invitation',
      content: 'Are you sure you want to decline the invitation to join ${invitation.crewName}?',
      confirmText: 'Decline',
      cancelText: 'Cancel',
      isDestructive: false,
    );

    if (!confirmed) return;

    final user = Provider.of<UserModel>(context, listen: false);

    setState(() {
      loadingStates[invitation.id] = true;
    });

    try {
      await _invitationService.declineInvitation(invitation.id, user.uid);

      if (!mounted) return;

      _showSuccessSnackBar('Invitation declined');
      _loadInvitations(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to decline invitation: $e');
    } finally {
      if (mounted) {
        setState(() {
          loadingStates[invitation.id] = false;
        });
      }
    }
  }

  void _navigateToCrew(String crewId) {
    // Navigate to crew details screen
    // This would typically use the app's navigation system
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDestructive ? AppTheme.errorRed : AppTheme.accentCopper,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.white, size: 20),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(child: Text(message)),
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
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: AppTheme.white, size: 20),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(child: Text(message)),
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
  }
}