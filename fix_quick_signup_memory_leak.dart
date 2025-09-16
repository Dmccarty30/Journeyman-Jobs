// MEMORY LEAK FIX - QuickSignupScreen
// CRITICAL: TextEditingController and stream subscription memory leak fix

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../models/roster_contractor.dart';
import '../../services/job_sharing_service.dart';
import '../../../design_system/app_theme.dart';

/// FIXED: Added proper dispose() method to prevent battery drain
/// during electrical work shifts and viral job sharing flows
class QuickSignupScreen extends StatefulWidget {
  final String? sharedJobId;
  final String? referrerUserId;

  const QuickSignupScreen({
    Key? key,
    this.sharedJobId,
    this.referrerUserId,
  }) : super(key: key);

  @override
  State<QuickSignupScreen> createState() => _QuickSignupScreenState();
}

class _QuickSignupScreenState extends State<QuickSignupScreen>
    with TickerProviderStateMixin {
  // Controllers that need disposal
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _ticketController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  // Animation controllers that need disposal
  late AnimationController _progressAnimationController;
  late AnimationController _successAnimationController;

  late JobSharingService _jobSharingService;

  // Stream subscriptions that need cancellation
  StreamSubscription<bool>? _validationSubscription;
  Timer? _progressTimer;

  // Form state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSubmitting = false;
  String? _selectedClassification;
  List<String> _classifications = [
    'Inside Wireman',
    'Journeyman Lineman',
    'Tree Trimmer',
    'Equipment Operator',
  ];

  @override
  void initState() {
    super.initState();
    _jobSharingService = JobSharingService();

    // Initialize animation controllers
    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _successAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _initializeValidation();
  }

  void _initializeValidation() {
    // Real-time validation stream
    _validationSubscription = Stream.periodic(Duration(milliseconds: 500))
        .map((_) => _validateCurrentStep())
        .distinct()
        .listen((isValid) {
      if (mounted) {
        setState(() {
          // Update validation state
        });
      }
    });
  }

  // CRITICAL MEMORY LEAK FIX: Proper disposal of all resources
  @override
  void dispose() {
    // Dispose page controller
    _pageController.dispose();

    // Dispose text controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _localController.dispose();
    _ticketController.dispose();
    _experienceController.dispose();

    // Dispose animation controllers
    _progressAnimationController.dispose();
    _successAnimationController.dispose();

    // Cancel stream subscriptions
    _validationSubscription?.cancel();

    // Cancel timers
    _progressTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quick Signup',
          style: AppTheme.headingMedium.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            // Main content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildBasicInfoStep(),
                  _buildIBEWInfoStep(),
                  _buildExperienceStep(),
                  _buildConfirmationStep(),
                ],
              ),
            ),
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? AppTheme.accentCopper
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: AppTheme.headingLarge.copyWith(color: Colors.white),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentCopper),
                ),
              ),
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Name is required';
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentCopper),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!value!.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentCopper),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone is required';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIBEWInfoStep() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IBEW Information',
            style: AppTheme.headingLarge.copyWith(color: Colors.white),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _localController,
            decoration: InputDecoration(
              labelText: 'IBEW Local (e.g., 46, 123)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accentCopper),
              ),
            ),
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedClassification,
            decoration: InputDecoration(
              labelText: 'Classification',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accentCopper),
              ),
            ),
            dropdownColor: AppTheme.primaryNavy,
            style: TextStyle(color: Colors.white),
            items: _classifications.map((classification) {
              return DropdownMenuItem(
                value: classification,
                child: Text(classification),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedClassification = value;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _ticketController,
            decoration: InputDecoration(
              labelText: 'Ticket Number (Optional)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accentCopper),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience',
            style: AppTheme.headingLarge.copyWith(color: Colors.white),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _experienceController,
            decoration: InputDecoration(
              labelText: 'Years of Experience',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accentCopper),
              ),
            ),
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Ready to Join!',
            style: AppTheme.headingLarge.copyWith(color: Colors.white),
          ),
          SizedBox(height: 20),
          if (_isSubmitting)
            CircularProgressIndicator(color: AppTheme.accentCopper)
          else
            Text(
              'Your account will be created and you\'ll have access to IBEW job opportunities.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                ),
                child: Text('Back', style: TextStyle(color: Colors.white)),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
              ),
              child: Text(
                _currentStep == 3 ? 'Complete Signup' : 'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentStep = page;
    });
    _progressAnimationController.animateTo(page / 3);
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitSignup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty &&
            _emailController.text.contains('@') &&
            _phoneController.text.isNotEmpty;
      case 1:
        return _localController.text.isNotEmpty &&
            _selectedClassification != null;
      case 2:
        return _experienceController.text.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _submitSignup() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final contractor = RosterContractor(
        id: '', // Will be generated
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        ibewLocal: _localController.text,
        classification: _selectedClassification ?? '',
        ticketNumber: _ticketController.text,
        yearsExperience: int.tryParse(_experienceController.text) ?? 0,
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      await _jobSharingService.createQuickAccount(
        contractor: contractor,
        sharedJobId: widget.sharedJobId,
        referrerUserId: widget.referrerUserId,
      );

      _successAnimationController.forward();

      // Navigate to success or job details
      if (widget.sharedJobId != null) {
        context.go('/jobs/${widget.sharedJobId}');
      } else {
        context.go('/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}