import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crew_preferences.dart';
import '../services/crew_service.dart';
import '../../../design_system/app_theme.dart';

class CrewPreferencesDialog extends StatefulWidget {
  final CrewPreferences initialPreferences;
  final String crewId;
  final CrewService crewService;
  final bool isNewCrew; // New parameter to distinguish between new and existing crews

  const CrewPreferencesDialog({
    super.key,
    required this.initialPreferences,
    required this.crewId,
    required this.crewService,
    this.isNewCrew = false, // Default to false for existing crews
  });

  @override
  State<CrewPreferencesDialog> createState() => _CrewPreferencesDialogState();
}

class _CrewPreferencesDialogState extends State<CrewPreferencesDialog> {
  late CrewPreferences _preferences;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Common job types in electrical industry
  final List<String> _availableJobTypes = [
    'Inside Wireman',
    'Journeyman Lineman',
    'Apprentice Lineman',
    'Electrical Foreman',
    'Project Manager',
    'Electrical Engineer',
    'Safety Coordinator',
    'Estimator',
    'Service Technician',
    'Maintenance Electrician',
  ];

  // Common electrical companies
  final List<String> _commonCompanies = [
    'IBEW Local Unions',
    'NECA Contractors',
    'Quanta Services',
    'MYR Group',
    'Mastec',
    'Pike Corporation',
    'PowerTeam Services',
    'Summit Line Construction',
    'Potelco',
    'Henkel',
  ];

  // Common electrical skills
  final List<String> _commonSkills = [
    'High Voltage',
    'Underground Distribution',
    'Overhead Distribution',
    'Substation',
    'Transformer',
    'Motor Control',
    'PLC Programming',
    'Fiber Optics',
    'SCADA Systems',
    'Safety Training',
    'OSHA 30',
    'CDL License',
    'Crane Operation',
    'Welding',
  ];

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences;
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildHeader() {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLg),
          ),
          gradient: AppTheme.electricalGradient,
        ),
        child: Row(
          children: [
            Icon(
              Icons.settings_applications,
              color: AppTheme.white,
              size: AppTheme.iconMd,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              widget.isNewCrew ? 'Set Crew Preferences' : 'Crew Job Preferences',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close,
                color: AppTheme.white,
                size: AppTheme.iconMd,
              ),
            ),
          ],
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          gradient: AppTheme.cardGradient,
          border: Border.all(
            color: AppTheme.borderCopper,
            width: AppTheme.borderWidthThin,
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildJobTypesSection(),
                        const SizedBox(height: AppTheme.spacingMd),
                        _buildWageRangeSection(),
                        const SizedBox(height: AppTheme.spacingMd),
                        _buildLocationSection(),
                        const SizedBox(height: AppTheme.spacingMd),
                        _buildCompaniesSection(),
                        const SizedBox(height: AppTheme.spacingMd),
                        _buildSkillsSection(),
                        const SizedBox(height: AppTheme.spacingMd),
                        _buildAutoShareSection(),
                        const SizedBox(height: AppTheme.spacingMd),
                        _buildMatchThresholdSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Types',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Select the types of electrical jobs your crew is interested in',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingXs,
          runSpacing: AppTheme.spacingXs,
          children: _availableJobTypes.map((jobType) {
            final isSelected = _preferences.jobTypes.contains(jobType);
            return FilterChip(
              label: Text(
                jobType,
                style: AppTheme.bodySmall.copyWith(
                  color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _preferences = _preferences.copyWith(
                      jobTypes: [..._preferences.jobTypes, jobType],
                    );
                  } else {
                    _preferences = _preferences.copyWith(
                      jobTypes: _preferences.jobTypes.where((type) => type != jobType).toList(),
                    );
                  }
                });
              },
              backgroundColor: AppTheme.lightGray,
              selectedColor: AppTheme.accentCopper,
              checkmarkColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                side: BorderSide(
                  color: isSelected ? AppTheme.accentCopper : AppTheme.borderLight,
                  width: AppTheme.borderWidthThin,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWageRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Hourly Rate',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          initialValue: _preferences.minHourlyRate?.toString() ?? '',
          decoration: InputDecoration(
            labelText: 'Minimum hourly rate (\$)',
            hintText: 'e.g., 25.00',
            prefixIcon: Icon(Icons.attach_money, color: AppTheme.accentCopper),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.accentCopper),
            ),
            filled: true,
            fillColor: AppTheme.offWhite,
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final rate = double.tryParse(value);
              if (rate == null || rate < 0) {
                return 'Please enter a valid hourly rate';
              }
            }
            return null;
          },
          onSaved: (value) {
            final rate = value != null && value.isNotEmpty ? double.tryParse(value) : null;
            _preferences = _preferences.copyWith(minHourlyRate: rate);
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Distance',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          initialValue: _preferences.maxDistanceMiles?.toString() ?? '',
          decoration: InputDecoration(
            labelText: 'Maximum distance (miles)',
            hintText: 'e.g., 50',
            prefixIcon: Icon(Icons.location_on, color: AppTheme.accentCopper),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.accentCopper),
            ),
            filled: true,
            fillColor: AppTheme.offWhite,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final distance = int.tryParse(value);
              if (distance == null || distance < 0) {
                return 'Please enter a valid distance';
              }
            }
            return null;
          },
          onSaved: (value) {
            final distance = value != null && value.isNotEmpty ? int.tryParse(value) : null;
            _preferences = _preferences.copyWith(maxDistanceMiles: distance);
          },
        ),
      ],
    );
  }

  Widget _buildCompaniesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Companies',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Select companies you prefer to work with',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingXs,
          runSpacing: AppTheme.spacingXs,
          children: _commonCompanies.map((company) {
            final isSelected = _preferences.preferredCompanies.contains(company);
            return FilterChip(
              label: Text(
                company,
                style: AppTheme.bodySmall.copyWith(
                  color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _preferences = _preferences.copyWith(
                      preferredCompanies: [..._preferences.preferredCompanies, company],
                    );
                  } else {
                    _preferences = _preferences.copyWith(
                      preferredCompanies: _preferences.preferredCompanies.where((c) => c != company).toList(),
                    );
                  }
                });
              },
              backgroundColor: AppTheme.lightGray,
              selectedColor: AppTheme.accentCopper,
              checkmarkColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                side: BorderSide(
                  color: isSelected ? AppTheme.accentCopper : AppTheme.borderLight,
                  width: AppTheme.borderWidthThin,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Skills',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Select skills that crew members must have',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingXs,
          runSpacing: AppTheme.spacingXs,
          children: _commonSkills.map((skill) {
            final isSelected = _preferences.requiredSkills.contains(skill);
            return FilterChip(
              label: Text(
                skill,
                style: AppTheme.bodySmall.copyWith(
                  color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _preferences = _preferences.copyWith(
                      requiredSkills: [..._preferences.requiredSkills, skill],
                    );
                  } else {
                    _preferences = _preferences.copyWith(
                      requiredSkills: _preferences.requiredSkills.where((s) => s != skill).toList(),
                    );
                  }
                });
              },
              backgroundColor: AppTheme.lightGray,
              selectedColor: AppTheme.accentCopper,
              checkmarkColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                side: BorderSide(
                  color: isSelected ? AppTheme.accentCopper : AppTheme.borderLight,
                  width: AppTheme.borderWidthThin,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAutoShareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Auto-Share Settings',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        SwitchListTile(
          title: Text(
            'Automatically share matching jobs with crew',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            'When enabled, jobs matching your preferences will be automatically shared',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          value: _preferences.autoShareEnabled,
          onChanged: (value) {
            setState(() {
              _preferences = _preferences.copyWith(autoShareEnabled: value);
            });
          },
          activeColor: AppTheme.accentCopper,
          tileColor: AppTheme.offWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            side: BorderSide(color: AppTheme.borderLight),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchThresholdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match Threshold',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Minimum match score required for job recommendations',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            Text(
              '0%',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Expanded(
              child: Slider(
                value: _preferences.matchThreshold.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_preferences.matchThreshold}%',
                onChanged: (value) {
                  setState(() {
                    _preferences = _preferences.copyWith(
                      matchThreshold: value.round(),
                    );
                  });
                },
                activeColor: AppTheme.accentCopper,
                inactiveColor: AppTheme.lightGray,
              ),
            ),
            Text(
              '100%',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: AppTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            color: AppTheme.accentCopper.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: AppTheme.accentCopper.withValues(alpha: 0.3),
              width: AppTheme.borderWidthThin,
            ),
          ),
          child: Text(
            '${_preferences.matchThreshold}% Match Required',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.radiusLg),
        ),
        color: AppTheme.offWhite,
        border: Border(
          top: BorderSide(color: AppTheme.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppTheme.mediumGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTheme.buttonMedium.copyWith(
                  color: AppTheme.mediumGray,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : Text(
                      'Save Preferences',
                      style: AppTheme.buttonMedium.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isNewCrew) {
        // For new crews, we'll return the preferences to the creator
        // The creator will handle the actual crew creation with these preferences
        if (mounted) {
          Navigator.of(context).pop(_preferences);
        }
      } else {
        // For existing crews, update the preferences directly
        await widget.crewService.updateCrew(
          crewId: widget.crewId,
          preferences: _preferences,
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Crew preferences updated successfully!'),
              backgroundColor: AppTheme.successGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.isNewCrew ? 'set' : 'update'} preferences: $e'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}