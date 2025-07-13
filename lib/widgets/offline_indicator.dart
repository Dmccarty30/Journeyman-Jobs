import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../design_system/app_theme.dart';
import '../services/connectivity_service.dart';
import '../services/resilient_firestore_service.dart';

/// Widget that displays connectivity status and offline indicators
/// 
/// Shows a persistent banner when offline and provides sync controls
/// when connection is restored. Integrates with caching for offline-first UX.
class OfflineIndicator extends StatelessWidget {
  /// Whether to show the indicator persistently when online
  final bool showWhenOnline;
  
  /// Custom height for the indicator
  final double? height;
  
  /// Whether to include sync controls
  final bool showSyncControls;
  
  const OfflineIndicator({
    super.key,
    this.showWhenOnline = false,
    this.height,
    this.showSyncControls = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        // Hide indicator when online unless explicitly requested
        if (connectivity.isOnline && !showWhenOnline && !connectivity.wasOffline) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: height ?? _getIndicatorHeight(connectivity),
          child: _buildIndicatorContent(context, connectivity),
        );
      },
    );
  }

  /// Calculate indicator height based on connectivity state
  double _getIndicatorHeight(ConnectivityService connectivity) {
    if (!connectivity.isOnline) return 56.0; // Offline - full height
    if (connectivity.wasOffline) return 48.0; // Recently offline - medium height
    return 32.0; // Online status - minimal height
  }

  /// Build the main indicator content
  Widget _buildIndicatorContent(BuildContext context, ConnectivityService connectivity) {
    if (!connectivity.isOnline) {
      return _buildOfflineIndicator(context, connectivity);
    } else if (connectivity.wasOffline) {
      return _buildReconnectedIndicator(context, connectivity);
    } else {
      return _buildOnlineIndicator(context, connectivity);
    }
  }

  /// Build offline state indicator
  Widget _buildOfflineIndicator(BuildContext context, ConnectivityService connectivity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.errorRed,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              Icons.cloud_off,
              color: AppTheme.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You\'re offline',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Using cached data • Limited functionality',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildRefreshButton(context, connectivity),
          ],
        ),
      ),
    );
  }

  /// Build reconnected state indicator  
  Widget _buildReconnectedIndicator(BuildContext context, ConnectivityService connectivity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.successGreen,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              Icons.cloud_done,
              color: AppTheme.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Back online • ${connectivity.connectionType}',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (connectivity.offlineDurationMinutes != null)
                    Text(
                      'Offline for ${connectivity.offlineDurationMinutes} min',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (showSyncControls) _buildSyncButton(context),
            const SizedBox(width: 8),
            _buildDismissButton(context),
          ],
        ),
      ),
    );
  }

  /// Build online state indicator (minimal)
  Widget _buildOnlineIndicator(BuildContext context, ConnectivityService connectivity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppTheme.primaryNavy.withValues(alpha: 0.8),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              connectivity.isConnectedToWifi ? Icons.wifi : Icons.signal_cellular_alt,
              color: AppTheme.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              connectivity.connectionType,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.white,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            if (showSyncControls) _buildSyncButton(context, isSmall: true),
          ],
        ),
      ),
    );
  }

  /// Build refresh connectivity button
  Widget _buildRefreshButton(BuildContext context, ConnectivityService connectivity) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => connectivity.refreshConnectivityState(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.refresh,
            color: AppTheme.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Build sync data button
  Widget _buildSyncButton(BuildContext context, {bool isSmall = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _performSync(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 12,
            vertical: isSmall ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: AppTheme.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sync,
                color: AppTheme.white,
                size: isSmall ? 14 : 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Sync',
                style: (isSmall ? AppTheme.bodySmall : AppTheme.labelSmall).copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build dismiss button
  Widget _buildDismissButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _dismissIndicator(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.close,
            color: AppTheme.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  /// Perform data synchronization
  Future<void> _performSync(BuildContext context) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Syncing data...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.primaryNavy,
        ),
      );

      // Trigger cache refresh and data sync
      final resilientService = ResilientFirestoreService();
      await Future.wait([
        resilientService.getCachedPopularJobs(),
        resilientService.getCachedLocals(),
        resilientService.clearCache(),
      ]);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.white, size: 16),
                const SizedBox(width: 12),
                const Text('Data synced successfully'),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppTheme.white, size: 16),
                const SizedBox(width: 12),
                Text('Sync failed: ${e.toString()}'),
              ],
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  /// Dismiss the connectivity indicator
  void _dismissIndicator(BuildContext context) {
    final connectivity = context.read<ConnectivityService>();
    // Reset the wasOffline flag to hide the indicator
    connectivity.resetOfflineFlag();
  }
}

/// Compact offline indicator for app bars
class CompactOfflineIndicator extends StatelessWidget {
  const CompactOfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (connectivity.isOnline && !connectivity.wasOffline) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: connectivity.isOnline 
                ? AppTheme.successGreen 
                : AppTheme.errorRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                connectivity.isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: AppTheme.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                connectivity.isOnline ? 'Online' : 'Offline',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

