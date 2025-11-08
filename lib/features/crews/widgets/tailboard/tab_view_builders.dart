// Flutter & Dart imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

// Journeyman Jobs - Absolute imports
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/features/crews/providers/feed_provider.dart';
import 'package:journeyman_jobs/features/crews/providers/jobs_filter_provider.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';

// Tailboard widget imports
import 'stream_chat_theme.dart';
import 'utility_widgets.dart';
import 'card_widgets.dart';

/// Builds the enhanced Feed tab with filters and job cards
class FeedTabBuilder extends ConsumerWidget {
  const FeedTabBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: const FeedEmptyState(),
    );
  }
}

/// Empty state for the Feed tab when no posts are available
class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state illustration
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Central feed icon
                    Icon(
                      Icons.feed_outlined,
                      size: 64,
                      color: AppTheme.primaryNavy.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Empty state title
              Text(
                'No Feed Posts',
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description message
              Text(
                'Start sharing updates, job opportunities, and important announcements with your crew.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              // Call to action
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 20,
                          color: AppTheme.accentCopper,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Get Started',
                          style: TextStyle(
                            color: AppTheme.primaryNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...[
                      '• Create your first post using the + button',
                      '• Share job opportunities with your crew',
                      '• Post safety alerts and important updates',
                      '• Celebrate team achievements and milestones',
                    ].map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Builds the enhanced Jobs tab with job listings
class JobsTabBuilder extends ConsumerWidget {
  const JobsTabBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: const JobsEmptyState(),
    );
  }
}

/// Empty state for the Jobs tab when no jobs are available
class JobsEmptyState extends StatelessWidget {
  const JobsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state illustration
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Central hard hat icon
                    Icon(
                      Icons.engineering,
                      size: 64,
                      color: AppTheme.primaryNavy.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Empty state title
              Text(
                'No Jobs Available',
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description message
              Text(
                'There are currently no job postings for this crew. '
                'Check back later for new opportunities or explore the main job board.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              // Action buttons
              Column(
                children: [
                  // Primary action button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to main job board
                      },
                      icon: const Icon(Icons.work_rounded, size: 20),
                      label: const Text(
                        'EXPLORE JOB BOARD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCopper,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppTheme.accentCopper.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary refresh button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Refresh jobs
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text(
                        'REFRESH',
                        style: TextStyle(
                          color: AppTheme.primaryNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryNavy.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Helpful tips section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 20,
                          color: AppTheme.accentCopper,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Pro Tips',
                          style: TextStyle(
                            color: AppTheme.primaryNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...[
                      '• Set up job alerts to get notified of new opportunities',
                      '• Connect with other crew members for job referrals',
                      '• Update your skills and certifications in your profile',
                    ].map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Builds the enhanced Chat tab with Stream Chat integration
class ChatTabBuilder extends ConsumerWidget {
  const ChatTabBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatClientAsync = ref.watch(streamChatClientProvider);
    final selectedCrew = ref.watch(selectedCrewProvider);

    return chatClientAsync.when(
      data: (client) {
        return StreamChat(
          client: client,
          streamChatThemeData: ElectricalStreamChatTheme.theme,
          child: Container(
            color: Colors.white,
            child: selectedCrew == null
                ? const NoCrewSelectedChat()
                : const ChannelListView(),
          ),
        );
      },
      loading: () => const LoadingStateWidget(),
      error: (error, stack) => ChatErrorState(error: error.toString()),
    );
  }
}

/// Chat channel list view with Stream Chat integration
class ChannelListView extends ConsumerWidget {
  const ChannelListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = StreamChat.of(context).client;
    return StreamChannelListView(
      controller: StreamChannelListController(
        client: client,
      ),
      emptyBuilder: EmptyChatStateBuilder.build,
      errorBuilder: ChatErrorStateBuilder.build,
      loadingBuilder: _buildLoadingState,
      separatorBuilder: _channelSeparator,
    );
  }

  /// Build loading state widget
  static Widget _buildLoadingState(BuildContext context) {
    return const LoadingStateWidget();
  }

  /// Build separator between channels
  static Widget _channelSeparator(BuildContext context, channels, int index) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0));
  }
}

/// Empty chat state when no channels exist
class EmptyChatStateBuilder {
  static Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppTheme.mediumGray.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Chat Channels',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textOnDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Create your first crew channel\nto start collaborating',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat error state builder
class ChatErrorStateBuilder {
  static Widget build(BuildContext context, Object error) {
    return ChatErrorState(error: error.toString());
  }
}

/// Widget for no crew selected in chat
class NoCrewSelectedChat extends StatelessWidget {
  const NoCrewSelectedChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_outlined,
                size: 64,
                color: AppTheme.mediumGray.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Crew Selected',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textOnDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select a crew to start chatting with your team members',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Builds the enhanced Crew tab with member cards
class CrewTabBuilder extends ConsumerWidget {
  const CrewTabBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    if (selectedCrew == null) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_outlined,
                size: 64,
                color: AppTheme.mediumGray.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No crew selected',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.mediumGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final crewMembers = ref.watch(crewMembersProvider(selectedCrew.id));

    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: crewMembers.length,
        itemBuilder: (context, index) {
          final member = crewMembers[index];
          return CrewMemberCard(member: member);
        },
      ),
    );
  }
}

/// Builds the enhanced Tailboard tab with safety cards
class TailboardTabBuilder extends StatelessWidget {
  const TailboardTabBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SafetyCard(
            title: 'Daily Safety Brief',
            description: 'Review today\'s safety protocols and hazards',
            icon: Icons.security,
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          SafetyCard(
            title: 'Job Hazard Analysis',
            description: 'Identify and mitigate potential risks',
            icon: Icons.warning_amber,
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          SafetyCard(
            title: 'Emergency Procedures',
            description: 'Quick access to emergency protocols',
            icon: Icons.emergency,
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          SafetyCard(
            title: 'PPE Requirements',
            description: 'Personal protective equipment checklist',
            icon: Icons.shield,
            color: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }
}

/// Error state widget for chat functionality
class ChatErrorState extends StatelessWidget {
  final String error;

  const ChatErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textOnDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}