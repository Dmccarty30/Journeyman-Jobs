import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../providers/crews_riverpod_provider.dart';
import '../../../widgets/electrical_components.dart';
import '../../../widgets/crew_invitation_card.dart';
import '../../../models/crew_model.dart';

/// Screen for managing crew invitations
///
/// This screen provides:
/// - View pending invitations
/// - Accept/decline invitations
/// - Send new invitations
/// - Invitation history
class CrewInvitationsScreen extends ConsumerStatefulWidget {
  const CrewInvitationsScreen({super.key});

  @override
  ConsumerState<CrewInvitationsScreen> createState() => _CrewInvitationsScreenState();
}

class _CrewInvitationsScreenState extends ConsumerState<CrewInvitationsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(auth_providers.currentUserProvider);

    if (currentUser == null) {
      return _buildSignInPrompt();
    }

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Text(
          'Crew Invitations',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: Column(
        children: [
          // Header with invite button
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invitations',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your crew invitations and requests',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                JJElectricalButton(
                  text: 'Send Invitation',
                  onPressed: _showSendInvitationDialog,
                  width: 160,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tabs for different invitation types
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  // Tab bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      labelColor: AppTheme.textSecondary,
                      unselectedLabelColor: AppTheme.textSecondary,
                      indicatorColor: AppTheme.accentCopper,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(
                          text: 'Pending',
                          icon: Icon(Icons.pending),
                        ),
                        Tab(
                          text: 'Sent',
                          icon: Icon(Icons.send),
                        ),
                        Tab(
                          text: 'History',
                          icon: Icon(Icons.history),
                        ),
                      ],
                    ),
                  ),

                  // Tab views
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPendingInvitations(),
                        _buildSentInvitations(),
                        _buildInvitationHistory(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                child: Icon(
                  Icons.mail_outline,
                  size: 48,
                  color: AppTheme.textLight,
                ),
              ),

            const SizedBox(height: AppTheme.spacingLg),

            Text(
              'Sign In Required',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppTheme.spacingSm),

            Text(
              'Please sign in to view and manage crew invitations',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppTheme.spacingLg),

            JJElectricalButton(
              text: 'Sign In',
              onPressed: () {
                // Navigate to sign in screen
                Navigator.of(context).pushReplacementNamed('/auth');
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingInvitations() {
    return Consumer(
      builder: (context, ref) {
        final pendingInvitations = ref.watch(pendingInvitationsProvider);

        if (pendingInvitations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox_outlined,
            title: 'No Pending Invitations',
            message: 'You don\'t have any pending crew invitations',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: pendingInvitations.length,
          itemBuilder: (context, index) {
            final invitation = pendingInvitations[index];
            return CrewInvitationCard(
              invitation: invitation,
              onAccept: () => _handleInvitationResponse(invitation, true),
              onDecline: () => _handleInvitationResponse(invitation, false),
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ).slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      },
    );
  }

  Widget _buildSentInvitations() {
    return Consumer(
      builder: (context, ref) {
        final sentInvitations = ref.watch(sentInvitationsProvider);

        if (sentInvitations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.send_outlined,
            title: 'No Sent Invitations',
            message: 'You haven\'t sent any crew invitations yet',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: sentInvitations.length,
          itemBuilder: (context, index) {
            final invitation = sentInvitations[index];
            return CrewInvitationCard(
              invitation: invitation,
              showActions: false, // Sent invitations can't be cancelled
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ).slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      },
    );
  }

  Widget _buildInvitationHistory() {
    return Consumer(
      builder: (context, ref) {
        final invitationHistory = ref.watch(invitationHistoryProvider);

        if (invitationHistory.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_outlined,
            title: 'No Invitation History',
            message: 'Your crew invitation history will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: invitationHistory.length,
          itemBuilder: (context, index) {
            final invitation = invitationHistory[index];
            return CrewInvitationCard(
              invitation: invitation,
              showActions: false, // History items are read-only
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ).slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            ),

            const SizedBox(height: AppTheme.spacingSm),

            Text(
              message,
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

  void _handleInvitationResponse(dynamic invitation, bool accept) async {
    try {
      if (accept) {
        // Accept invitation logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation accepted!'),
            backgroundColor: AppTheme.electricalSuccess,
          ),
        );
      } else {
        // Decline invitation logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation declined'),
            backgroundColor: AppTheme.mediumGray,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error responding to invitation: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _showSendInvitationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Crew Invitation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            JJElectricalTextField(
              hintText: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            JJElectricalTextField(
              hintText: 'Message (optional)',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          JJElectricalButton(
            text: 'Send',
            onPressed: () {
              Navigator.of(context).pop();
              // Send invitation logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invitation sent!'),
                  backgroundColor: AppTheme.electricalSuccess,
                ),
              );
            },
            width: 100,
          ),
        ],
      ),
    );
  }
}