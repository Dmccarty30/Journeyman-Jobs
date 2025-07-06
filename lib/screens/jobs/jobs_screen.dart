import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/job_model.dart';


class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  static String routeName = 'jobs';
  static String routePath = '/jobs';

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _powerFlowController;
  late Animation<double> _powerFlowAnimation;
  String _selectedFilter = 'All Jobs';
  String _searchQuery = '';
  bool _showAdvancedFilters = false;

  // Electrical-themed filter categories
  final List<String> _electricalFilterCategories = [
    'All Jobs',
    'Journeyman Lineman',
    'Journeyman Electrician', 
    'Journeyman Wireman',

    'Transmission',
    'Distribution',
    'Substation',
    'Storm Work',

  ];

  @override
  void initState() {
    super.initState();
    _powerFlowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _powerFlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _powerFlowController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _powerFlowController.dispose();
    super.dispose();
  }

  Widget _buildElectricalLoadingIndicator() {
    return AnimatedBuilder(
      animation: _powerFlowAnimation,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Power grid background
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentCopper.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                // Animated power flow
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accentCopper.withOpacity(_powerFlowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Center electrical icon
                Icon(
                  Icons.electrical_services,
                  size: 32,
                  color: AppTheme.primaryNavy,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Connecting to Power Grid...',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildElectricalEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            shape: BoxShape.circle,
            boxShadow: [AppTheme.shadowMd],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Power line tower silhouette
              Icon(
                Icons.electrical_services_outlined,
                size: 60,
                color: AppTheme.primaryNavy.withOpacity(0.3),
              ),
              // Power off indicator
              Positioned(
                bottom: 25,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.textLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OFF',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.white,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          'No Power Jobs Available',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Check back later for new electrical opportunities',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildElectricalFilterButton(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.buttonGradient : null,
          color: isSelected ? null : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: isSelected 
            ? Border.all(color: AppTheme.accentCopper, width: 1)
            : Border.all(color: AppTheme.lightGray, width: 1),
          boxShadow: isSelected ? [AppTheme.shadowSm] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                _getFilterIcon(filter),
                size: 16,
                color: AppTheme.white,
              ),
              const SizedBox(width: AppTheme.spacingXs),
            ],
            Text(
              filter,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Transmission':
        return Icons.electrical_services;
      case 'Distribution':
        return Icons.power_outlined;
      case 'Substation':
        return Icons.electrical_services_outlined;
      case 'Storm Work':
        return Icons.flash_on;
      default:
        return Icons.work;
    }
  }

  Color _getVoltageLevelColor(String? voltageLevel) {
    if (voltageLevel == null) return AppTheme.textSecondary;

    // Since voltage levels are not standard classifications in the trade,
    // we'll return a default color for all cases
    return AppTheme.textSecondary;
  }

  Widget _buildElectricalJobCard(Job job) {
    final voltageColor = _getVoltageLevelColor(job.voltageLevel);
    final isEmergency = job.classification?.toLowerCase().contains('storm') ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.shadowMd],
        border: isEmergency 
          ? Border.all(color: AppTheme.errorRed, width: 2)
          : Border.all(color: AppTheme.accentCopper.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: () => _showElectricalJobDetails(job),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with classification and voltage indicator
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Classification and Local
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isEmergency)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingSm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flash_on,
                                    size: 12,
                                    color: AppTheme.white,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'EMERGENCY',
                                    style: AppTheme.labelSmall.copyWith(
                                      color: AppTheme.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isEmergency) const SizedBox(height: AppTheme.spacingXs),
                          Row(
                            children: [
                              Text(
                                'Local: ',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                job.localNumber?.toString() ?? 'N/A',
                                style: AppTheme.bodyLarge.copyWith(
                                  color: AppTheme.primaryNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            job.classification ?? 'Electrical Worker',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.primaryNavy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right side - Voltage level indicator
                    if (job.voltageLevel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSm,
                          vertical: AppTheme.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: voltageColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(color: voltageColor, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt,
                              size: 14,
                              color: voltageColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job.voltageLevel!,
                              style: AppTheme.labelSmall.copyWith(
                                color: voltageColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingMd),

                // Job details in two columns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJobDetailRow(
                            Icons.access_time,
                            'Posted:',
                            job.datePosted ?? 'Recently',
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          _buildJobDetailRow(
                            Icons.location_on,
                            'Location:',
                            job.location,
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          _buildJobDetailRow(
                            Icons.business,
                            'Company:',
                            job.company,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    // Right column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJobDetailRow(
                            Icons.schedule,
                            'Hours:',
                            job.hours ?? '40hrs',
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          _buildJobDetailRow(
                            Icons.attach_money,
                            'Wage:',
                            job.wage ?? 'Competitive',
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          if (job.perDiem != null)
                            _buildJobDetailRow(
                              Icons.card_giftcard,
                              'Per Diem:',
                              job.perDiem!,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingMd),

                // Action buttons with electrical theme
                Row(
                  children: [
                    Expanded(
                      child: JJSecondaryButton(
                        text: 'View Details',
                        icon: Icons.visibility,
                        onPressed: () => _showElectricalJobDetails(job),
                        height: 42,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: JJPrimaryButton(
                        text: 'Bid Now',
                        icon: Icons.send,
                        onPressed: () => _handleBidNow(job),
                        height: 42,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showElectricalJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return JobDetailsSheet(job: job, scrollController: scrollController);
          },
        );
      },
    );
  }

  void _handleBidNow(Job job) {
    _showBidSubmissionDialog(job);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search Jobs',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by company, location, or classification...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primaryNavy),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
              Navigator.pop(context);
            },
            child: Text('Clear', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: AppTheme.white,
            ),
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showBidSubmissionDialog(Job job) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Submit Bid',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job: ${job.classification ?? 'Electrical Worker'}',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy,
              ),
            ),
            Text(
              'Company: ${job.company}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              'Location: ${job.location}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a message (optional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitBid(job, messageController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCopper,
              foregroundColor: AppTheme.white,
            ),
            child: Text('Submit Bid'),
          ),
        ],
      ),
    );
  }

  void _submitBid(Job job, String message) {
    // Here you would typically submit to your backend/Firestore
    // For now, we'll just show a success message
    JJSnackBar.showSuccess(
      context: context,
      message: 'Bid submitted for ${job.classification}!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: AppTheme.primaryNavy,
            automaticallyImplyLeading: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryNavy,
                      AppTheme.primaryNavy.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Circuit pattern overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ElectricalCircuitPainter(),
                      ),
                    ),
                  ],
                ),
              ),
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppTheme.buttonGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.electrical_services,
                      size: 20,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'Power Jobs',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: AppTheme.white),
                onPressed: () {
                  _showSearchDialog();
                },
              ),
              IconButton(
                icon: Icon(Icons.filter_alt, color: AppTheme.white),
                onPressed: () {
                  setState(() {
                    _showAdvancedFilters = !_showAdvancedFilters;
                  });
                },
              ),
            ],
          ),
        ],
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _electricalFilterCategories
                        .map((filter) => Padding(
                              padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                              child: _buildElectricalFilterButton(filter),
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Advanced filters section
                if (_showAdvancedFilters) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.accentCopper.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tune,
                              color: AppTheme.primaryNavy,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                              'Advanced Filters',
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.primaryNavy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'Search Query: ${_searchQuery.isEmpty ? 'None' : _searchQuery}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _showSearchDialog,
                                icon: Icon(Icons.search, size: 16),
                                label: Text('Search Jobs'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryNavy,
                                  foregroundColor: AppTheme.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacingMd,
                                    vertical: AppTheme.spacingSm,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                  _selectedFilter = 'All Jobs';
                                });
                              },
                              icon: Icon(Icons.clear, size: 16),
                              label: Text('Clear All'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.textLight,
                                foregroundColor: AppTheme.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingMd,
                                  vertical: AppTheme.spacingSm,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],

                // Jobs section header
                Text(
                  _selectedFilter == 'All Jobs' ? 'All Power Jobs' : _selectedFilter,
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingMd),

                // Jobs list with StreamBuilder
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: _buildElectricalLoadingIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.electrical_services_outlined,
                                size: 64,
                                color: AppTheme.errorRed.withOpacity(0.5),
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              Text(
                                'Power Grid Connection Failed',
                                style: AppTheme.headlineSmall.copyWith(
                                  color: AppTheme.errorRed,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              Text(
                                'Unable to load job opportunities',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: _buildElectricalEmptyState());
                      }

                      // Convert Firestore documents to Job objects
                      final jobs = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id;
                        return Job.fromJson(data);
                      }).toList();

                      // Filter jobs based on selected category and search query
                      var filteredJobs = _selectedFilter == 'All Jobs'
                        ? jobs
                        : jobs.where((job) {
                            return job.classification?.contains(_selectedFilter) == true ||
                                   job.voltageLevel == _selectedFilter ||
                                   job.typeOfWork?.contains(_selectedFilter) == true;
                          }).toList();

                      // Apply search filter if search query exists
                      if (_searchQuery.isNotEmpty) {
                        filteredJobs = filteredJobs.where((job) {
                          final query = _searchQuery.toLowerCase();
                          return job.company.toLowerCase().contains(query) ||
                                 job.location.toLowerCase().contains(query) ||
                                 (job.classification?.toLowerCase().contains(query) ?? false) ||
                                 (job.typeOfWork?.toLowerCase().contains(query) ?? false) ||
                                 (job.voltageLevel?.toLowerCase().contains(query) ?? false);
                        }).toList();
                      }

                      if (filteredJobs.isEmpty) {
                        return Center(child: _buildElectricalEmptyState());
                      }

                      return ListView.builder(
                        itemCount: filteredJobs.length,
                        itemBuilder: (context, index) {
                          return _buildElectricalJobCard(filteredJobs[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for electrical circuit patterns
class ElectricalCircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentCopper.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw subtle circuit pattern
    for (int i = 0; i < 5; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * 0.3, y),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.7, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class JobDetailsSheet extends StatelessWidget {
  final Job job;
  final ScrollController scrollController;

  const JobDetailsSheet({
    super.key,
    required this.job,
    required this.scrollController,
  });

  Color _getVoltageLevelColor(String? voltageLevel) {
    if (voltageLevel == null) return AppTheme.textSecondary;

    // Since voltage levels are not standard classifications in the trade,
    // we'll return a default color for all cases
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final voltageColor = _getVoltageLevelColor(job.voltageLevel);
    final isEmergency = job.classification?.toLowerCase().contains('storm') ?? false;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isEmergency)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMd,
                            vertical: AppTheme.spacingSm,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed,
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flash_on,
                                size: 16,
                                color: AppTheme.white,
                              ),
                              const SizedBox(width: AppTheme.spacingXs),
                              Text(
                                'EMERGENCY WORK',
                                style: AppTheme.labelMedium.copyWith(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isEmergency) const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        job.classification ?? 'Electrical Worker',
                        style: AppTheme.displaySmall.copyWith(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Row(
                        children: [
                          Text(
                            'Local ',
                            style: AppTheme.headlineSmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            job.localNumber?.toString() ?? 'N/A',
                            style: AppTheme.headlineSmall.copyWith(
                              color: AppTheme.accentCopper,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Voltage level indicator
            if (job.voltageLevel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: voltageColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: voltageColor, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      size: 20,
                      color: voltageColor,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      job.voltageLevel!,
                      style: AppTheme.titleMedium.copyWith(
                        color: voltageColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Key information in cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wage',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.successGreen,
                          ),
                        ),
                        Text(
                          job.wage ?? 'Competitive',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCopper.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hours',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.accentCopper,
                          ),
                        ),
                        Text(
                          job.hours ?? '40hrs',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.accentCopper,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Location and Company
            Text(
              'Job Details',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            _buildDetailRow(Icons.location_on, 'Location', job.location),
            const SizedBox(height: AppTheme.spacingSm),
            _buildDetailRow(Icons.business, 'Company', job.company),
            const SizedBox(height: AppTheme.spacingSm),
            _buildDetailRow(Icons.access_time, 'Posted', job.datePosted ?? 'Recently'),

            if (job.perDiem != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              _buildDetailRow(Icons.card_giftcard, 'Per Diem', job.perDiem!),
            ],
            
            if (job.jobDescription != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Description',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                job.jobDescription!,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
            
            if (job.typeOfWork != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Type of Work',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(
                  job.typeOfWork!,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: AppTheme.spacingXl),
            
            // Safety information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.infoBlue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.safety_check,
                        color: AppTheme.infoBlue,
                        size: AppTheme.iconMd,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        'Safety Reminder',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.infoBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Always follow proper safety protocols and use appropriate PPE for electrical work.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingXl),
            
            // Action buttons
            JJPrimaryButton(
              text: 'Apply for This Job',
              icon: Icons.send,
              onPressed: () {
                Navigator.pop(context);
                JJSnackBar.showSuccess(
                  context: context,
                  message: 'Application submitted for ${job.classification}!',
                );
              },
              isFullWidth: true,
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            JJSecondaryButton(
              text: 'Save for Later',
              icon: Icons.bookmark_border,
              onPressed: () {
                JJSnackBar.showSuccess(
                  context: context,
                  message: 'Job saved to your favorites',
                );
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}