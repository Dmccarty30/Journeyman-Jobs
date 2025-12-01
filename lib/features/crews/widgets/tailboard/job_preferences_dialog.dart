import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tailboard_theme.dart';
import '../../models/crew_preferences.dart';
import '../../providers/crews_riverpod_provider.dart';


class JobPreferencesDialog extends ConsumerStatefulWidget {
  final String crewId;
  final CrewPreferences initialPreferences;

  const JobPreferencesDialog({
    super.key,
    required this.crewId,
    required this.initialPreferences,
  });

  @override
  ConsumerState<JobPreferencesDialog> createState() => _JobPreferencesDialogState();
}

class _JobPreferencesDialogState extends ConsumerState<JobPreferencesDialog> {
  late List<String> _selectedJobTypes;
  late double? _minHourlyRate;
  late int? _maxDistanceMiles;
  late List<String> _selectedSkills;
  late bool _autoShareEnabled;
  late int _matchThreshold;
  
  final _hourlyRateController = TextEditingController();
  final _maxDistanceController = TextEditingController();

  // Available job types
  static const List<String> availableJobTypes = [
    'Commercial',
    'Industrial',
    'Residential',
    'Institutional',
    'Infrastructure',
    'Renewable Energy',
    'Data Centers',
    'Transportation',
  ];

  // Available skills
  static const List<String> availableSkills = [
    'Conduit Bending',
    'Blueprint Reading',
    'Wire Pulling',
    'Panel Installation',
    'Troubleshooting',
    'PLC Programming',
    'Low Voltage',
    'High Voltage',
    'Fire Alarm',
    'Security Systems',
  ];

  @override
  void initState() {
    super.initState();
    _selectedJobTypes = List.from(widget.initialPreferences.jobTypes);
    _minHourlyRate = widget.initialPreferences.minHourlyRate;
    _maxDistanceMiles = widget.initialPreferences.maxDistanceMiles;
    _selectedSkills = List.from(widget.initialPreferences.requiredSkills);
    _autoShareEnabled = widget.initialPreferences.autoShareEnabled;
    _matchThreshold = widget.initialPreferences.matchThreshold;
    
    if (_minHourlyRate != null) {
      _hourlyRateController.text = _minHourlyRate!.toStringAsFixed(2);
    }
    if (_maxDistanceMiles != null) {
      _maxDistanceController.text = _maxDistanceMiles.toString();
    }
  }

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _maxDistanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: TailboardTheme.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        padding: const EdgeInsets.all(TailboardTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Job Preferences',
                  style: TailboardTheme.headingMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TailboardTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: TailboardTheme.spacingM),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Job Types',
                      style: TailboardTheme.headingSmall,
                    ),
                    const SizedBox(height: TailboardTheme.spacingS),
                    Wrap(
                      spacing: TailboardTheme.spacingS,
                      runSpacing: TailboardTheme.spacingS,
                      children: availableJobTypes.map((type) {
                        final isSelected = _selectedJobTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedJobTypes.add(type);
                              } else {
                                _selectedJobTypes.remove(type);
                              }
                            });
                          },
                          backgroundColor: TailboardTheme.backgroundCard,
                          selectedColor: TailboardTheme.copper.withValues(alpha: 0.2),
                          checkmarkColor: TailboardTheme.copper,
                          labelStyle: TailboardTheme.bodySmall.copyWith(
                            color: isSelected ? TailboardTheme.copper : TailboardTheme.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? TailboardTheme.copper : TailboardTheme.border,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: TailboardTheme.spacingL),
                    Text(
                      'Minimum Hourly Rate',
                      style: TailboardTheme.headingSmall,
                    ),
                    const SizedBox(height: TailboardTheme.spacingS),
                    TextField(
                      controller: _hourlyRateController,
                      keyboardType: TextInputType.number,
                      decoration: TailboardTheme.inputDecoration(
                        hintText: 'e.g., 45.00',
                        prefixIcon: const Icon(Icons.attach_money, color: TailboardTheme.copper),
                      ),
                      style: TailboardTheme.bodyMedium,
                      onChanged: (value) {
                        _minHourlyRate = double.tryParse(value);
                      },
                    ),
                    const SizedBox(height: TailboardTheme.spacingL),
                    Text(
                      'Maximum Distance (miles)',
                      style: TailboardTheme.headingSmall,
                    ),
                    const SizedBox(height: TailboardTheme.spacingS),
                    TextField(
                      controller: _maxDistanceController,
                      keyboardType: TextInputType.number,
                      decoration: TailboardTheme.inputDecoration(
                        hintText: 'e.g., 50',
                        prefixIcon: const Icon(Icons.location_on, color: TailboardTheme.copper),
                      ),
                      style: TailboardTheme.bodyMedium,
                      onChanged: (value) {
                        _maxDistanceMiles = int.tryParse(value);
                      },
                    ),
                    const SizedBox(height: TailboardTheme.spacingL),
                    Text(
                      'Required Skills',
                      style: TailboardTheme.headingSmall,
                    ),
                    const SizedBox(height: TailboardTheme.spacingS),
                    Wrap(
                      spacing: TailboardTheme.spacingS,
                      runSpacing: TailboardTheme.spacingS,
                      children: availableSkills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSkills.add(skill);
                              } else {
                                _selectedSkills.remove(skill);
                              }
                            });
                          },
                          backgroundColor: TailboardTheme.backgroundCard,
                          selectedColor: TailboardTheme.copper.withValues(alpha: 0.2),
                          checkmarkColor: TailboardTheme.copper,
                          labelStyle: TailboardTheme.bodySmall.copyWith(
                            color: isSelected ? TailboardTheme.copper : TailboardTheme.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? TailboardTheme.copper : TailboardTheme.border,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: TailboardTheme.spacingL),
                    SwitchListTile(
                      title: Text(
                        'Auto-Share Matching Jobs',
                        style: TailboardTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        'Automatically share jobs that match crew preferences',
                        style: TailboardTheme.bodySmall,
                      ),
                      value: _autoShareEnabled,
                      onChanged: (value) {
                        setState(() {
                          _autoShareEnabled = value;
                        });
                      },
                      activeThumbColor: TailboardTheme.copper,
                      tileColor: TailboardTheme.backgroundCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
                      ),
                    ),
                    const SizedBox(height: TailboardTheme.spacingL),
                    Text(
                      'Match Threshold: $_matchThreshold%',
                      style: TailboardTheme.headingSmall,
                    ),
                    Slider(
                      value: _matchThreshold.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '$_matchThreshold%',
                      activeColor: TailboardTheme.copper,
                      inactiveColor: TailboardTheme.border,
                      onChanged: (value) {
                        setState(() {
                          _matchThreshold = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TailboardTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TailboardTheme.secondaryButton,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: TailboardTheme.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savePreferences,
                    style: TailboardTheme.primaryButton,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    try {
      final crewService = ref.read(crewServiceProvider);
      final newPreferences = CrewPreferences(
        jobTypes: _selectedJobTypes,
        minHourlyRate: _minHourlyRate,
        maxDistanceMiles: _maxDistanceMiles,
        requiredSkills: _selectedSkills,
        autoShareEnabled: _autoShareEnabled,
        matchThreshold: _matchThreshold,
      );

      await crewService.updateCrew(
        crewId: widget.crewId,
        preferences: newPreferences,
      );
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Job preferences saved successfully'),
            backgroundColor: TailboardTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: TailboardTheme.error,
          ),
        );
      }
    }
  }
}
