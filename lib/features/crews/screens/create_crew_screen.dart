import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/app_theme.dart';
import '../models/crew_enums.dart';
import '../providers/crew_provider.dart';

/// Form screen for creating new electrical worker crews
/// 
/// Provides a comprehensive interface for IBEW workers to create crews
/// with proper classification, location, and professional requirements.
class CreateCrewScreen extends ConsumerStatefulWidget {
  const CreateCrewScreen({super.key});

  @override
  ConsumerState<CreateCrewScreen> createState() => _CreateCrewScreenState();
}

class _CreateCrewScreenState extends ConsumerState<CreateCrewScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _travelRadiusController = TextEditingController(text: '50');
  final TextEditingController _maxMembersController = TextEditingController(text: '10');
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _perDiemController = TextEditingController();
  final TextEditingController _unionLocalController = TextEditingController();
  
  // Form State
  Set<JobType> _selectedJobTypes = {};
  Set<String> _selectedClassifications = {};
  bool _isPrivate = false;
  bool _isStormCrew = false;
  bool _isEmergencyCrew = false;
  bool _allowJobSharing = true;
  bool _allowInvitations = true;
  bool _isLoading = false;

  // IBEW Classifications
  static const List<String> _ibewClassifications = [
    'Inside Wireman',
    'Journeyman Lineman',
    'Tree Trimmer',
    'Equipment Operator',
    'Inside Journeyman Electrician',
    'Maintenance Lineman',
    'Testing Technician',
    'Substation Specialist',
    'Underground Specialist',
    'Transmission Specialist',
    'Distribution Specialist',
    'Telecommunications Technician',
    'Traffic Signal Technician',
    'Railroad Electrician',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _travelRadiusController.dispose();
    _maxMembersController.dispose();
    _hourlyRateController.dispose();
    _perDiemController.dispose();
    _unionLocalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Create Crew',
        style: TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.primaryNavy,
      elevation: 2,
      shadowColor: AppTheme.shadowColor.withValues(alpha: 0.2),
      iconTheme: const IconThemeData(color: AppTheme.white),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _saveCrewAndReturn,
          child: Text(
            'Save',
            style: TextStyle(
              color: _isLoading ? AppTheme.lightGray : AppTheme.accentCopper,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCrewBasicsSection(),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildIBEWSpecificationsSection(),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildLocationAndAvailabilitySection(),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildRatesAndRequirementsSection(),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildPrivacyAndPermissionsSection(),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildCrewBasicsSection() {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.shadowColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Crew Basics', Icons.group),
            const SizedBox(height: AppTheme.spacingMd),
            _buildNameField(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildDescriptionField(),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Expanded(child: _buildMaxMembersField()),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(child: _buildUnionLocalField()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIBEWSpecificationsSection() {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.shadowColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('IBEW Classifications', Icons.engineering),
            const SizedBox(height: AppTheme.spacingMd),
            _buildClassificationsField(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildJobTypesField(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAndAvailabilitySection() {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.shadowColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Location & Availability', Icons.location_on),
            const SizedBox(height: AppTheme.spacingMd),
            _buildLocationField(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildTravelRadiusField(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildAvailabilityToggles(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatesAndRequirementsSection() {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.shadowColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Rates & Requirements', Icons.attach_money),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Expanded(child: _buildHourlyRateField()),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(child: _buildPerDiemField()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyAndPermissionsSection() {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.shadowColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Privacy & Permissions', Icons.security),
            const SizedBox(height: AppTheme.spacingMd),
            _buildPrivacyToggles(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentCopper.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentCopper,
            size: 20,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      maxLength: 50,
      decoration: const InputDecoration(
        labelText: 'Crew Name*',
        hintText: 'e.g., Lightning Linemen, Storm Chasers, Local 123 Crew A',
        prefixIcon: Icon(Icons.bolt, color: AppTheme.accentCopper),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Crew name is required';
        }
        if (value.trim().length < 3) {
          return 'Crew name must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      maxLength: 200,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Describe your crew\'s experience, specializations, and approach',
        prefixIcon: Icon(Icons.description, color: AppTheme.accentCopper),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
      ),
    );
  }

  Widget _buildMaxMembersField() {
    return TextFormField(
      controller: _maxMembersController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Max Members*',
        prefixIcon: Icon(Icons.group, color: AppTheme.accentCopper),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        final number = int.tryParse(value);
        if (number == null || number < 2 || number > 50) {
          return '2-50 members';
        }
        return null;
      },
    );
  }

  Widget _buildUnionLocalField() {
    return TextFormField(
      controller: _unionLocalController,
      decoration: const InputDecoration(
        labelText: 'Home Local',
        hintText: 'e.g., Local 123, Local 456',
        prefixIcon: Icon(Icons.business, color: AppTheme.accentCopper),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          // Basic validation for local format
          if (!RegExp(r'^Local\s+\d+$', caseSensitive: false).hasMatch(value.trim())) {
            return 'Format: Local 123';
          }
        }
        return null;
      },
    );
  }

  Widget _buildClassificationsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required Classifications*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedClassifications.isEmpty 
                  ? AppTheme.errorRed 
                  : AppTheme.lightGray,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ibewClassifications.map((classification) {
              final isSelected = _selectedClassifications.contains(classification);
              return FilterChip(
                label: Text(classification),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedClassifications.add(classification);
                    } else {
                      _selectedClassifications.remove(classification);
                    }
                  });
                },
                selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.accentCopper,
                side: BorderSide(
                  color: isSelected ? AppTheme.accentCopper : AppTheme.lightGray,
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedClassifications.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'At least one classification is required',
              style: TextStyle(
                color: AppTheme.errorRed,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildJobTypesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Job Types*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedJobTypes.isEmpty 
                  ? AppTheme.errorRed 
                  : AppTheme.lightGray,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: JobType.values.map((jobType) {
              final isSelected = _selectedJobTypes.contains(jobType);
              return FilterChip(
                label: Text(jobType.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedJobTypes.add(jobType);
                    } else {
                      _selectedJobTypes.remove(jobType);
                    }
                  });
                },
                selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.accentCopper,
                side: BorderSide(
                  color: isSelected ? AppTheme.accentCopper : AppTheme.lightGray,
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedJobTypes.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'At least one job type is required',
              style: TextStyle(
                color: AppTheme.errorRed,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Base Location',
        hintText: 'City, State or Region',
        prefixIcon: Icon(Icons.location_city, color: AppTheme.accentCopper),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
      ),
    );
  }

  Widget _buildTravelRadiusField() {
    return TextFormField(
      controller: _travelRadiusController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Travel Radius (miles)',
        prefixIcon: Icon(Icons.my_location, color: AppTheme.accentCopper),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = int.tryParse(value);
          if (number == null || number < 1 || number > 500) {
            return '1-500 miles';
          }
        }
        return null;
      },
    );
  }

  Widget _buildAvailabilityToggles() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            'Storm Work Crew',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Available for emergency storm restoration'),
          value: _isStormCrew,
          onChanged: (value) => setState(() => _isStormCrew = value),
          activeColor: AppTheme.accentCopper,
          secondary: const Icon(Icons.thunderstorm, color: AppTheme.accentCopper),
        ),
        SwitchListTile(
          title: const Text(
            'Emergency Response',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Available for emergency call-outs'),
          value: _isEmergencyCrew,
          onChanged: (value) => setState(() => _isEmergencyCrew = value),
          activeColor: AppTheme.accentCopper,
          secondary: const Icon(Icons.emergency, color: AppTheme.errorRed),
        ),
      ],
    );
  }

  Widget _buildHourlyRateField() {
    return TextFormField(
      controller: _hourlyRateController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Hourly Rate',
        hintText: '\$45.00',
        prefixText: '\$',
        prefixIcon: Icon(Icons.attach_money, color: AppTheme.accentCopper),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value);
          if (number == null || number < 0) {
            return 'Invalid rate';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPerDiemField() {
    return TextFormField(
      controller: _perDiemController,
      decoration: const InputDecoration(
        labelText: 'Per Diem Requirements',
        hintText: 'e.g., \$75/day, Hotel + \$50',
        prefixIcon: Icon(Icons.hotel, color: AppTheme.accentCopper),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
      ),
    );
  }

  Widget _buildPrivacyToggles() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            'Private Crew',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Invite-only, not visible in public listings'),
          value: _isPrivate,
          onChanged: (value) => setState(() => _isPrivate = value),
          activeColor: AppTheme.accentCopper,
          secondary: const Icon(Icons.lock, color: AppTheme.accentCopper),
        ),
        SwitchListTile(
          title: const Text(
            'Allow Job Sharing',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Members can share job opportunities'),
          value: _allowJobSharing,
          onChanged: (value) => setState(() => _allowJobSharing = value),
          activeColor: AppTheme.accentCopper,
          secondary: const Icon(Icons.share, color: AppTheme.accentCopper),
        ),
        SwitchListTile(
          title: const Text(
            'Allow Invitations',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Accept new member invitations'),
          value: _allowInvitations,
          onChanged: (value) => setState(() => _allowInvitations = value),
          activeColor: AppTheme.accentCopper,
          secondary: const Icon(Icons.person_add, color: AppTheme.accentCopper),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
            ),
          ),
          SizedBox(width: AppTheme.spacingMd),
          Text(
            'Creating crew...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCrewAndReturn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClassifications.isEmpty) {
      _showError('Please select at least one classification');
      return;
    }

    if (_selectedJobTypes.isEmpty) {
      _showError('Please select at least one job type');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user ID (this would normally come from auth provider)
      const String currentUserId = 'current_user_id'; // TODO: Get from auth provider
      
      final crew = await ref.read(crewProvider.notifier).createCrew(
        creatorId: currentUserId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        classifications: _selectedClassifications.toList(),
        jobTypes: _selectedJobTypes.toList(),
        maxMembers: int.parse(_maxMembersController.text),
        isPublic: !_isPrivate,
      );

      if (crew != null && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Crew "${crew.name}" created successfully!'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Return to previous screen
        Navigator.of(context).pop(crew);
      } else if (mounted) {
        _showError('Failed to create crew. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error creating crew: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
