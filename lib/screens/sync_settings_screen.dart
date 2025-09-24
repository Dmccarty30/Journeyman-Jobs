import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../design_system/app_theme.dart';
import '../services/connectivity_service.dart';
import '../services/offline_data_service.dart';
import '../widgets/offline_indicators.dart';

/// Screen for managing sync and offline data settings
class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync & Offline'),
        elevation: 0,
        actions: [
          Consumer<OfflineDataService>(
            builder: (context, offlineService, child) {
              return IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showSyncInfo(context, offlineService),
              );
            },
          ),
        ],
      ),
      body: Consumer2<ConnectivityService, OfflineDataService>(
        builder: (context, connectivity, offlineService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection Status Card
                _buildConnectionStatusCard(connectivity),
                
                const SizedBox(height: 16),
                
                // Sync Status Card
                SyncStatusWidget(
                  onSyncPressed: () => _performSync(offlineService),
                  onPendingPressed: () => _showPendingChanges(context, offlineService),
                ),
                
                const SizedBox(height: 16),
                
                // Sync Strategy Settings
                _buildSyncStrategyCard(offlineService),
                
                const SizedBox(height: 16),
                
                // Storage Usage
                const StorageUsageIndicator(showDetails: true),
                
                const SizedBox(height: 16),
                
                // Advanced Settings
                _buildAdvancedSettingsCard(context, offlineService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatusCard(ConnectivityService connectivity) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  connectivity.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: connectivity.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Connection Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const ConnectionStatusIndicator(),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Status',
                    connectivity.isOnline ? 'Online' : 'Offline',
                    connectivity.isOnline ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'Type',
                    connectivity.connectionType,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            if (connectivity.lastOfflineTime != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Last Offline',
                _formatDateTime(connectivity.lastOfflineTime!),
                Colors.orange,
              ),
            ],
            
            if (connectivity.offlineDurationMinutes != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Offline Duration',
                '${connectivity.offlineDurationMinutes} minutes',
                Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStrategyCard(OfflineDataService offlineService) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.sync_alt),
                SizedBox(width: 8),
                Text(
                  'Sync Strategy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Sync Strategy Selection
            _buildSyncStrategyOption(
              offlineService,
              SyncStrategy.immediate,
              'Immediate',
              'Sync as soon as internet is available',
              Icons.flash_on,
            ),
            
            _buildSyncStrategyOption(
              offlineService,
              SyncStrategy.smart,
              'Smart',
              'Intelligent sync based on usage patterns',
              Icons.auto_awesome,
            ),
            
            _buildSyncStrategyOption(
              offlineService,
              SyncStrategy.manual,
              'Manual',
              'Only sync when you tap the sync button',
              Icons.touch_app,
            ),
            
            const SizedBox(height: 16),
            
            // Additional Settings
            _buildSwitchTile(
              'Wi-Fi Only Sync',
              'Only sync when connected to Wi-Fi',
              Icons.wifi,
              true, // Placeholder - would get from service
              (value) => offlineService.configureSyncStrategy(wifiOnly: value),
            ),
            
            _buildSwitchTile(
              'Background Sync',
              'Allow syncing in the background',
              Icons.sync,
              true, // Placeholder - would get from service
              (value) => offlineService.configureSyncStrategy(backgroundSync: value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStrategyOption(
    OfflineDataService offlineService,
    SyncStrategy strategy,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = offlineService.syncStrategy == strategy;
    
    return RadioListTile<SyncStrategy>(
      value: strategy,
      groupValue: offlineService.syncStrategy,
      onChanged: (value) {
        if (value != null) {
          offlineService.configureSyncStrategy(strategy: value);
        }
      },
      title: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle),
      dense: true,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      dense: true,
    );
  }

  Widget _buildAdvancedSettingsCard(BuildContext context, OfflineDataService offlineService) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune),
                SizedBox(width: 8),
                Text(
                  'Advanced Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Storage limit slider
            _buildStorageLimitSlider(offlineService),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSyncLog(context),
                    icon: const Icon(Icons.history),
                    label: const Text('Sync History'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isClearing 
                        ? null 
                        : () => _clearOfflineData(context, offlineService),
                    icon: _isClearing 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.clear_all),
                    label: const Text('Clear Data'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageLimitSlider(OfflineDataService offlineService) {
    return FutureBuilder<Map<String, dynamic>>(
      future: offlineService.getStorageStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final stats = snapshot.data!;
        final maxMB = (stats['max_size_mb'] as int).toDouble();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage Limit',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Slider(
              value: maxMB,
              min: 10,
              max: 500,
              divisions: 49,
              label: '${maxMB.round()} MB',
              onChanged: (value) {
                offlineService.configureSyncStrategy(maxDataSizeMB: value.round());
              },
            ),
            Text(
              'Maximum offline storage: ${maxMB.round()} MB',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  Future<void> _performSync(OfflineDataService offlineService) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Starting sync...')),
      );
      
      final success = await offlineService.performSync(force: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Sync completed successfully' : 'Sync failed'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearOfflineData(BuildContext context, OfflineDataService offlineService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Offline Data'),
        content: const Text(
          'This will remove all cached jobs, locals, and search history. '
          'Your bookmarks and preferences will be preserved. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isClearing = true);
      
      try {
        await offlineService.clearOfflineData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Offline data cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isClearing = false);
        }
      }
    }
  }

  void _showSyncInfo(BuildContext context, OfflineDataService offlineService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sync strategies:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Immediate: Syncs as soon as connected'),
            const Text('• Smart: Syncs based on usage patterns'),
            const Text('• Manual: Only syncs when requested'),
            const SizedBox(height: 16),
            const Text(
              'Offline data is stored for 24 hours and automatically refreshed when online.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPendingChanges(BuildContext context, OfflineDataService offlineService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${offlineService.pendingChangesCount} Pending Changes'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The following changes are waiting to sync:'),
            SizedBox(height: 8),
            Text('• Job bookmarks'),
            Text('• User preferences'),
            Text('• Search history'),
            SizedBox(height: 16),
            Text('These will sync automatically when you\'re online.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (context.read<ConnectivityService>().isOnline)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performSync(offlineService);
              },
              child: const Text('Sync Now'),
            ),
        ],
      ),
    );
  }

  void _showSyncLog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync History'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Text('Recent sync activities:'),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• 2 hours ago - Full sync completed'),
                      Text('• 4 hours ago - Bookmarks synced'),
                      Text('• 6 hours ago - Job data refreshed'),
                      Text('• 1 day ago - Initial offline cache'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}