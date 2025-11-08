import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/domain/enums/enums.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../navigation/app_router.dart';
import '../../services/unified_firestore_service.dart';
import '../../electrical_components/jj_circuit_breaker_switch_list_tile.dart';
import '../../electrical_components/jj_circuit_breaker_switch.dart';
import '../../electrical_components/circuit_board_background.dart';
import '../../electrical_components/jj_electrical_notifications.dart';
import '../../models/user_job_preferences.dart';

class OnboardingStepsScreen extends ConsumerStatefulWidget {
  const OnboardingStepsScreen({super.key});

  @override
  ConsumerState<OnboardingStepsScreen> createState() => _OnboardingStepsScreenState();
}

class _OnboardingStepsScreenState extends ConsumerState<OnboardingStepsScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Personal Information
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();

  // Focus nodes for keyboard navigation
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _address1Focus = FocusNode();
  final _address2Focus = FocusNode();
  final _cityFocus = FocusNode();
  final _zipcodeFocus = FocusNode();

  // Step 2: Professional Details
  final _homeLocalController = TextEditingController();
  final _ticketNumberController = TextEditingController();
  String? _selectedClassification;
  bool _isWorking = false;

  // Step 3: Job Preferences & Goals
  bool _networkWithOthers = false;
  bool _careerAdvancements = false;
  bool _betterBenefits = false;
  bool _higherPayRate = false;
  bool _learnNewSkill = false;
  bool _travelToNewLocation = false;
  bool _findLongTermWork = false;

  // Step 2: Additional Professional Details
  final _booksOnController = TextEditingController();

  // Loading state for save operations
  bool _isSaving = false;

  // Step 3: Preferences and Feedback
  final Set<String> _selectedConstructionTypes = <String>{};
  String? _selectedHoursPerWeek;
  String? _selectedPerDiem;
  final _preferredLocalsController = TextEditingController();
  final _careerGoalsController = TextEditingController();
  final _howHeardAboutUsController = TextEditingController();
  final _lookingToAccomplishController = TextEditingController();

  // Step 2 Focus nodes
  final _ticketNumberFocus = FocusNode();
  final _homeLocalFocus = FocusNode();
  final _booksOnFocus = FocusNode();

  // Step 3 Focus nodes
  final _preferredLocalsFocus = FocusNode();
  final _careerGoalsFocus = FocusNode();
  final _howHeardAboutUsFocus = FocusNode();
  final _lookingToAccomplishFocus = FocusNode();

  // Data options
  final List<String> _classifications = Classification.all;

  final List<String> _constructionTypes = ConstructionTypes.all;

  final List<String> _usStates = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'
  ];

  final List<String> _hoursPerWeekOptions = [
    '40',
    '40-50',
    '50-60',
    '60-70',
    '>70'
  ];

  final List<String> _perDiemOptions = [
    '100-150',
    '150-200',
    '200+'
  ];

  @override
  void initState() {
    super.initState();
    // Load saved onboarding progress when screen initializes
    _loadOnboardingProgress();
  }

  /// Loads saved onboarding progress from Firestore
  ///
  /// Checks if user has partially completed onboarding and restores:
  /// - Current onboarding step (to resume at correct page)
  /// - Previously entered form data (to avoid re-entry)
  ///
  /// This enables seamless resume capability if user exits mid-onboarding.
  Future<void> _loadOnboardingProgress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final firestoreService = UnifiedFirestoreService();
      final userDoc = await firestoreService.getUser(user.uid);

      if (!userDoc.exists) return;

      final data = userDoc.data() as Map<String, dynamic>?;
      if (data == null) return;

      // Check if onboarding was previously started
      final savedStep = data['onboardingStep'] as int?;
      final onboardingStatus = data['onboardingStatus'] as String?;

      // Only resume if onboarding is incomplete
      if (onboardingStatus == 'complete') return;

      if (mounted) {
        setState(() {
          // Restore Step 1 data if available
          if (data.containsKey('firstName')) {
            _firstNameController.text = data['firstName'] ?? '';
            _lastNameController.text = data['lastName'] ?? '';
            _phoneController.text = data['phoneNumber'] ?? '';
            _address1Controller.text = data['address1'] ?? '';
            _address2Controller.text = data['address2'] ?? '';
            _cityController.text = data['city'] ?? '';
            _stateController.text = data['state'] ?? '';
            if (data['zipcode'] != null && data['zipcode'] != 0) {
              _zipcodeController.text = data['zipcode'].toString();
            }
          }

          // Restore Step 2 data if available
          if (data.containsKey('homeLocal')) {
            if (data['homeLocal'] != null && data['homeLocal'] != 0) {
              _homeLocalController.text = data['homeLocal'].toString();
            }
            _ticketNumberController.text = data['ticketNumber'] ?? '';
            _selectedClassification = data['classification'];
            _isWorking = data['isWorking'] ?? false;
            _booksOnController.text = data['booksOn'] ?? '';
          }

          // Resume at saved step (default to 0 if no saved step or savedStep is 1)
          if (savedStep != null && savedStep > 1) {
            _currentStep = savedStep - 1; // Convert to 0-indexed
            // Navigate to saved page after build completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _currentStep < _totalSteps) {
                _pageController.jumpToPage(_currentStep);
                debugPrint('✅ Resumed onboarding at Step ${_currentStep + 1}');
              }
            });
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error loading onboarding progress: $e');
      // Continue with fresh onboarding if load fails
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _homeLocalController.dispose();
    _ticketNumberController.dispose();
    _booksOnController.dispose();
    _preferredLocalsController.dispose();
    _careerGoalsController.dispose();
    _howHeardAboutUsController.dispose();
    _lookingToAccomplishController.dispose();

    // Dispose focus nodes
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    _address1Focus.dispose();
    _address2Focus.dispose();
    _cityFocus.dispose();
    _zipcodeFocus.dispose();
    _ticketNumberFocus.dispose();
    _homeLocalFocus.dispose();
    _booksOnFocus.dispose();
    _preferredLocalsFocus.dispose();
    _careerGoalsFocus.dispose();
    _howHeardAboutUsFocus.dispose();
    _lookingToAccomplishFocus.dispose();

    super.dispose();
  }

  /// Handles navigation to next step with validation and progress saving
  ///
  /// Validates current step data and saves progress to Firestore.
  /// This enables resume capability if user exits before completing onboarding.
  void _nextStep() async {
    if (_isSaving) return;

    try {
      setState(() => _isSaving = true);

      if (_currentStep == 0) {
        // Validate and save Step 1 data
        await _validateStep1();

        // Proceed to next step if validation passes
        if (mounted && _currentStep < _totalSteps - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else if (_currentStep == 1) {
        // Validate and save Step 2 data
        await _validateStep2();

        // Proceed to next step if validation passes
        if (mounted && _currentStep < _totalSteps - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else {
        // Final step - complete onboarding with split collection writes
        await _completeOnboarding();
      }
    } catch (e) {
      debugPrint('Error in _nextStep: $e');
      if (mounted) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Please fix the errors before continuing.',
          type: ElectricalNotificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Validates and saves Step 1: Personal Information
  ///
  /// Performs client-side validation of required fields:
  /// - First name, last name (required)
  /// - Phone number (required)
  /// - Address line 1, city, state (required)
  /// - Zipcode (required, numeric, min 5 digits)
  ///
  /// After validation, saves Step 1 data to Firestore and updates onboardingStep to 2
  /// to enable resume capability if user exits the app.
  ///
  /// Throws [Exception] if validation fails
  Future<void> _validateStep1() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address1 = _address1Controller.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final zipcode = _zipcodeController.text.trim();

    // Validate required fields
    if (firstName.isEmpty) {
      throw Exception('First name is required');
    }
    if (lastName.isEmpty) {
      throw Exception('Last name is required');
    }
    if (phone.isEmpty) {
      throw Exception('Phone number is required');
    }
    if (address1.isEmpty) {
      throw Exception('Address is required');
    }
    if (city.isEmpty) {
      throw Exception('City is required');
    }
    if (state.isEmpty) {
      throw Exception('State is required');
    }
    if (zipcode.isEmpty) {
      throw Exception('Zipcode is required');
    }
    if (zipcode.length < 5) {
      throw Exception('Zipcode must be at least 5 digits');
    }
    if (int.tryParse(zipcode) == null) {
      throw Exception('Zipcode must be numeric');
    }

    debugPrint('✅ Step 1 validation passed');

    // Save Step 1 progress to Firestore
    await _saveStep1Progress();
  }

  /// Saves Step 1 data to Firestore with progress tracking
  ///
  /// Writes personal information to users/{uid} and sets onboardingStep to 2.
  /// This enables resume capability if user exits before completing onboarding.
  Future<void> _saveStep1Progress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final step1Data = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address1': _address1Controller.text.trim(),
        'address2': _address2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipcode': int.parse(_zipcodeController.text.trim()),
        'displayName': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim(),
        'email': user.email ?? '',
        'username': user.email?.split('@')[0] ?? 'user',
        'onboardingStep': 2, // Mark ready for step 2
        'onboardingStatus': 'incomplete',
        'lastActive': FieldValue.serverTimestamp(),
      };

      final firestoreService = UnifiedFirestoreService();
      await firestoreService.setUserWithMerge(uid: user.uid, data: step1Data);
      debugPrint('✅ Step 1 progress saved - User can resume at Step 2');
    } catch (e) {
      debugPrint('⚠️ Error saving Step 1 progress: $e');
      // Don't block progression even if save fails
    }
  }

  /// Validates and saves Step 2: Professional Details
  ///
  /// Performs client-side validation of required fields:
  /// - Home local number (required, numeric)
  /// - Ticket number (required)
  /// - Classification (required selection)
  ///
  /// After validation, saves Step 2 data to Firestore and updates onboardingStep to 3
  /// to enable resume capability if user exits the app.
  ///
  /// Throws [Exception] if validation fails
  Future<void> _validateStep2() async {
    final homeLocal = _homeLocalController.text.trim();
    final ticketNumber = _ticketNumberController.text.trim();

    // Validate required fields
    if (homeLocal.isEmpty) {
      throw Exception('Home local number is required');
    }
    if (int.tryParse(homeLocal) == null) {
      throw Exception('Home local must be a valid number');
    }
    if (ticketNumber.isEmpty) {
      throw Exception('Ticket number is required');
    }
    if (_selectedClassification == null || _selectedClassification!.isEmpty) {
      throw Exception('Classification is required');
    }

    debugPrint('✅ Step 2 validation passed');

    // Save Step 2 progress to Firestore
    await _saveStep2Progress();
  }

  /// Saves Step 2 data to Firestore with progress tracking
  ///
  /// Writes IBEW professional information to users/{uid} and sets onboardingStep to 3.
  /// This enables resume capability if user exits before completing onboarding.
  Future<void> _saveStep2Progress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final step2Data = {
        'homeLocal': int.parse(_homeLocalController.text.trim()),
        'ticketNumber': _ticketNumberController.text.trim(),
        'classification': _selectedClassification ?? '',
        'isWorking': _isWorking,
        'booksOn': _booksOnController.text.trim().isEmpty
            ? null
            : _booksOnController.text.trim(),
        'onboardingStep': 3, // Mark ready for step 3
        'onboardingStatus': 'incomplete',
        'lastActive': FieldValue.serverTimestamp(),
      };

      final firestoreService = UnifiedFirestoreService();
      await firestoreService.setUserWithMerge(uid: user.uid, data: step2Data);
      debugPrint('✅ Step 2 progress saved - User can resume at Step 3');
    } catch (e) {
      debugPrint('⚠️ Error saving Step 2 progress: $e');
      // Don't block progression even if save fails
    }
  }

  /// Parses comma-separated preferred locals into list of integers
  ///
  /// Handles various input formats:
  /// - "84, 222, 111" → [84, 222, 111]
  /// - "Local 26, Local 103" → [26, 103]
  /// - Empty string → []
  ///
  /// Returns list of valid local numbers, ignoring invalid entries
  List<int> _parsePreferredLocals(String localsText) {
    final preferredLocals = <int>[];
    if (localsText.trim().isEmpty) return preferredLocals;

    final localStrings = localsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    for (final localStr in localStrings) {
      final local = int.tryParse(localStr);
      if (local != null) {
        preferredLocals.add(local);
      }
    }
    return preferredLocals;
  }

  /// Formats classification from camelCase to Title Case
  ///
  /// Examples:
  /// - "journeymanLineman" → "Journeyman Lineman"
  /// - "journeymanWireman" → "Journeyman Wireman"
  /// - "operator" → "Operator"
  ///
  /// Returns formatted string for display
  String _formatClassification(String classification) {
    // Add space before capital letters and capitalize first letter
    return classification
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Maps onboarding data to UserJobPreferences model
  ///
  /// Creates UserJobPreferences object from Step 3 form data:
  /// - Construction types (multi-select chips)
  /// - Preferred locals (parsed from comma-separated input)
  /// - Hours per week and per diem (dropdown selections)
  ///
  /// Returns [UserJobPreferences] object for saving to Firestore
  UserJobPreferences _mapOnboardingDataToPreferences() {
    return UserJobPreferences(
      classifications: [], // Set to empty as per requirements
      constructionTypes: _selectedConstructionTypes.toList(),
      preferredLocals: _parsePreferredLocals(_preferredLocalsController.text.trim()),
      hoursPerWeek: _selectedHoursPerWeek,
      perDiemRequirement: _selectedPerDiem,
      minWage: null, // Set to null as per requirements
      maxDistance: null, // Set to null as per requirements
    );
  }

  /// Completes onboarding by saving all data to users/{uid} collection
  ///
  /// BACKEND ARCHITECTURE:
  /// Saves complete user profile with embedded job preferences in a single write:
  /// - users/{uid}: Personal info, IBEW details, job search goals, metadata
  /// - users/{uid}.jobPreferences: Construction types, hours, per diem, preferred locals (nested)
  ///
  /// After successful write:
  /// - Sets onboardingStatus to 'complete' in Firestore
  /// - Shows success notification
  /// - Navigates to home screen
  ///
  /// Error handling:
  /// - Logs error and shows user-friendly message
  /// - Does not navigate away on failure
  /// - Allows user to retry
  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);

    try {
      // Get current authenticated user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      debugPrint('\n🔍 DEBUG: Starting onboarding completion for user: ${user.uid}');
      debugPrint('📧 User email: ${user.email}');

      // Initialize Firestore service
      final firestoreService = UnifiedFirestoreService();

      // Map onboarding data to UserJobPreferences for job matching
      final preferences = _mapOnboardingDataToPreferences();
      debugPrint('✅ Preferences mapped successfully');

      // ============================================================
      // Build complete user data with embedded job preferences
      // ============================================================
      // All data saved to users/{uid} collection in a single write
      final Map<String, dynamic> completeUserData = {
        // Step 1: Personal Information (8 fields)
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address1': _address1Controller.text.trim(),
        'address2': _address2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipcode': int.parse(_zipcodeController.text.trim()),

        // Step 2: IBEW Classification (5 fields)
        'homeLocal': int.parse(_homeLocalController.text.trim()),
        'ticketNumber': _ticketNumberController.text.trim(),
        'classification': _selectedClassification ?? '',
        'isWorking': _isWorking,
        'booksOn': _booksOnController.text.trim().isEmpty
            ? null
            : _booksOnController.text.trim(),

        // Step 3: Job Search Goals (NOT preferences - these describe user's situation)
        'networkWithOthers': _networkWithOthers,
        'careerAdvancements': _careerAdvancements,
        'betterBenefits': _betterBenefits,
        'higherPayRate': _higherPayRate,
        'learnNewSkill': _learnNewSkill,
        'travelToNewLocation': _travelToNewLocation,
        'findLongTermWork': _findLongTermWork,
        'careerGoals': _careerGoalsController.text.trim().isEmpty
            ? null
            : _careerGoalsController.text.trim(),
        'howHeardAboutUs': _howHeardAboutUsController.text.trim().isEmpty
            ? null
            : _howHeardAboutUsController.text.trim(),
        'lookingToAccomplish': _lookingToAccomplishController.text.trim().isEmpty
            ? null
            : _lookingToAccomplishController.text.trim(),

        // Job Preferences - Embedded as nested object
        'jobPreferences': preferences.toJson(),

        // System/Metadata fields
        'email': user.email ?? '',
        'username': '${_firstNameController.text.trim()}${_lastNameController.text.trim()}',
        'displayName': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim(),
        'onboardingStatus': 'complete',
        'onboardingStep': 3, // Track completion at step 3
        'preferencesCompleted': true, // Flag for preferences completion
        'onlineStatus': true, // CRITICAL: User is now active and online
        'createdTime': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'isActive': true,
        'crewIds': <String>[],
        'hasSetJobPreferences': true,
      };

      debugPrint('\n📦 DEBUG: completeUserData map built with ${completeUserData.length} fields');
      debugPrint('📝 Fields: ${completeUserData.keys.toList()}');
      debugPrint('🎯 Sample data:');
      debugPrint('  - firstName: ${completeUserData['firstName']}');
      debugPrint('  - lastName: ${completeUserData['lastName']}');
      debugPrint('  - email: ${completeUserData['email']}');
      debugPrint('  - onboardingStatus: ${completeUserData['onboardingStatus']}');
      debugPrint('  - hasSetJobPreferences: ${completeUserData['hasSetJobPreferences']}');

      // Execute single Firestore write with embedded job preferences
      debugPrint('\n🔄 DEBUG: Calling setUserWithMerge...');
      await firestoreService.setUserWithMerge(
        uid: user.uid,
        data: completeUserData,
      );
      debugPrint('✅ DEBUG: setUserWithMerge completed successfully!');

      debugPrint('✅ User data saved to users/{${user.uid}} with ${completeUserData.length} fields');
      debugPrint('✅ Job preferences embedded in users/{${user.uid}}.jobPreferences');
      debugPrint('✅ Onboarding completed successfully');

      if (mounted) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Profile setup complete! Welcome to Journeyman Jobs.',
          type: ElectricalNotificationType.success,
        );

        // Navigate to home after successful save
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go(AppRouter.home);
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('\n❌❌❌ ERROR COMPLETING ONBOARDING ❌❌❌');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');
      debugPrint('Stack trace:');
      debugPrint(stackTrace.toString());
      debugPrint('❌❌❌ END ERROR ❌❌❌\n');

      if (mounted) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Error saving profile: ${e.toString()}',
          type: ElectricalNotificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Validates whether current step can proceed to next
  ///
  /// Client-side validation to enable/disable Next button:
  /// - Step 1: All personal information fields required
  /// - Step 2: Home local, ticket number, classification required
  /// - Step 3: At least one construction type selected
  ///
  /// Returns true if current step has valid data
  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Basic Information - Enhanced validation
        final firstName = _firstNameController.text.trim();
        final lastName = _lastNameController.text.trim();
        final phone = _phoneController.text.trim();
        final address1 = _address1Controller.text.trim();
        final city = _cityController.text.trim();
        final state = _stateController.text.trim();
        final zipcode = _zipcodeController.text.trim();

        return firstName.isNotEmpty &&
               lastName.isNotEmpty &&
               phone.isNotEmpty &&
               address1.isNotEmpty &&
               city.isNotEmpty &&
               state.isNotEmpty &&
               zipcode.isNotEmpty &&
               zipcode.length >= 5 && // Basic zipcode validation
               int.tryParse(zipcode) != null; // Ensure zipcode is numeric

      case 1: // Professional Details - Enhanced validation
        final homeLocal = _homeLocalController.text.trim();
        final ticketNumber = _ticketNumberController.text.trim();

        return homeLocal.isNotEmpty &&
               ticketNumber.isNotEmpty &&
               _selectedClassification != null &&
               _selectedClassification!.isNotEmpty &&
               int.tryParse(homeLocal) != null; // Ensure home local is numeric

      case 2: // Preferences & Feedback
        return _selectedConstructionTypes.isNotEmpty;

      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed from: AppTheme.primaryNavy
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.95), // Changed from: AppTheme.primaryNavy.withValues(alpha: 0.9)
        elevation: 0,
        leading: _currentStep > 0
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.accentCopper,
                    width: AppTheme.borderWidthCopperThin,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: [
                    AppTheme.shadowElectricalInfo,
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.primaryNavy), // Changed from: AppTheme.white),
                  onPressed: _previousStep,
                ),
              )
            : null,
        title: Text(
          'Setup Profile',
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.textPrimary, // Changed from: AppTheme.white
            shadows: [
              Shadow(
                color: AppTheme.accentCopper.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentCopper.withValues(alpha: 0.0),
                  AppTheme.accentCopper.withValues(alpha: 0.5),
                  AppTheme.accentCopper.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Enhanced electrical circuit background
          // TODO: Update ElectricalCircuitBackground to support light mode
          // - Use navy traces instead of white (opacity: 0.12)
          // - Add copper component highlights (opacity: 0.08)
          // TODO: Update ElectricalCircuitBackground to support light mode
          // - Use navy traces instead of white (opacity: 0.12)
          // - Add copper component highlights (opacity: 0.08)
          const Positioned.fill(
            child: ElectricalCircuitBackground(
              opacity: 0.08,
              componentDensity: ComponentDensity.high,
              enableCurrentFlow: true,
              enableInteractiveComponents: true,
            ),
          ),
          Column(
            children: [
              // Enhanced progress indicator with electrical theming
              Container(
                margin: const EdgeInsets.all(AppTheme.spacingMd),
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: Colors.white, // Changed from: AppTheme.white.withValues(alpha: 0.05)
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: AppTheme.accentCopper,
                    width: AppTheme.borderWidthCopperThin,
                  ),
                  boxShadow: [
                    AppTheme.shadowElectricalInfo,
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    JJProgressIndicator(
                      currentStep: _currentStep + 1,
                      totalSteps: _totalSteps,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'Step ${_currentStep + 1} of $_totalSteps',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textPrimary, // Changed from: AppTheme.white
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentStep = page;
                    });
                  },
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95), // Changed from: AppTheme.primaryNavy.withValues(alpha: 0.9)
          border: Border(
            top: BorderSide(
              color: AppTheme.accentCopper,
              width: AppTheme.borderWidthCopper,
            ),
          ),
          boxShadow: [
            AppTheme.shadowElectricalSuccess,
            BoxShadow(
              color: AppTheme.primaryNavy.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.accentCopper,
                          width: AppTheme.borderWidthCopperThin,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          AppTheme.shadowElectricalWarning,
                        ],
                      ),
                      child: JJSecondaryButton(
                        text: 'Back',
                        onPressed: _previousStep,
                      ),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),

                const SizedBox(width: AppTheme.spacingMd),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.accentCopper,
                        width: AppTheme.borderWidthCopper,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: [
                        AppTheme.shadowElectricalSuccess,
                      ],
                    ),
                    child: JJPrimaryButton(
                      text: _currentStep == _totalSteps - 1 ? 'Complete' : 'Next',
                      onPressed: (_canProceed() && !_isSaving) ? _nextStep : null,
                      isLoading: _isSaving,
                      icon: _currentStep == _totalSteps - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                      variant: JJButtonVariant.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: _buildStepHeader(
              icon: Icons.person_outline,
              title: 'Basic Information',
              subtitle: 'Let\'s start with your essential details',
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Name fields
          Row(
            children: [
              Expanded(
                child: JJTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocus),
                  prefixIcon: Icons.person_outline,
                  hintText: 'Enter first name',
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: JJTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  focusNode: _lastNameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                  prefixIcon: Icons.person_outline,
                  hintText: 'Enter last name',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Phone number
          JJTextField(
            label: 'Phone Number',
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_address1Focus),
            prefixIcon: Icons.phone_outlined,
            hintText: 'Enter your phone number',
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Address
          JJTextField(
            label: 'Address Line 1',
            controller: _address1Controller,
            focusNode: _address1Focus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_address2Focus),
            prefixIcon: Icons.home_outlined,
            hintText: 'Enter your street address',
          ),

          const SizedBox(height: AppTheme.spacingSm),

          JJTextField(
            label: 'Address Line 2 (Optional)',
            controller: _address2Controller,
            focusNode: _address2Focus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cityFocus),
            prefixIcon: Icons.home_outlined,
            hintText: 'Apartment, suite, etc.',
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // City, State, Zip
          JJTextField(
            label: 'City',
            controller: _cityController,
            focusNode: _cityFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_zipcodeFocus),
            prefixIcon: Icons.location_city_outlined,
            hintText: 'Enter city',
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'State',
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: Colors.white, // Changed from: AppTheme.white.withValues(alpha: 0.05)
                        border: Border.all(
                          color: AppTheme.accentCopper,
                          width: AppTheme.borderWidthCopperThin,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [AppTheme.shadowElectricalInfo],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _stateController.text.isEmpty ? null : _stateController.text,
                          hint: Text(
                            'State',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary, // Changed from: AppTheme.white.withValues(alpha: 0.7)
                            ),
                          ),
                          dropdownColor: AppTheme.primaryNavy,
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary), // Changed from: AppTheme.white),
                          icon: Icon(Icons.arrow_drop_down, color: AppTheme.accentCopper),
                          isExpanded: true,
                          items: _usStates.map((state) {
                            return DropdownMenuItem(
                              value: state,
                              child: Text(
                                state,
                                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary), // Changed from: AppTheme.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _stateController.text = value ?? '';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                flex: 2,
                child: JJTextField(
                  label: 'Zip Code',
                  controller: _zipcodeController,
                  focusNode: _zipcodeFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icons.mail_outline,
                  hintText: 'Zip',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingXxl),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStepHeader(
            icon: Icons.electrical_services,
            title: 'IBEW Professional Details',
            subtitle: 'Tell us about your electrical career and qualifications',
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Ticket Number
          JJTextField(
            label: 'Ticket Number',
            controller: _ticketNumberController,
            focusNode: _ticketNumberFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_homeLocalFocus),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.badge_outlined,
            hintText: 'Enter your ticket number',
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Home Local
          JJTextField(
            label: 'Home Local Number',
            controller: _homeLocalController,
            focusNode: _homeLocalFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_booksOnFocus),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.location_on_outlined,
            hintText: 'Enter your home local number',
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Classification selection
          Text(
            'Classification',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Select your current classification',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: _classifications.map((classification) {
              final isSelected = _selectedClassification == classification;
              return JJChip(
                label: _formatClassification(classification),
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedClassification = classification;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Currently working status
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              children: [
                JJCircuitBreakerSwitchListTile(
                  title: Row(
                    children: [
                      Text(
                        'Currently Working',
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _isWorking ? AppTheme.successGreen.withValues(alpha: 0.2) : AppTheme.lightGray.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(
                            color: _isWorking ? AppTheme.successGreen : AppTheme.lightGray,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _isWorking ? 'YES' : 'NO',
                          style: AppTheme.labelSmall.copyWith(
                            color: _isWorking ? AppTheme.successGreen : AppTheme.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'Are you currently employed?',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                  ),
                  value: _isWorking,
                  onChanged: (value) {
                    setState(() {
                      _isWorking = value;
                    });
                  },
                  size: JJCircuitBreakerSize.small,
                  showElectricalEffects: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacingMd, top: AppTheme.spacingSm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'NO',
                        style: AppTheme.labelSmall.copyWith(
                          color: !_isWorking ? AppTheme.accentCopper : AppTheme.textLight,
                          fontWeight: !_isWorking ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Text(
                        'YES',
                        style: AppTheme.labelSmall.copyWith(
                          color: _isWorking ? AppTheme.accentCopper : AppTheme.textLight,
                          fontWeight: _isWorking ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Books they're on - CRITICAL FIELD
          JJTextField(
            label: 'Books You\'re Currently On',
            controller: _booksOnController,
            focusNode: _booksOnFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            prefixIcon: Icons.book_outlined,
            hintText: 'e.g., 84, 222, 111, 1249, 71',
            maxLines: 2,
          ),

          const SizedBox(height: AppTheme.spacingSm),

          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.accentCopper,
                  size: 16,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    'This helps us manage your monthly resignations and maintain your position',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingXxl),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStepHeader(
            icon: Icons.tune_outlined,
            title: 'Preferences & Feedback',
            subtitle: 'Help us personalize your experience',
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Construction Types
          Text(
            'Construction Types',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Select all construction types you\'re interested in:',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: _constructionTypes.map((type) {
              final isSelected = _selectedConstructionTypes.contains(type);
              return JJChip(
                label: _capitalizeConstructionType(type),
                isSelected: isSelected,
                icon: _getConstructionTypeIcon(type),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedConstructionTypes.remove(type);
                    } else {
                      _selectedConstructionTypes.add(type);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Hours per week
          Text(
            'Hours Per Week',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'How many hours are you willing to work per week?',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              color: AppTheme.textPrimary, // Changed from: AppTheme.white
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedHoursPerWeek,
                hint: Text(
                  'Select hours per week',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                ),
                isExpanded: true,
                items: _hoursPerWeekOptions.map((hours) {
                  return DropdownMenuItem(
                    value: hours,
                    child: Text(hours, style: AppTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHoursPerWeek = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Per diem
          Text(
            'Per Diem Requirements',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'What per diem amount are you looking for?',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              color: AppTheme.textPrimary, // Changed from: AppTheme.white
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPerDiem,
                hint: Text(
                  'Select per diem preference',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                ),
                isExpanded: true,
                items: _perDiemOptions.map((perDiem) {
                  return DropdownMenuItem(
                    value: perDiem,
                    child: Text(perDiem, style: AppTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPerDiem = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Preferred locals
          JJTextField(
            label: 'Preferred Locals (Optional)',
            controller: _preferredLocalsController,
            focusNode: _preferredLocalsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_careerGoalsFocus),
            prefixIcon: Icons.location_on_outlined,
            hintText: 'e.g., Local 26, Local 103, Local 456',
            maxLines: 2,
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Job search goals
          Text(
            'Job Search Goals',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Select all that apply to your job search:',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: Colors.white, // Changed from: AppTheme.white.withValues(alpha: 0.05)
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthCopper,
              ),
              boxShadow: [AppTheme.shadowElectricalInfo],
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text('Network with Others', style: AppTheme.bodyMedium),
                  subtitle: Text('Connect with other electricians', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _networkWithOthers,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _networkWithOthers = value ?? false),
                  dense: true,
                ),
                Divider(color: AppTheme.accentCopper.withValues(alpha: 0.3), height: 1),
                CheckboxListTile(
                  title: Text('Career Advancement', style: AppTheme.bodyMedium),
                  subtitle: Text('Seek leadership roles', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _careerAdvancements,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _careerAdvancements = value ?? false),
                  dense: true,
                ),
                Divider(color: AppTheme.accentCopper.withValues(alpha: 0.3), height: 1),
                CheckboxListTile(
                  title: Text('Better Benefits', style: AppTheme.bodyMedium),
                  subtitle: Text('Improved benefit packages', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _betterBenefits,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _betterBenefits = value ?? false),
                  dense: true,
                ),
                Divider(color: AppTheme.accentCopper.withValues(alpha: 0.3), height: 1),
                CheckboxListTile(
                  title: Text('Higher Pay Rate', style: AppTheme.bodyMedium),
                  subtitle: Text('Increase compensation', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _higherPayRate,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _higherPayRate = value ?? false),
                  dense: true,
                ),
                Divider(color: AppTheme.accentCopper.withValues(alpha: 0.3), height: 1),
                CheckboxListTile(
                  title: Text('Learn New Skills', style: AppTheme.bodyMedium),
                  subtitle: Text('Gain new experience', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _learnNewSkill,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _learnNewSkill = value ?? false),
                  dense: true,
                ),
                Divider(color: AppTheme.accentCopper.withValues(alpha: 0.3), height: 1),
                CheckboxListTile(
                  title: Text('Travel to New Locations', style: AppTheme.bodyMedium),
                  subtitle: Text('Work in different areas', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _travelToNewLocation,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _travelToNewLocation = value ?? false),
                  dense: true,
                ),
                Divider(color: AppTheme.accentCopper.withValues(alpha: 0.3), height: 1),
                CheckboxListTile(
                  title: Text('Find Long-term Work', style: AppTheme.bodyMedium),
                  subtitle: Text('Secure stable employment', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _findLongTermWork,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _findLongTermWork = value ?? false),
                  dense: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Career goals
          JJTextField(
            label: 'Career Goals (Optional)',
            controller: _careerGoalsController,
            focusNode: _careerGoalsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_howHeardAboutUsFocus),
            maxLines: 3,
            prefixIcon: Icons.flag_outlined,
            hintText: 'Describe your career goals and where you see yourself in the future...',
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // How did you hear about us
          JJTextField(
            label: 'How did you hear about us?',
            controller: _howHeardAboutUsController,
            focusNode: _howHeardAboutUsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lookingToAccomplishFocus),
            maxLines: 2,
            prefixIcon: Icons.info_outline,
            hintText: 'Tell us how you discovered Journeyman Jobs...',
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // What are you looking to accomplish
          JJTextField(
            label: 'What are you looking to accomplish?',
            controller: _lookingToAccomplishController,
            focusNode: _lookingToAccomplishFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            maxLines: 3,
            prefixIcon: Icons.track_changes_outlined,
            hintText: 'What do you hope to achieve through our platform?',
          ),

          const SizedBox(height: AppTheme.spacingXxl),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.accentCopper,
              width: AppTheme.borderWidthCopper,
            ),
            boxShadow: [
              AppTheme.shadowElectricalSuccess,
              BoxShadow(
                color: AppTheme.accentCopper.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 36,
            color: AppTheme.textPrimary, // Changed from: AppTheme.white
            shadows: [
              Shadow(
                color: AppTheme.accentCopper.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingMd),

        Text(
          title,
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.textPrimary, // Changed from: AppTheme.white
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: AppTheme.primaryNavy.withValues(alpha: 0.8),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppTheme.spacingSm),

        Text(
          subtitle,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textPrimary, // Changed from: AppTheme.white.withValues(alpha: 0.9)
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _capitalizeConstructionType(String type) {
    switch (type) {
      case 'distribution':
        return 'Distribution';
      case 'transmission':
        return 'Transmission';
      case 'subStation':
        return 'Sub Station';
      case 'residential':
        return 'Residential';
      case 'industrial':
        return 'Industrial';
      case 'dataCenter':
        return 'Data Center';
      case 'commercial':
        return 'Commercial';
      case 'underground':
        return 'Underground';
      default:
        // Fallback: capitalize first letter
        return type.isNotEmpty
            ? '${type[0].toUpperCase()}${type.substring(1)}'
            : type;
    }
  }

  IconData _getConstructionTypeIcon(String type) {
    switch (type) {
      case 'distribution':
        return Icons.power_outlined;
      case 'transmission':
        return Icons.electrical_services;
      case 'subStation':
        return Icons.transform_outlined;
      case 'residential':
        return Icons.home_outlined;
      case 'industrial':
        return Icons.factory_outlined;
      case 'dataCenter':
        return Icons.storage_outlined;
      case 'commercial':
        return Icons.business_outlined;
      case 'underground':
        return Icons.layers_outlined;
      default:
        return Icons.construction_outlined;
    }
  }

}
