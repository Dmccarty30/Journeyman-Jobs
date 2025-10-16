import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../navigation/app_router.dart';
import '../../../electrical_components/jj_electrical_toast.dart';
import '../../../electrical_components/circuit_board_background.dart';


import '../models/crew_preferences.dart';
import '../providers/crews_riverpod_provider.dart';
import '../widgets/crew_preferences_dialog.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart';
import '../../../domain/enums/permission.dart';

class CreateCrewScreen extends ConsumerStatefulWidget {
  const CreateCrewScreen({super.key});

  @override
  CreateCrewScreenState createState() => CreateCrewScreenState();
}

class CreateCrewScreenState extends ConsumerState<CreateCrewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _crewNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedJobType = 'Inside Wireman';
  bool _autoShareEnabled = false;

  @override
  void dispose() {
    _crewNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createCrew() async {
    if (_formKey.currentState!.validate()) {
      try {
        final crewService = ref.read(crewServiceProvider);
        final currentUser = ref.read(currentUserProvider);

        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Create crew with current user as foreman
        await crewService.createCrew(
          name: _crewNameController.text,
          foremanId: currentUser.uid, // Use current user's UID as foremanId
          preferences: CrewPreferences(
            jobTypes: [_selectedJobType],
            constructionTypes: ['Commercial', 'Industrial'], // Default construction types
            autoShareEnabled: _autoShareEnabled,
          ),
        );

        // After successful crew creation, show preferences dialog
        if (mounted) {
          final crew = await crewService.getUserCrews(currentUser.uid);
          if (crew.isNotEmpty) {
            final crewId = crew.first.id;
            final updatedPreferences = await showDialog<CrewPreferences>(
              context: context,
              builder: (context) => CrewPreferencesDialog(
                initialPreferences: CrewPreferences(
                  jobTypes: [_selectedJobType],
                  constructionTypes: ['Commercial', 'Industrial'], // Default construction types
                  autoShareEnabled: _autoShareEnabled,
                ),
                crewId: crewId,
                crewService: crewService,
                isNewCrew: true, // Indicate this is for a new crew
              ),
            );

            if (updatedPreferences != null && mounted) {
              // Update crew with final preferences
              await crewService.updateCrew(
                crewId: crewId,
                preferences: updatedPreferences,
              );
            }

            // Navigate to Tailboard screen
            if (mounted) {
              context.go('${AppRouter.crews}/$crewId');
            }
          } else {
            // Fallback if crew creation didn't return the crew
            throw Exception('Crew creation failed - crew not found');
          }
        }

      } catch (e) {
        if (mounted) {
          JJElectricalToast.showError(context: context, message: 'Failed to create crew: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Crew'),
        elevation: 0,
        backgroundColor: AppTheme.white,
      ),
      body: ElectricalCircuitBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _crewNameController,
                    decoration: InputDecoration(
                      labelText: 'Crew Name',
                      hintText: 'Enter crew name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
                      ),
                      filled: true,
                      fillColor: AppTheme.white,
                      labelStyle: TextStyle(color: AppTheme.textSecondary),
                      hintStyle: TextStyle(color: AppTheme.mediumGray),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Crew name is required';
                      }
                      return null;
                    },
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedJobType,
                    items: const [
                      DropdownMenuItem(value: 'Journeyman Lineman', child: Text('Journeyman Lineman')),
                      DropdownMenuItem(value: 'Inside Wireman', child: Text('Inside Wireman')),
                      DropdownMenuItem(value: 'Operator', child: Text('Operator')),
                      DropdownMenuItem(value: 'Journeyman Wireman', child: Text('Journeyman Wireman')),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedJobType = newValue ?? 'Inside Wireman';
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Primary Classification',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
                      ),
                      filled: true,
                      fillColor: AppTheme.white,
                      labelStyle: TextStyle(color: AppTheme.textSecondary),
                    ),
                    style: TextStyle(color: AppTheme.textPrimary),
                    dropdownColor: AppTheme.white,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief crew description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
                      ),
                      filled: true,
                      fillColor: AppTheme.white,
                      labelStyle: TextStyle(color: AppTheme.textSecondary),
                      hintStyle: TextStyle(color: AppTheme.mediumGray),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                    maxLines: 3,
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: Text(
                      'Auto-share matching jobs',
                      style: TextStyle(color: AppTheme.textOnDark),
                    ),
                    value: _autoShareEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoShareEnabled = value;
                      });
                    },
                    activeColor: AppTheme.accentCopper,
                    tileColor: AppTheme.secondaryNavy,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: ref.watch(currentUserProvider) != null ? _createCrew : null,
                    icon: const Icon(Icons.check, color: AppTheme.white),
                    label: Text(
                      'Create Crew',
                      style: TextStyle(color: AppTheme.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ref.watch(currentUserProvider) != null ? AppTheme.primaryNavy : Colors.grey,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      elevation: 4.0, // Use a constant value instead of AppTheme.elevationMd
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
