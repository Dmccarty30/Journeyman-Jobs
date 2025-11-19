import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tailboard_theme.dart';
import '../../providers/feed_filter_provider.dart';

class FeedSortOptionsDialog extends ConsumerWidget {
  const FeedSortOptionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(feedFilterProvider);
    final notifier = ref.read(feedFilterProvider.notifier);

    return Dialog(
      backgroundColor: TailboardTheme.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
      ),
      child: Container(
        padding: const EdgeInsets.all(TailboardTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort Feed',
                  style: TailboardTheme.headingMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TailboardTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: TailboardTheme.spacingM),
            _SortOption(
              title: 'Most Recent',
              subtitle: 'Show newest posts first',
              icon: Icons.access_time,
              isSelected: currentFilter.sortOption == FeedSortOption.recent,
              onTap: () {
                notifier.setSortOption(FeedSortOption.recent);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: TailboardTheme.spacingS),
            _SortOption(
              title: 'Most Popular',
              subtitle: 'Show posts with most reactions',
              icon: Icons.trending_up,
              isSelected: currentFilter.sortOption == FeedSortOption.popular,
              onTap: () {
                notifier.setSortOption(FeedSortOption.popular);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: TailboardTheme.spacingS),
            _SortOption(
              title: 'Oldest First',
              subtitle: 'Show oldest posts first',
              icon: Icons.history,
              isSelected: currentFilter.sortOption == FeedSortOption.oldest,
              onTap: () {
                notifier.setSortOption(FeedSortOption.oldest);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? TailboardTheme.copper.withValues(alpha: 0.1)
          : TailboardTheme.backgroundDark,
      borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.all(TailboardTheme.spacingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
            border: Border.all(
              color: isSelected
                  ? TailboardTheme.copper
                  : TailboardTheme.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? TailboardTheme.copper
                      : TailboardTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? TailboardTheme.textPrimary
                      : TailboardTheme.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: TailboardTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TailboardTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? TailboardTheme.copper
                            : TailboardTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TailboardTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: TailboardTheme.copper,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
