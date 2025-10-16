import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../domain/enums/enums.dart'; // For Classification and ConstructionTypes
import '../../utils/text_formatting_wrapper.dart'; // For toTitleCase
import '../../design_system/components/reusable_components.dart' hide JJSnackBar; // For JJTextField, JJButton
import '../../electrical_components/jj_snack_bar.dart'; // For JJSnackBar
import '../../models/user_job_preferences.dart';
import '../../providers/riverpod/user_preferences_riverpod_provider.dart';

class UserJobPreferencesDialog extends ConsumerStatefulWidget {
  final UserJobPreferences? initialPreferences;
  final String userId;
  final bool isFirstTime;

  const UserJobPreferencesDialog({
    super.key,
    this.initialPreferences,
    required this.userId,
    this.isFirstTime = false,
  });

  @override
  ConsumerState<UserJobPreferencesDialog> createState() => _UserJobPreferencesDialogState();
}

class _UserJobPreferencesDialogState extends ConsumerState<UserJobPreferencesDialog> {
  final _formKey = GlobalKey<FormState>();
  late UserJobPreferences _preferences;
  bool _isLoading = false;

  // Controllers for text fields
  late TextEditingController _preferredLocalsController;
  late TextEditingController _minimumWageController;
  late TextEditingController _maximumDistanceController;

  // Focus nodes for text fields
  final FocusNode _preferredLocalsFocus = FocusNode();
  final FocusNode _minimumWageFocus = FocusNode();
  final FocusNode _maximumDistanceFocus = FocusNode();

  // Dropdown options
  final List<String> _hoursPerWeekOptions = ['40-50', '50-60', '60-70', '>70'];
  final List<String> _perDiemOptions = [
    '\$100-\$150',
    '\$150-\$200',
    '\$200-\$250',
    '\$250-\$300',
    'Not Required'
  ];

  // Multi-select chip options (from onboarding_steps_screen.dart)
  final List<String> _availableClassifications = Classification.values.map((e) => toTitleCase(e.name)).toList();
  final List<String> _availableConstructionTypes = ConstructionTypes.values.map((e) => toTitleCase(e.name)).toList();

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences ?? UserJobPreferences.empty();

    _preferredLocalsController = TextEditingController(text: _preferences.preferredLocals.map((e) => e.toString()).join(', '));
    _minimumWageController = TextEditingController(text: _preferences.minWage?.toStringAsFixed(2) ?? '');
    _maximumDistanceController = TextEditingController(text: _preferences.maxDistance?.toString() ?? '');
  }

  @override
  void dispose() {
    _preferredLocalsController.dispose();
    _minimumWageController.dispose();
    _maximumDistanceController.dispose();
    _preferredLocalsFocus.dispose();
    _minimumWageFocus.dispose();
    _maximumDistanceFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
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
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
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
              widget.isFirstTime ? 'Set Job Preferences' : 'Update Job Preferences',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
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
          'Classifications',
          style: AppTheme.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Select your preferred job classifications',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingXs,
          runSpacing: AppTheme.spacingXs,
          children: _availableClassifications.map((classification) {
            final isSelected = _preferences.classifications.contains(classification);
            return JJChip(
              label: classification,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _preferences = _preferences.copyWith(
                      classifications: _preferences.classifications.where((type) => type != classification).toList(),
                    );
                  } else {
                    _preferences = _preferences.copyWith(
                      classifications: [..._preferences.classifications, classification],
                    );
                  }
                });
              },
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
          'Select the construction types you are interested in',
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
            return JJChip(
              label: constructionType,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _preferences = _preferences.copyWith(
                      constructionTypes: _preferences.constructionTypes.where((type) => type != constructionType).toList(),
                    );
                  } else {
                    _preferences = _preferences.copyWith(
                      constructionTypes: [..._preferences.constructionTypes, constructionType],
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreferredLocalsSection() {
    return JJTextField(
      label: 'Preferred Locals (Comma-separated)',
      controller: _preferredLocalsController,
      focusNode: _preferredLocalsFocus,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_minimumWageFocus),
      prefixIcon: Icons.location_on_outlined,
      hintText: 'e.g., 26, 103, 456',
      maxLines: 2,
      onChanged: (value) {
        _preferences = _preferences.copyWith(
          preferredLocals: value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).map((e) => int.tryParse(e) ?? 0).toList(),
        );
      },
    );
  }

  Widget _buildHoursPerWeekSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hours Per Week',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'How many hours are you willing to work per week?',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightGray),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            color: AppTheme.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _preferences.hoursPerWeek,
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
                  _preferences = _preferences.copyWith(hoursPerWeek: value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerDiemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Per Diem Requirements',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'What per diem amount are you looking for?',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightGray),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            color: AppTheme.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _preferences.perDiemRequirement,
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
                  _preferences = _preferences.copyWith(perDiemRequirement: value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimumWageSection() {
    return JJTextField(
      label: 'Minimum Wage (\$)',
      controller: _minimumWageController,
      focusNode: _minimumWageFocus,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_maximumDistanceFocus),
      prefixIcon: Icons.attach_money,
      hintText: 'e.g., 25.00',
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final wage = double.tryParse(value);
          if (wage == null || wage < 0) {
            return 'Please enter a valid wage';
          }
        }
        return null;
      },
      onChanged: (value) {
        final wage = value.isNotEmpty ? double.tryParse(value) : null;
        _preferences = _preferences.copyWith(minWage: wage);
      },
    );
  }

  Widget _buildMaximumDistanceSection() {
    return JJTextField(
      label: 'Maximum Distance (miles)',
      controller: _maximumDistanceController,
      focusNode: _maximumDistanceFocus,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
      prefixIcon: Icons.directions_car_outlined,
      hintText: 'e.g., 50',
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
      onChanged: (value) {
        final distance = value.isNotEmpty ? int.tryParse(value) : null;
        _preferences = _preferences.copyWith(maxDistance: distance);
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.radiusLg),
        ),
        border: Border(
          top: BorderSide(color: AppTheme.borderLight, width: AppTheme.borderWidthThin),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          JJButton(
            text: 'Cancel',
            variant: JJButtonVariant.secondary,
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
            size: JJButtonSize.medium,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          JJButton(
            text: 'Save Preferences',
            icon: Icons.save_outlined,
            onPressed: _isLoading ? null : _savePreferences,
            isLoading: _isLoading,
            size: JJButtonSize.medium,
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
      final userPreferencesNotifier = ref.read(userPreferencesProvider) as dynamic;
      if (widget.initialPreferences == null) {
        await userPreferencesNotifier.savePreferences(widget.userId, _preferences);
      } else {
        await userPreferencesNotifier.updatePreferences(widget.userId, _preferences);
      }

      if (!mounted) return;

      JJSnackBar.showSuccess(
        context: context,
        message: 'Job preferences saved successfully!',
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      JJSnackBar.showError(
        context: context,
        message: 'Failed to save job preferences: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
