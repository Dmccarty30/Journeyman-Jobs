import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
// import '../../backend/schema/enums.dart'; // TODO: Uncomment when needed
import '../../navigation/app_router.dart';
import '../../services/onboarding_service.dart';
import '../../electrical_components/jj_circuit_breaker_switch_list_tile.dart';
import '../../electrical_components/jj_circuit_breaker_switch.dart';

class OnboardingStepsScreen extends StatefulWidget {
  const OnboardingStepsScreen({super.key});

  @override
  State<OnboardingStepsScreen> createState() => _OnboardingStepsScreenState();
}

class _OnboardingStepsScreenState extends State<OnboardingStepsScreen> {
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
  final List<String> _classifications = [
    'Journeyman Lineman',
    'Journeyman Electrician',
    'Journeyman Wireman',
    'Journeyman Tree Trimmer',
    'Operator',
  ];

  final List<String> _constructionTypes = [
    'Distribution',
    'Transmission',
    'SubStation',
    'Residential',
    'Industrial',
    'Data Center',
    'Commercial',
    'Underground',
  ];

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

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
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

  void _completeOnboarding() async {
    try {
      // TODO: Get current user ID from auth
      // final String userId = 'temp_user_id'; // This should come from auth service

      // Convert classification string to enum value
      // Classification? classificationEnum;
      /*if (_selectedClassification != null) {
        switch (_selectedClassification!) {
          case 'Journeyman Lineman':
            classificationEnum = Classification.JourneymanLineman;
            break;
          case 'Journeyman Electrician':
            classificationEnum = Classification.JourneymanElectrician;
            break;
          case 'Journeyman Wireman':
            classificationEnum = Classification.JourneymanWireman;
            break;
          case 'Journeyman Tree Trimmer':
            classificationEnum = Classification.JourneymanTreeTrimmer;
            break;
          case 'Operator':
            classificationEnum = Classification.Operator;
            break;
        }
      }*/

      // Create comprehensive user data map
      // TODO: Uncomment when FirestoreService is implemented
      /*final userData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone_number': _phoneController.text,
        'address1': _address1Controller.text,
        'address2': _address2Controller.text.isEmpty ? null : _address2Controller.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zipcode': int.tryParse(_zipcodeController.text),
        'home_local': int.tryParse(_homeLocalController.text),
        'ticket_number': int.tryParse(_ticketNumberController.text),
        'classification': classificationEnum?.serialize(),
        'is_working': _isWorking,
        'books_on': _booksOnController.text.isEmpty ? null : _booksOnController.text,
        'constructionTypes': _selectedConstructionTypes.toList(),
        'hours_per_week': _selectedHoursPerWeek,
        'per_diem_requirement': _selectedPerDiem,
        'preferred_locals': _preferredLocalsController.text.isEmpty ? null : _preferredLocalsController.text,
        'networkWithOthers': _networkWithOthers,
        'careerAdvancements': _careerAdvancements,
        'betterBenefits': _betterBenefits,
        'higherPayRate': _higherPayRate,
        'learnNewSkill': _learnNewSkill,
        'travelToNewLocation': _travelToNewLocation,
        'findLongTermWork': _findLongTermWork,
        'careerGoals': _careerGoalsController.text.isEmpty ? null : _careerGoalsController.text,
        'how_heard_about_us': _howHeardAboutUsController.text.isEmpty ? null : _howHeardAboutUsController.text,
        'lookingToAccomplish': _lookingToAccomplishController.text.isEmpty ? null : _lookingToAccomplishController.text,
        'onboardingStatus': 'completed',
        'created_time': DateTime.now(),
      };*/

      // TODO: Save to Firestore using FirestoreService
      // await FirestoreService().createUser(uid: userId, userData: userData);

      // Mark onboarding as complete
      final onboardingService = OnboardingService();
      await onboardingService.markOnboardingComplete();

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Profile setup complete! Welcome to Journeyman Jobs.',
        );

        // Navigate to home after successful save
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go(AppRouter.home);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Error saving profile. Please try again.',
        );
      }
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Basic Information
        return _firstNameController.text.isNotEmpty &&
               _lastNameController.text.isNotEmpty &&
               _phoneController.text.isNotEmpty &&
               _address1Controller.text.isNotEmpty &&
               _cityController.text.isNotEmpty &&
               _stateController.text.isNotEmpty &&
               _zipcodeController.text.isNotEmpty;
      case 1: // Professional Details
        return _homeLocalController.text.isNotEmpty &&
               _ticketNumberController.text.isNotEmpty &&
               _selectedClassification != null;
      case 2: // Preferences & Feedback
        return _selectedConstructionTypes.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primaryNavy),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Setup Profile',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.primaryNavy),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                JJProgressIndicator(
                  currentStep: _currentStep + 1,
                  totalSteps: _totalSteps,
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
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
                    child: JJSecondaryButton(
                      text: 'Back',
                      onPressed: _previousStep,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                
                const SizedBox(width: AppTheme.spacingMd),
                
                Expanded(
                  child: JJPrimaryButton(
                    text: _currentStep == _totalSteps - 1 ? 'Complete' : 'Next',
                    onPressed: _canProceed() ? _nextStep : null,
                    icon: _currentStep == _totalSteps - 1
                        ? Icons.check
                        : Icons.arrow_forward,
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
          _buildStepHeader(
            icon: Icons.person_outline,
            title: 'Basic Information',
            subtitle: 'Let\'s start with your essential details',
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
          Row(
            children: [
              Expanded(
                flex: 3,
                child: JJTextField(
                  label: 'City',
                  controller: _cityController,
                  focusNode: _cityFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_zipcodeFocus),
                  prefixIcon: Icons.location_city_outlined,
                  hintText: 'Enter city',
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                flex: 2,
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
                        border: Border.all(color: AppTheme.lightGray),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        color: AppTheme.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _stateController.text.isEmpty ? null : _stateController.text,
                          hint: Text(
                            'State',
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                          ),
                          isExpanded: true,
                          items: _usStates.map((state) {
                            return DropdownMenuItem(
                              value: state,
                              child: Text(state, style: AppTheme.bodyMedium),
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
                flex: 1,
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
                label: classification,
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
            child: JJCircuitBreakerSwitchListTile(
              title: Text(
                'Currently Working',
                style: AppTheme.titleMedium,
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
            hintText: 'e.g., Book 1, Book 2, Local 456 Book 1',
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
                label: type,
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
              color: AppTheme.white,
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
              color: AppTheme.white,
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
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
                CheckboxListTile(
                  title: Text('Career Advancement', style: AppTheme.bodyMedium),
                  subtitle: Text('Seek leadership roles', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _careerAdvancements,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _careerAdvancements = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Better Benefits', style: AppTheme.bodyMedium),
                  subtitle: Text('Improved benefit packages', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _betterBenefits,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _betterBenefits = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Higher Pay Rate', style: AppTheme.bodyMedium),
                  subtitle: Text('Increase compensation', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _higherPayRate,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _higherPayRate = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Learn New Skills', style: AppTheme.bodyMedium),
                  subtitle: Text('Gain new experience', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _learnNewSkill,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _learnNewSkill = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Travel to New Locations', style: AppTheme.bodyMedium),
                  subtitle: Text('Work in different areas', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _travelToNewLocation,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _travelToNewLocation = value ?? false),
                  dense: true,
                ),
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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient,
            shape: BoxShape.circle,
            boxShadow: [AppTheme.shadowMd],
          ),
          child: Icon(
            icon,
            size: 28,
            color: AppTheme.white,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingSm),
        
        Text(
          title,
          style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppTheme.spacingXs),
        
        Text(
          subtitle,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getConstructionTypeIcon(String type) {
    switch (type) {
      case 'Distribution':
        return Icons.power_outlined;
      case 'Transmission':
        return Icons.electrical_services;
      case 'SubStation':
        return Icons.transform_outlined;
      case 'Residential':
        return Icons.home_outlined;
      case 'Industrial':
        return Icons.factory_outlined;
      case 'Data Center':
        return Icons.storage_outlined;
      case 'Commercial':
        return Icons.business_outlined;
      case 'Underground':
        return Icons.layers_outlined;
      default:
        return Icons.construction_outlined;
    }
  }

}
