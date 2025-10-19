import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_job_preferences.dart';
import '../../providers/riverpod/user_preferences_riverpod_provider.dart';
import '../../design_system/app_theme.dart';
import '../../electrical_components/jj_electrical_notifications.dart';

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

  /// Tracks whether the save operation is currently in progress
  /// to prevent duplicate saves and provide visual feedback
  bool _isSaving = false;

  // Available options for form fields - IBEW-specific classifications only
  final List<String> _availableClassifications = [
    'Journeyman Lineman',
    'Journeyman Wireman',
    'Journeyman Electrician',
    'Journeyman Tree Trimmer',
    'Equipment Operator',
  ];

  // IBEW-relevant construction types only
  final List<String> _availableConstructionTypes = [
    'Commercial',
    'Industrial',
    'Residential',
    'Utility/Power',
    'Distribution',
    'Transmission',
    'Substation',
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

  /// Parses the comma-separated list of local numbers from the text field
  /// Returns a list of valid integers, filtering out invalid entries
  List<int> _parseLocals() {
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
    return locals;
  }

  /// Saves or updates user job preferences to Firebase
  ///
  /// This method is async to properly await Firebase operations before
  /// closing the dialog. It includes comprehensive error handling and
  /// user feedback via electrical toast notifications.
  ///
  /// The save operation follows these steps:
  /// 1. Validate form input
  /// 2. Check user authentication
  /// 3. Parse and prepare preference data
  /// 4. Await Firebase save/update operation
  /// 5. Show success/error notification
  /// 6. Close dialog only after successful save
  Future<void> _savePreferences() async {
    // Validate all form fields before proceeding
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure user is authenticated before attempting Firebase operations
      if (widget.userId.isEmpty) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Error: User not authenticated',
          type: ElectricalNotificationType.error,
        );
        return;
      }

      // Parse preferred locals from the text input field
      final updatedPreferences = _currentPreferences.copyWith(
        preferredLocals: _parseLocals(),
      );

      try {
        // Set loading state to prevent duplicate saves and show visual feedback
        setState(() => _isSaving = true);

        final provider = widget.ref.read(userPreferencesProvider.notifier);

        // Await Firebase operation based on whether this is first-time setup or update
        if (widget.isFirstTime) {
          await provider.savePreferences(widget.userId, updatedPreferences);
        } else {
          await provider.updatePreferences(widget.userId, updatedPreferences);
        }

        // Only proceed if widget is still mounted (user hasn't navigated away)
        if (mounted) {
          // Show success notification using electrical-themed toast
          JJElectricalNotifications.showElectricalToast(
            context: context,
            message: 'Job preferences saved successfully',
            type: ElectricalNotificationType.success,
          );

          // Safe to close dialog now that save is complete
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        // Log error for debugging purposes
        debugPrint('Error saving preferences: $e');

        // Only show error UI if widget is still mounted
        if (mounted) {
          // Show error notification with electrical-themed toast
          JJElectricalNotifications.showElectricalToast(
            context: context,
            message: 'Error saving preferences. Please try again.',
            type: ElectricalNotificationType.error,
          );
        }
      } finally {
        // Always clear loading state when operation completes
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
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

  /// Footer with responsive Save and Cancel buttons
  /// Prevents overflow on smaller screens by using Flexible widgets
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
          Flexible(
            child: TextButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
              child: Text('Cancel'),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Flexible(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
              ),
              child: _isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                    ),
                  )
                : Text('Save Preferences', overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
