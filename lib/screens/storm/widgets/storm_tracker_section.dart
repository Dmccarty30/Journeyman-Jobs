import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../models/storm_track.dart';
import '../services/storm_tracking_service.dart';
import 'storm_track_form.dart';
import 'package:intl/intl.dart';

import 'storm_track_summary_sheet.dart';

class StormTrackerSection extends StatefulWidget {
  const StormTrackerSection({super.key});

  @override
  State<StormTrackerSection> createState() => _StormTrackerSectionState();
}

class _StormTrackerSectionState extends State<StormTrackerSection> {
  final StormTrackingService _trackingService = StormTrackingService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.shadowMd],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: AppTheme.primaryNavy,
                    size: AppTheme.iconMd,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'My Storm Tracks',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              JJButton(
                text: 'Add Track',
                icon: Icons.add,
                onPressed: () => _showTrackForm(context),
                variant: JJButtonVariant.primary,
                size: JJButtonSize.small,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Stats Summary
          FutureBuilder<Map<String, dynamic>>(
            future: _trackingService.getStormStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.accentCopper)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final stats = snapshot.data!;
              return Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Earnings',
                        '\$${(stats['totalEarnings'] as double).toStringAsFixed(0)}'),
                    _buildStatItem('Days Worked', '${stats['totalDays']}'),
                    _buildStatItem('Storms', '${stats['stormCount']}'),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Recent Tracks List
          StreamBuilder<List<StormTrack>>(
            stream: _trackingService.getStormTracks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Text(
                      'No storm tracks recorded yet.',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.textSecondary),
                    ),
                  ),
                );
              }

              final tracks = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tracks.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      track.stormType.isNotEmpty
                          ? track.stormType
                          : 'Storm Work',
                      style: AppTheme.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${track.contractor} • ${track.utility}'),
                        Text(
                          '${DateFormat('MMM d, y').format(track.startDate)} - ${track.endDate != null ? DateFormat('MMM d, y').format(track.endDate!) : 'Ongoing'}',
                          style: AppTheme.bodySmall
                              .copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         IconButton(
                          icon: const Icon(Icons.calculate_outlined, size: 22, color: AppTheme.successGreen),
                          tooltip: 'View Pay Summary',
                          onPressed: () => _showSummarySheet(context, track),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _showTrackForm(context, track: track),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  void _showTrackForm(BuildContext context, {StormTrack? track}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
          ),
          child:
              StormTrackForm(track: track, scrollController: scrollController),
        ),
      ),
    );
  }

  void _showSummarySheet(BuildContext context, StormTrack track) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StormTrackSummarySheet(track: track),
    );
  }
}
