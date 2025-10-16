import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_job_preferences.dart';
import '../../providers/riverpod/user_preferences_riverpod_provider.dart';
import '../../design_system/app_theme.dart';

class UserJobPreferencesDialog extends ConsumerWidget {
  final UserJobPreferences? initialPreferences;
  final String userId;
  final bool isFirstTime;

  const UserJobPreferencesDialog({
    super.key,
    this.initialPreferences,
    required this.userId,
    required this.isFirstTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          gradient: AppTheme.electricalGradient,
          border: Border.all(
            color: AppTheme.borderCopper,
            width: AppTheme.borderWidthThin,
          ),
        ),
        child: _UserJobPreferencesDialogContent(
          initialPreferences: initialPreferences,
          userId: userId,
          isFirstTime: isFirstTime,
          ref: ref,
        ),
      ),
    );
  }
}

class _UserJobPreferencesDialogContent extends StatefulWidget {
  final UserJobPreferences? initialPreferences;
  final String userId;
  final bool isFirstTime;
  final WidgetRef ref;

  const _UserJobPreferencesDialogContent({
    this.initialPreferences,
    required this.userId,
    required this.isFirstTime,
    required this.ref,
  });

  @override
  _UserJobPreferencesDialogContentState createState() => _UserJobPreferencesDialogContentState();
}

class _UserJobPreferencesDialogContentState extends State<_UserJobPreferencesDialogContent> {
  late UserJobPreferences _currentPreferences;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _localsController = TextEditingController();

  // Available options for form fields
  final List<String> _availableClassifications = [
    'Journeyman Electrician',
    'Apprentice Electrician',
    'Master Electrician',
    'Electrical Engineer',
    'Power Systems Technician',
    'Industrial Electrician',
    'Commercial Electrician',
    'Residential Electrician',
    'Maintenance Electrician',
    'Instrumentation Technician'
  ];

  final List<String> _availableConstructionTypes = [
    'Commercial',
    'Industrial',
    'Residential',
    'Utility/Power',
    'Renewable Energy',
    'Data Centers',
    'Healthcare',
    'Education',
    'Transportation',
    'Manufacturing'
  ];

  final List<String> _hoursPerWeekOptions = [
    '40-50',
    '50-60',
    '60-70',
    '70+'
  ];

  final List<String> _perDiemOptions = [
    '50-75',
    '75-100',
    '100-125',
    '125-150',
    '150-200',
    '200+'
  ];

  @override
  void initState() {
    super.initState();
    _currentPreferences = widget.initialPreferences ?? UserJobPreferences.empty();
    if (_currentPreferences.preferredLocals.isNotEmpty) {
      _localsController.text = _currentPreferences.preferredLocals.join(', ');
    }
  }

  @override
  void dispose() {
    _localsController.dispose();
    super.dispose();
  }

  void _savePreferences() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Parse locals from text input
      final localsText = _localsController.text.trim();
      final locals = <int>[];
      if (localsText.isNotEmpty) {
        final localStrings = localsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final localStr in localStrings) {
          final local = int.tryParse(localStr);
          if (local != null) {
            locals.add(local);
          }
        }
      }

      final updatedPreferences = _currentPreferences.copyWith(
        preferredLocals: locals,
      );

      final provider = widget.ref.read(userPreferencesProvider.notifier);
      if (widget.isFirstTime) {
        provider.savePreferences(widget.userId, updatedPreferences);
      } else {
        provider.updatePreferences(widget.userId, updatedPreferences);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job preferences saved successfully!'),
          backgroundColor: AppTheme.successGreen,
        )
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _buildHeader(),
        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClassificationsSection(),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildConstructionTypesSection(),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildPreferredLocalsSection(),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildHoursPerWeekSection(),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildPerDiemSection(),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildMinimumWageSection(),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildMaximumDistanceSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Footer
        _buildFooter(),
      ],
    );
  }

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
            Icons.work_outline,
            color: AppTheme.white,
            size: AppTheme.iconMd,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              widget.isFirstTime ? 'Set Job Preferences' : 'Job Preferences',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildClassificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Classifications',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Select the job classifications you are qualified for',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingXs,
          runSpacing: AppTheme.spacingXs,
          children: _availableClassifications.map((classification) {
            final isSelected = _currentPreferences.classifications.contains(classification);
            return FilterChip(
              label: Text(
                classification,
                style: AppTheme.bodySmall.copyWith(
                  color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _currentPreferences = _currentPreferences.copyWith(
                      classifications: [..._currentPreferences.classifications, classification],
                    );
                  } else {
                    _currentPreferences = _currentPreferences.copyWith(
                      classifications: _currentPreferences.classifications.where((c) => c != classification).toList(),
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

  Widget _buildConstructionTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Construction Types',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Select the types of construction work you prefer',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingXs,
          runSpacing: AppTheme.spacingXs,
          children: _availableConstructionTypes.map((constructionType) {
            final isSelected = _currentPreferences.constructionTypes.contains(constructionType);
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
                    _currentPreferences = _currentPreferences.copyWith(
                      constructionTypes: [..._currentPreferences.constructionTypes, constructionType],
                    );
                  } else {
                    _currentPreferences = _currentPreferences.copyWith(
                      constructionTypes: _currentPreferences.constructionTypes.where((c) => c != constructionType).toList(),
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

  Widget _buildPreferredLocalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred IBEW Locals',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: _localsController,
          decoration: InputDecoration(
            labelText: 'Local numbers (comma separated)',
            hintText: 'e.g., 11, 26, 103',
            prefixIcon: Icon(Icons.location_city, color: AppTheme.accentCopper),
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
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final locals = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
              for (final local in locals) {
                if (int.tryParse(local) == null) {
                  return 'Please enter valid local numbers';
                }
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildHoursPerWeekSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hours Per Week',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        DropdownButtonFormField<String>(
          value: _currentPreferences.hoursPerWeek,
          decoration: InputDecoration(
            labelText: 'Preferred hours per week',
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
          items: _hoursPerWeekOptions.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _currentPreferences = _currentPreferences.copyWith(hoursPerWeek: value);
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select preferred hours per week';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPerDiemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Per Diem Requirement',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        DropdownButtonFormField<String>(
          value: _currentPreferences.perDiemRequirement,
          decoration: InputDecoration(
            labelText: 'Minimum per diem amount',
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
          items: _perDiemOptions.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _currentPreferences = _currentPreferences.copyWith(perDiemRequirement: value);
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select minimum per diem amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMinimumWageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Hourly Wage',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          initialValue: _currentPreferences.minWage?.toString(),
          decoration: InputDecoration(
            labelText: 'Minimum hourly wage (\$)',
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
              final wage = double.tryParse(value);
              if (wage == null || wage < 0) {
                return 'Please enter a valid hourly wage';
              }
            }
            return null;
          },
          onSaved: (value) {
            final wage = value != null && value.isNotEmpty ? double.tryParse(value) : null;
            _currentPreferences = _currentPreferences.copyWith(minWage: wage);
          },
        ),
      ],
    );
  }

  Widget _buildMaximumDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Travel Distance',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          initialValue: _currentPreferences.maxDistance?.toString(),
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
            _currentPreferences = _currentPreferences.copyWith(maxDistance: distance);
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.radiusLg),
        ),
        border: Border(
          top: BorderSide(color: AppTheme.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
            ),
            child: Text('Cancel'),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          ElevatedButton(
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCopper,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            child: Text('Save Preferences'),
          ),
        ],
      ),
    );
  }
}
