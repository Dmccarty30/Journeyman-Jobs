import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/riverpod/app_state_riverpod_provider.dart';
import '../design_system/app_theme.dart';

/// Connection status indicator that shows current connectivity state
class ConnectionStatusIndicator extends ConsumerWidget {
  final bool showLabel;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const ConnectionStatusIndicator({
    super.key,
    this.showLabel = true,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityServiceProvider);
    final isOnline = connectivity.isOnline;
    final connectionType = connectivity.connectionType;

    final color = isOnline ? AppTheme.successGreen : AppTheme.errorRed;
    final icon = isOnline
        ? (connectivity.isConnectedToWifi ? Icons.wifi : Icons.signal_cellular_4_bar)
        : Icons.wifi_off;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              isOnline ? connectionType : 'Offline',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Offline banner that appears when the app is offline
class OfflineBanner extends ConsumerWidget {
  final Widget child;
  final bool showSyncButton;

  const OfflineBanner({
    super.key,
    required this.child,
    this.showSyncButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityServiceProvider);
    final offlineService = ref.watch(offlineDataServiceProvider);

    return Column(
      children: [
        if (connectivity.isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.warningOrange.shade100,
            child: Row(
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 20,
                  color: AppTheme.warningOrange.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'re offline. Some features may be limited.',
                    style: TextStyle(
                      color: AppTheme.warningOrange.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (showSyncButton)
                  TextButton(
                    onPressed: connectivity.isOnline && !offlineService.isSyncing
                        ? () => offlineService.performSync()
                        : null,
                    child: Text(
                      connectivity.isOnline ? 'Sync' : 'Waiting...',
                      style: TextStyle(
                        color: AppTheme.warningOrange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}

/// Data freshness indicator showing how old the cached data is
class DataFreshnessIndicator extends StatelessWidget {
  final DateTime? lastSync;
  final bool isOfflineData;
  final VoidCallback? onRefresh;

  const DataFreshnessIndicator({
    super.key,
    this.lastSync,
    this.isOfflineData = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (lastSync == null && !isOfflineData) return const SizedBox.shrink();

    final now = DateTime.now();
    final age = lastSync != null ? now.difference(lastSync!) : null;

    String freshnessText;
    Color color;
    IconData icon;

    if (isOfflineData) {
      freshnessText = 'Offline data';
      color = AppTheme.warningOrange;
      icon = Icons.offline_bolt;
    } else if (age != null) {
      if (age.inMinutes < 5) {
        freshnessText = 'Just updated';
        color = AppTheme.successGreen;
        icon = Icons.check_circle;
      } else if (age.inHours < 1) {
        freshnessText = '${age.inMinutes}m ago';
        color = AppTheme.infoBlue;
        icon = Icons.access_time;
      } else if (age.inDays < 1) {
        freshnessText = '${age.inHours}h ago';
        color = AppTheme.warningOrange;
        icon = Icons.schedule;
      } else {
        freshnessText = '${age.inDays}d ago';
        color = AppTheme.errorRed;
        icon = Icons.warning;
      }
    } else {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onRefresh,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              freshnessText,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.refresh,
                size: 12,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sync progress indicator with circular progress
class SyncProgressIndicator extends ConsumerWidget {
  final bool showLabel;
  final double size;

  const SyncProgressIndicator({
    super.key,
    this.showLabel = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineService = ref.watch(offlineDataServiceProvider);
    return StreamBuilder<double>(
      stream: offlineService.syncProgressStream,
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        final isSyncing = offlineService.isSyncing;

        if (!isSyncing && progress == 0.0) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: isSyncing ? progress : null,
                strokeWidth: 2,
                backgroundColor: AppTheme.mediumGray.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                isSyncing ? 'Syncing... ${(progress * 100).round()}%' : 'Sync complete',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Pending changes indicator showing number of unsynced changes
class PendingChangesIndicator extends ConsumerWidget {
  final VoidCallback? onTap;

  const PendingChangesIndicator({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineService = ref.watch(offlineDataServiceProvider);
    final pendingCount = offlineService.pendingChangesCount;

    if (pendingCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.infoBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sync_problem,
              size: 16,
              color: AppTheme.infoBlue,
            ),
            const SizedBox(width: 4),
            Text(
              '$pendingCount pending',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.infoBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Comprehensive sync status widget combining multiple indicators
class SyncStatusWidget extends ConsumerWidget {
  final bool compact;
  final VoidCallback? onSyncPressed;
  final VoidCallback? onPendingPressed;

  const SyncStatusWidget({
    super.key,
    this.compact = false,
    this.onSyncPressed,
    this.onPendingPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityServiceProvider);
    final offlineService = ref.watch(offlineDataServiceProvider);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ConnectionStatusIndicator(showLabel: false),
          const SizedBox(width: 8),
          if (offlineService.isSyncing)
            const SyncProgressIndicator(showLabel: false)
          else
            PendingChangesIndicator(onTap: onPendingPressed),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Sync Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const ConnectionStatusIndicator(),
              ],
            ),
            const SizedBox(height: 12),

            // Last sync time
            if (offlineService.lastSyncTime != null)
              DataFreshnessIndicator(
                lastSync: offlineService.lastSyncTime,
                onRefresh: connectivity.isOnline ? onSyncPressed : null,
              ),

            const SizedBox(height: 8),

            // Sync progress or pending changes
            if (offlineService.isSyncing)
              const SyncProgressIndicator()
            else if (offlineService.pendingChangesCount > 0)
              PendingChangesIndicator(onTap: onPendingPressed),

            // Manual sync button
            if (!offlineService.isSyncing && connectivity.isOnline) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSyncPressed ?? () => offlineService.performSync(),
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Sync Now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Storage usage indicator showing offline data usage
class StorageUsageIndicator extends ConsumerWidget {
  final bool showDetails;

  const StorageUsageIndicator({
    super.key,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineService = ref.watch(offlineDataServiceProvider);
    return FutureBuilder<Map<String, dynamic>>(
      future: offlineService.getStorageStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        final usedMB = double.parse('${stats['storage_size_mb']}');
        final maxMB = stats['max_size_mb'] as int;
        final percentage = (usedMB / maxMB).clamp(0.0, 1.0);

        Color color;
        if (percentage < 0.5) {
          color = AppTheme.successGreen;
        } else if (percentage < 0.8) {
          color = AppTheme.warningOrange;
        } else {
          color = AppTheme.errorRed;
        }

        if (!showDetails) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storage,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  '${usedMB.toStringAsFixed(1)}MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storage, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Storage Usage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress bar
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: AppTheme.mediumGray.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${usedMB.toStringAsFixed(1)} MB used',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${maxMB} MB limit',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Data breakdown
                Text(
                  'Jobs: ${stats['jobs_count']} • Locals: ${stats['locals_count']} • Search: ${stats['search_history_count']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mediumGray.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Offline mode toggle switch
class OfflineModeToggle extends ConsumerWidget {
  final ValueChanged<bool>? onChanged;

  const OfflineModeToggle({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineService = ref.watch(offlineDataServiceProvider);
    final isOfflineDataAvailable = offlineService.isOfflineDataAvailable;

    return ListTile(
      leading: Icon(
        isOfflineDataAvailable ? Icons.offline_bolt : Icons.cloud_off,
        color: isOfflineDataAvailable ? AppTheme.successGreen : AppTheme.mediumGray,
      ),
      title: const Text('Offline Mode'),
      subtitle: Text(
        isOfflineDataAvailable ? 'Offline data available (24h)' : 'No offline data available',
      ),
      trailing: Switch(
        value: isOfflineDataAvailable,
        onChanged: onChanged,
      ),
    );
  }
}
