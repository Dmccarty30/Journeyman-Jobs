import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/performance_monitoring_service.dart';
import '../../services/analytics_service.dart';
import '../../design_system/app_theme.dart';

/// Admin-only performance dashboard for monitoring app metrics
class PerformanceDashboard extends StatefulWidget {
  const PerformanceDashboard({super.key});

  @override
  State<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard> {
  Map<String, dynamic> _performanceMetrics = {};
  Map<String, dynamic> _userBehaviorMetrics = {};
  Map<String, dynamic> _costAnalysis = {};
  Map<String, dynamic> _systemHealth = {};
  List<Map<String, dynamic>> _performanceTrends = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _loadAllMetrics();
  }

  /// Check if current user has admin access
  Future<void> _checkAdminAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Authentication required';
        _isLoading = false;
      });
      return;
    }

    // In a real implementation, check user roles/permissions
    // For now, we'll allow access for demonstration
    // You could check against a Firebase function or Firestore document
  }

  /// Load all dashboard metrics
  Future<void> _loadAllMetrics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        AnalyticsService.getPerformanceMetrics(),
        AnalyticsService.getUserBehaviorMetrics(),
        AnalyticsService.getCostAnalysis(),
        AnalyticsService.getSystemHealth(),
        AnalyticsService.getPerformanceTrends(days: 7),
      ]);

      setState(() {
        _performanceMetrics = results[0] as Map<String, dynamic>;
        _userBehaviorMetrics = results[1] as Map<String, dynamic>;
        _costAnalysis = results[2] as Map<String, dynamic>;
        _systemHealth = results[3] as Map<String, dynamic>;
        _performanceTrends = results[4] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load metrics: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        backgroundColor: AppTheme.infoBlue,
        foregroundColor: AppTheme.white,
        actions: [
          IconButton(
            onPressed: _loadAllMetrics,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: TabController(length: 4, vsync: Scaffold.of(context)),
          onTap: (index) => setState(() => _selectedTabIndex = index),
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.white.withOpacity(0.7),
          indicatorColor: AppTheme.warningYellow,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Performance', icon: Icon(Icons.speed)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Costs', icon: Icon(Icons.attach_money)),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading dashboard metrics...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(_error!, style: AppTheme.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllMetrics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: TabController(length: 4, vsync: Scaffold.of(context)),
      children: [
        _buildOverviewTab(),
        _buildPerformanceTab(),
        _buildUsersTab(),
        _buildCostsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Health', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildSystemHealthGrid(),
          const SizedBox(height: 24),
          Text('Key Metrics', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildKeyMetricsGrid(),
          const SizedBox(height: 24),
          Text('Recent Alerts', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildAlertsSection(),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Response Times', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildResponseTimesGrid(),
          const SizedBox(height: 24),
          Text('Cache Performance', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildCachePerformanceCard(),
          const SizedBox(height: 24),
          Text('Performance Trends', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildPerformanceTrendsCard(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Statistics', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildUserStatsGrid(),
          const SizedBox(height: 24),
          Text('Popular Features', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildPopularFeaturesCard(),
          const SizedBox(height: 24),
          Text('Peak Usage Hours', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildPeakUsageCard(),
        ],
      ),
    );
  }

  Widget _buildCostsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cost Overview', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildCostOverviewCard(),
          const SizedBox(height: 24),
          Text('Cost Breakdown', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildCostBreakdownCard(),
          const SizedBox(height: 24),
          Text('Savings Analysis', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildSavingsAnalysisCard(),
        ],
      ),
    );
  }

  Widget _buildSystemHealthGrid() {
    final uptime = _systemHealth['uptime'] ?? 0.0;
    final responseTime = _systemHealth['responseTime'] ?? 0;
    final errorRate = _systemHealth['errorRate'] ?? 0.0;
    final throughput = _systemHealth['throughput'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard('Uptime', '${uptime.toStringAsFixed(2)}%', 
          uptime > 99.5 ? AppTheme.successGreen : AppTheme.warningYellow, Icons.check_circle),
        _buildMetricCard('Avg Response', '${responseTime}ms', 
          responseTime < 500 ? AppTheme.successGreen : AppTheme.warningYellow, Icons.speed),
        _buildMetricCard('Error Rate', '${errorRate.toStringAsFixed(2)}%', 
          errorRate < 1.0 ? AppTheme.successGreen : AppTheme.errorRed, Icons.error_outline),
        _buildMetricCard('Throughput', '${throughput}/min', AppTheme.infoBlue, Icons.trending_up),
      ],
    );
  }

  Widget _buildKeyMetricsGrid() {
    final avgQueryTime = _performanceMetrics['avgQueryTime'] ?? 0;
    final cacheHitRate = _performanceMetrics['cacheHitRate'] ?? 0.0;
    final activeUsers = _userBehaviorMetrics['activeUsers'] ?? 0;
    final monthlyCost = _costAnalysis['estimatedMonthlyCost'] ?? 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard('Query Time', '${avgQueryTime}ms', 
          avgQueryTime < 500 ? AppTheme.successGreen : AppTheme.warningYellow, Icons.query_stats),
        _buildMetricCard('Cache Hit Rate', '${cacheHitRate.toStringAsFixed(1)}%', 
          cacheHitRate > 70 ? AppTheme.successGreen : AppTheme.warningYellow, Icons.storage),
        _buildMetricCard('Active Users', '$activeUsers', AppTheme.infoBlue, Icons.people),
        _buildMetricCard('Monthly Cost', '\$${monthlyCost.toStringAsFixed(0)}', AppTheme.infoBlue, Icons.attach_money),
      ],
    );
  }

  Widget _buildResponseTimesGrid() {
    final loadTimes = _performanceMetrics['loadTimes'] as Map<String, dynamic>? ?? {};
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: loadTimes.length,
      itemBuilder: (context, index) {
        final entry = loadTimes.entries.elementAt(index);
        final screenName = entry.key.replaceAll('_', ' ').toUpperCase();
        final time = entry.value as int;
        
        return _buildMetricCard(
          screenName,
          '${time}ms',
          time < 1000 ? AppTheme.successGreen : AppTheme.warningYellow,
          Icons.timer,
        );
      },
    );
  }

  Widget _buildCachePerformanceCard() {
    final cachePerf = _systemHealth['cachePerformance'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: AppTheme.infoBlue),
                const SizedBox(width: 8),
                Text('Cache Performance', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressIndicator('Hit Rate', cachePerf['hit_rate'] ?? 0.0, '%'),
            const SizedBox(height: 8),
            _buildProgressIndicator('Memory Usage', cachePerf['memory_usage'] ?? 0.0, '%'),
            const SizedBox(height: 8),
            _buildProgressIndicator('Miss Rate', cachePerf['miss_rate'] ?? 0.0, '%'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatsGrid() {
    final totalUsers = _userBehaviorMetrics['totalUsers'] ?? 0;
    final activeUsers = _userBehaviorMetrics['activeUsers'] ?? 0;
    final newUsers = _userBehaviorMetrics['newUsers'] ?? 0;
    final retentionRate = _userBehaviorMetrics['retentionRate'] ?? 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard('Total Users', '$totalUsers', AppTheme.infoBlue, Icons.people),
        _buildMetricCard('Active Users', '$activeUsers', AppTheme.successGreen, Icons.people_alt),
        _buildMetricCard('New Users', '$newUsers', AppTheme.warningYellow, Icons.person_add),
        _buildMetricCard('Retention', '${retentionRate.toStringAsFixed(1)}%', 
          retentionRate > 60 ? AppTheme.successGreen : AppTheme.warningYellow, Icons.trending_up),
      ],
    );
  }

  Widget _buildPopularFeaturesCard() {
    final features = _performanceMetrics['popularFeatures'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppTheme.warningYellow),
                const SizedBox(width: 8),
                Text('Feature Usage', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...features.entries.map((entry) {
              final featureName = entry.key.replaceAll('_', ' ').toUpperCase();
              final usage = entry.value as int;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildProgressIndicator(featureName, usage.toDouble(), '% usage'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCostOverviewCard() {
    final monthlyCost = _costAnalysis['estimatedMonthlyCost'] ?? 0.0;
    final savings = _costAnalysis['costTrends']?['savings'] ?? 0.0;
    final totalSavings = _costAnalysis['totalSavings'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: AppTheme.successGreen),
                const SizedBox(width: 8),
                Text('Cost Summary', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCostSummaryItem('Monthly Cost', '\$${monthlyCost.toStringAsFixed(2)}', AppTheme.infoBlue),
                ),
                Expanded(
                  child: _buildCostSummaryItem('Monthly Savings', '\$${savings.toStringAsFixed(2)}', AppTheme.successGreen),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCostSummaryItem('Total Savings', '\$${totalSavings.toStringAsFixed(2)}', AppTheme.successGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection() {
    final alerts = _systemHealth['alerts'] as List<dynamic>? ?? [];
    
    if (alerts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successGreen),
              const SizedBox(width: 8),
              Text('No active alerts', style: AppTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    return Column(
      children: alerts.map((alert) {
        final alertData = alert as Map<String, dynamic>;
        final type = alertData['type'] as String? ?? 'info';
        final message = alertData['message'] as String? ?? '';
        
        Color alertColor = AppTheme.infoBlue;
        IconData alertIcon = Icons.info;
        
        switch (type) {
          case 'warning':
            alertColor = AppTheme.warningYellow;
            alertIcon = Icons.warning;
            break;
          case 'error':
            alertColor = AppTheme.errorRed;
            alertIcon = Icons.error;
            break;
        }

        return Card(
          child: ListTile(
            leading: Icon(alertIcon, color: alertColor),
            title: Text(message),
            subtitle: Text('Type: ${type.toUpperCase()}'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // In real implementation, dismiss alert
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceTrendsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppTheme.infoBlue),
                const SizedBox(width: 8),
                Text('7-Day Performance Trends', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Performance trends chart would be displayed here\n'
                  '(${_performanceTrends.length} data points available)',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakUsageCard() {
    final peakHours = _performanceMetrics['peakUsageHours'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.infoBlue),
                const SizedBox(width: 8),
                Text('Peak Usage Hours', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...peakHours.entries.map((entry) {
              final hour = entry.key;
              final usage = entry.value as int;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 60, child: Text(hour, style: AppTheme.bodyMedium)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: usage / 100.0,
                        backgroundColor: AppTheme.lightGray,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.infoBlue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$usage%', style: AppTheme.bodySmall),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCostBreakdownCard() {
    final breakdown = _costAnalysis['costBreakdown'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppTheme.infoBlue),
                const SizedBox(width: 8),
                Text('Cost Breakdown', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...breakdown.entries.map((entry) {
              final service = entry.key.replaceAll('_', ' ').toUpperCase();
              final cost = entry.value as double;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(service, style: AppTheme.bodyMedium),
                    Text('\$${cost.toStringAsFixed(2)}', style: AppTheme.bodyMedium),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsAnalysisCard() {
    final optimizationImpact = _costAnalysis['costTrends']?['optimization_impact'] ?? 0.0;
    final baselineCost = _costAnalysis['baselineCost'] ?? 0.0;
    final currentCost = _costAnalysis['estimatedMonthlyCost'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: AppTheme.successGreen),
                const SizedBox(width: 8),
                Text('Optimization Impact', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressIndicator('Cost Reduction', optimizationImpact, '%'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Before Optimization:', style: AppTheme.bodyMedium),
                Text('\$${baselineCost.toStringAsFixed(2)}', style: AppTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Cost:', style: AppTheme.bodyMedium),
                Text('\$${currentCost.toStringAsFixed(2)}', 
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.successGreen)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: AppTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(value, style: AppTheme.titleLarge.copyWith(color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.bodyMedium),
            Text('${value.toStringAsFixed(1)}$suffix', style: AppTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (value / 100).clamp(0.0, 1.0),
          backgroundColor: AppTheme.lightGray,
          valueColor: AlwaysStoppedAnimation<Color>(
            value > 75 ? AppTheme.successGreen : 
            value > 50 ? AppTheme.warningYellow : AppTheme.errorRed,
          ),
        ),
      ],
    );
  }

  Widget _buildCostSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.titleLarge.copyWith(color: color)),
      ],
    );
  }
}