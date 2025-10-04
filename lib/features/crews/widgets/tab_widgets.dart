import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../providers/crews_riverpod_provider.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed, size: 48, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            selectedCrew != null ? 'Feed for ${selectedCrew.name}' : 'Feed Tab Content',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            selectedCrew != null
                ? 'Team updates and announcements for ${selectedCrew.name} appear here'
                : 'Select a crew to view team updates and announcements',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class JobsTab extends ConsumerWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 48, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            selectedCrew != null ? 'Jobs for ${selectedCrew.name}' : 'Jobs Tab Content',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            selectedCrew != null
                ? 'Shared job opportunities for ${selectedCrew.name} appear here'
                : 'Select a crew to view shared job opportunities',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ChatTab extends ConsumerWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            selectedCrew != null ? 'Chat for ${selectedCrew.name}' : 'Chat Tab Content',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            selectedCrew != null
                ? 'Direct messaging and group chat for ${selectedCrew.name} appear here'
                : 'Select a crew to view direct messaging and group chat',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MembersTab extends ConsumerWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 48, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            selectedCrew != null ? 'Members of ${selectedCrew.name}' : 'Members Tab Content',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            selectedCrew != null
                ? 'Crew member information for ${selectedCrew.name} appears here'
                : 'Select a crew to view crew member information',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}