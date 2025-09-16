// MEMORY LEAK FIX - RosterSignupCarousel
// CRITICAL: PageController memory leak fix for storm emergency work

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../models/storm_roster_signup.dart';
import '../../services/roster_data_service.dart';
import '../../design_system/app_theme.dart';
import 'contractor_card.dart';

/// FIXED: Added proper dispose() method to prevent battery drain
/// during storm emergency electrical work
class RosterSignupCarousel extends StatefulWidget {
  const RosterSignupCarousel({super.key});

  @override
  State<RosterSignupCarousel> createState() => _RosterSignupCarouselState();
}

class _RosterSignupCarouselState extends State<RosterSignupCarousel>
    with TickerProviderStateMixin {
  // Controllers that need disposal
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  // Animation controllers that need disposal
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;

  final RosterDataService _rosterService = RosterDataService();

  // Stream subscriptions that need cancellation
  StreamSubscription<List<StormRosterSignup>>? _signupsSubscription;
  Timer? _autoScrollTimer;

  List<StormRosterSignup> _signups = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _loadSignups();
    _startAutoScroll();
  }

  void _loadSignups() {
    // Setup stream subscription for real-time updates
    _signupsSubscription = _rosterService
        .getStormRosterSignupsStream()
        .listen((signups) {
      if (mounted) {
        setState(() {
          _signups = signups;
          _isLoading = false;
        });
        _fadeAnimationController.forward();
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted && _signups.isNotEmpty) {
        final nextIndex = (_currentIndex + 1) % _signups.length;
        _pageController.animateToPage(
          nextIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // CRITICAL MEMORY LEAK FIX: Proper disposal of all resources
  @override
  void dispose() {
    // Dispose controllers
    _pageController.dispose();
    _scrollController.dispose();

    // Dispose animation controllers
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();

    // Cancel stream subscriptions
    _signupsSubscription?.cancel();

    // Cancel timers
    _autoScrollTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentCopper,
          ),
        ),
      );
    }

    if (_signups.isEmpty) {
      return Container(
        height: 200,
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flash_off,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No storm roster signups available',
                style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/storm-signup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                ),
                child: Text('Join Storm Roster'),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimationController,
      child: Container(
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Storm Roster Signups',
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/storm-roster'),
                    child: Text(
                      'View All',
                      style: TextStyle(color: AppTheme.accentCopper),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _slideAnimationController.forward().then((_) {
                    _slideAnimationController.reset();
                  });
                },
                itemCount: _signups.length,
                itemBuilder: (context, index) {
                  final signup = _signups[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(0.05, 0),
                    ).animate(_slideAnimationController),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ContractorCard(
                        contractor: signup.contractor,
                        isStormWork: true,
                        onTap: () => _showSignupDetails(signup),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Page indicators
            if (_signups.length > 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_signups.length, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? AppTheme.accentCopper
                            : Colors.grey.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSignupDetails(StormRosterSignup signup) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                signup.contractor.name,
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'IBEW Local ${signup.contractor.ibewLocal}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildDetailRow('Classification', signup.contractor.classification),
              _buildDetailRow('Experience', '${signup.contractor.yearsExperience} years'),
              _buildDetailRow('Storm Experience', signup.stormExperience),
              _buildDetailRow('Equipment', signup.equipmentAvailable.join(', ')),
              if (signup.availableStartDate != null)
                _buildDetailRow(
                  'Available',
                  '${signup.availableStartDate!.month}/${signup.availableStartDate!.day}',
                ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _contactContractor(signup.contractor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCopper,
                      ),
                      child: Text('Contact'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _contactContractor(dynamic contractor) {
    // Implement contact functionality
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact feature coming soon'),
        backgroundColor: AppTheme.accentCopper,
      ),
    );
  }
}