import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crew_preferences.dart';
import '../services/crew_service.dart';
import '../../../design_system/app_theme.dart';
import '../../../domain/enums/enums.dart';
import '../../../utils/text_formatting_wrapper.dart';

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

  // Job types/classifications available for electrical workers
  final List<String> _availableJobTypes = Classification.all.map((e) => toTitleCase(e)).toList();

  // Common construction types
  final List<String> _availableConstructionTypes = ConstructionTypes.all.map((e) => toTitleCase(e)).toList();

  // Common electrical companies
  final List<String> _commonCompanies = [
    'IBEW Local Unions',
    'NECA Contractors',
    'Quanta Services',
    'MYR Group',
    'PowerTeam Services',
    'Summit Line Construction',
    'Potelco',
    'Henkel',
  ];

  // Common electrical skills
  final List<String> _commonSkills = [
    'Underground Distribution',
    'Overhead Distribution',
    'Substation',
    'OSHA 30',
    'CDL License',
    'Crane Operation',
  ];

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildHeader() {
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
            Expanded(
              child: Text(
                widget.isNewCrew ? 'Set Crew Preferences' : 'Crew Job Preferences',
                style: AppTheme.headlineMedium.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
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
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
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
            buildHeader(),
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
                        // Quick presets section for fast configuration
                        _buildPresetsSection(),
                        const SizedBox(height: AppTheme.spacingLg),

                        // Job types/classifications section (ADDED)
                        _buildJobTypesSection(),
                        const SizedBox(height: AppTheme.spacingMd),

                        _buildConstructionTypesSection(),
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

  /// Quick preset templates for common crew configurations
  /// Allows rapid setup with industry-standard preferences
  Widget _buildPresetsSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentCopper.withValues(alpha: 0.1),
            AppTheme.primaryNavy.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.3),
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: AppTheme.accentCopper, size: AppTheme.iconSm),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                'Quick Setup',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Select a preset to quickly configure common job preferences',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Wrap(
            spacing: AppTheme.spacingXs,
            runSpacing: AppTheme.spacingXs,
            children: [
              _buildPresetChip(
                label: 'Lineman',
                icon: Icons.electrical_services,
                onTap: () => _applyPreset(_linemanPreset()),
              ),
              _buildPresetChip(
                label: 'Inside Wireman',
                icon: Icons.business,
                onTap: () => _applyPreset(_insideWiremanPreset()),
              ),
              _buildPresetChip(
                label: 'Tree Trimmer',
                icon: Icons.nature,
                onTap: () => _applyPreset(_treeTrimmerPreset()),
              ),
              _buildPresetChip(
                label: 'Storm Work',
                icon: Icons.storm,
                onTap: () => _applyPreset(_stormWorkPreset()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Individual preset chip button
  Widget _buildPresetChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: AppTheme.accentCopper.withValues(alpha: 0.3),
            width: AppTheme.borderWidthThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.accentCopper, size: AppTheme.iconXs),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Job types/classifications section for electrical workers
  /// Allows selection of multiple worker classifications
  Widget _buildJobTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.work, color: AppTheme.accentCopper, size: AppTheme.iconSm),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              'Job Classifications',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          'Select the job types your crew is qualified for',
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
              backgroundColor: AppTheme.offWhite,
              selectedColor: AppTheme.accentCopper,
              checkmarkColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                side: BorderSide(
                  color: isSelected ? AppTheme.accentCopper : AppTheme.borderLight,
                  width: isSelected ? 2 : AppTheme.borderWidthThin,
                ),
              ),
            );
          }).toList(),
        ),
        if (_preferences.jobTypes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingXs),
            child: Text(
              '⚠️ Select at least one job classification',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.warningOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConstructionTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.construction, color: AppTheme.accentCopper, size: AppTheme.iconSm),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              'Construction Types',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Select the construction types your crew works on',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingXs,
          runSpacing: AppTheme.spacingXs,
          children: _availableConstructionTypes.map((constructionType) {
            final isSelected = _preferences.constructionTypes.contains(constructionType);
            return FilterChip(
              label: Text(
                constructionType,
                style: AppTheme.bodySmall.copyWith(
                  color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _preferences = _preferences.copyWith(
                      constructionTypes: [..._preferences.constructionTypes, constructionType],
                    );
                  } else {
                    _preferences = _preferences.copyWith(
                      constructionTypes: _preferences.constructionTypes.where((type) => type != constructionType).toList(),
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
          activeThumbColor: AppTheme.accentCopper,
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
                      'Save',
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

  /// Apply a preset configuration to preferences
  void _applyPreset(CrewPreferences preset) {
    setState(() {
      _preferences = preset;
    });

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preset applied! Review and adjust as needed.'),
        backgroundColor: AppTheme.accentCopper,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Lineman preset configuration
  /// Optimized for utility line work, transmission, and distribution
  CrewPreferences _linemanPreset() {
    return CrewPreferences(
      jobTypes: ['Journeyman Lineman'],
      constructionTypes: ['Distribution', 'Transmission', 'Sub Station'],
      minHourlyRate: 45.0,
      maxDistanceMiles: 100,
      preferredCompanies: ['IBEW Local Unions', 'Quanta Services', 'MYR Group'],
      requiredSkills: ['Overhead Distribution', 'CDL License'],
      autoShareEnabled: true,
      matchThreshold: 60,
    );
  }

  /// Inside Wireman preset configuration
  /// Optimized for commercial and industrial electrical work
  CrewPreferences _insideWiremanPreset() {
    return CrewPreferences(
      jobTypes: ['Journeyman Wireman', 'Journeyman Electrician'],
      constructionTypes: ['Commercial', 'Industrial', 'Data Center'],
      minHourlyRate: 35.0,
      maxDistanceMiles: 50,
      preferredCompanies: ['NECA Contractors', 'IBEW Local Unions'],
      requiredSkills: ['OSHA 30'],
      autoShareEnabled: true,
      matchThreshold: 50,
    );
  }

  /// Tree Trimmer preset configuration
  /// Optimized for vegetation management and utility clearing
  CrewPreferences _treeTrimmerPreset() {
    return CrewPreferences(
      jobTypes: ['Journeyman Tree Trimmer'],
      constructionTypes: ['Distribution', 'Transmission'],
      minHourlyRate: 30.0,
      maxDistanceMiles: 75,
      preferredCompanies: ['IBEW Local Unions'],
      requiredSkills: ['CDL License'],
      autoShareEnabled: true,
      matchThreshold: 55,
    );
  }

  /// Storm Work preset configuration
  /// Optimized for emergency restoration and high-mobility crews
  CrewPreferences _stormWorkPreset() {
    return CrewPreferences(
      jobTypes: ['Journeyman Lineman', 'Operator'],
      constructionTypes: ['Distribution', 'Transmission', 'Underground'],
      minHourlyRate: 50.0,
      maxDistanceMiles: 500, // Storm work often requires travel
      preferredCompanies: ['PowerTeam Services', 'Summit Line Construction', 'Quanta Services'],
      requiredSkills: ['Overhead Distribution', 'CDL License', 'Crane Operation'],
      autoShareEnabled: true,
      matchThreshold: 40, // Lower threshold for urgent storm work
    );
  }

  /// Saves crew preferences with comprehensive validation and error handling
  ///
  /// IMPORTANT: This method handles two scenarios:
  /// 1. New Crew Creation: Returns preferences to caller (no Firestore operation)
  /// 2. Existing Crew Update: Saves preferences to Firestore via CrewService
  ///
  /// Enhanced error handling includes:
  /// - Pre-save validation (job types, construction types, form fields)
  /// - Detailed error logging for debugging
  /// - User-friendly error messages based on error codes
  /// - Offline mode support
  /// - Authentication state checking
  Future<void> _savePreferences() async {
    // Enhanced validation before saving
    if (!_formKey.currentState!.validate()) {
      debugPrint('[CrewPreferencesDialog] Form validation failed');
      return;
    }

    // Validate at least one job type is selected
    if (_preferences.jobTypes.isEmpty) {
      debugPrint('[CrewPreferencesDialog] Validation failed: No job types selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ Please select at least one job classification'),
            backgroundColor: AppTheme.warningOrange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Validate at least one construction type is selected
    if (_preferences.constructionTypes.isEmpty) {
      debugPrint('[CrewPreferencesDialog] Validation failed: No construction types selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ Please select at least one construction type'),
            backgroundColor: AppTheme.warningOrange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('[CrewPreferencesDialog] Starting save operation');
      debugPrint('[CrewPreferencesDialog] isNewCrew: ${widget.isNewCrew}');
      debugPrint('[CrewPreferencesDialog] crewId: ${widget.crewId}');
      debugPrint('[CrewPreferencesDialog] jobTypes: ${_preferences.jobTypes}');
      debugPrint('[CrewPreferencesDialog] constructionTypes: ${_preferences.constructionTypes}');
      debugPrint('[CrewPreferencesDialog] autoShareEnabled: ${_preferences.autoShareEnabled}');

      if (widget.isNewCrew) {
        // For new crews, we'll return the preferences to the creator
        // The creator will handle the actual crew creation with these preferences
        debugPrint('[CrewPreferencesDialog] Returning preferences to creator (new crew scenario)');
        if (mounted) {
          Navigator.of(context).pop(_preferences);
        }
      } else {
        // For existing crews, validate crew ID before attempting update
        if (widget.crewId.isEmpty) {
          debugPrint('[CrewPreferencesDialog] ERROR: Empty crew ID provided');
          throw Exception('Invalid crew ID. Cannot save preferences without a valid crew.');
        }

        debugPrint('[CrewPreferencesDialog] Calling CrewService.updateCrew for existing crew');

        // For existing crews, update the preferences directly
        await widget.crewService.updateCrew(
          crewId: widget.crewId,
          preferences: _preferences,
        );

        debugPrint('[CrewPreferencesDialog] Crew preferences updated successfully');

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Crew preferences updated successfully!'),
              backgroundColor: AppTheme.successGreen,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[CrewPreferencesDialog] ERROR: Failed to save preferences');
      debugPrint('[CrewPreferencesDialog] Error: $e');
      debugPrint('[CrewPreferencesDialog] Stack trace: $stackTrace');

      if (mounted) {
        // Determine user-friendly error message based on error type
        String errorMessage = 'Failed to ${widget.isNewCrew ? 'set' : 'update'} preferences';

        final errorString = e.toString().toLowerCase();

        if (errorString.contains('permission') || errorString.contains('denied')) {
          errorMessage = 'Permission denied. Please ensure you are a crew member and try again.';
        } else if (errorString.contains('unauthenticated') || errorString.contains('authentication')) {
          errorMessage = 'Authentication required. Please sign in and try again.';
        } else if (errorString.contains('not found') || errorString.contains('crew-not-found')) {
          errorMessage = 'Crew not found. The crew may have been deleted.';
        } else if (errorString.contains('network') || errorString.contains('unavailable')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (errorString.contains('invalid crew id')) {
          errorMessage = 'Invalid crew. Please navigate back and try again.';
        }

        debugPrint('[CrewPreferencesDialog] Showing error to user: $errorMessage');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppTheme.white,
              onPressed: () => _savePreferences(),
            ),
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