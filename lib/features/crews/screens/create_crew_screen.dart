import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../navigation/app_router.dart';
import '../../../electrical_components/jj_electrical_toast.dart';

import '../models/crew_preferences.dart';
import '../providers/crews_riverpod_provider.dart';
import '../widgets/crew_preferences_dialog.dart';
import '../services/crew_service.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart';

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
  int _minHourlyRate = 25;
  bool _autoShareEnabled = false;

  @override
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

        // Create crew with initial preferences
        final crewId = '${_crewNameController.text}-${DateTime.now().millisecondsSinceEpoch}';
        
        if (mounted) {
          // Show CrewPreferencesDialog after successful crew creation
          final updatedPreferences = await showDialog<CrewPreferences>(
            context: context,
            builder: (context) => CrewPreferencesDialog(
              initialPreferences: CrewPreferences(
                jobTypes: [_selectedJobType],
                minHourlyRate: _minHourlyRate.toDouble(),
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
            
            // Navigate to Tailboard screen
            context.go('${AppRouter.crews}/$crewId');
          } else if (mounted) {
            // User cancelled preferences, navigate to Tailboard with initial preferences
            context.go('${AppRouter.crews}/$crewId');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _crewNameController,
                  decoration: const InputDecoration(
                    labelText: 'Crew Name',
                    hintText: 'Enter crew name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Crew name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedJobType,
                  items: const [
                    DropdownMenuItem(value: 'Inside Wireman', child: Text('Inside Wireman')),
                    DropdownMenuItem(value: 'Journeyman Lineman', child: Text('Journeyman Lineman')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedJobType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief crew description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Minimum Hourly Rate: \$$_minHourlyRate'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => setState(() => _minHourlyRate = max(15, _minHourlyRate - 5)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _minHourlyRate = min(100, _minHourlyRate + 5)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Auto-share matching jobs'),
                  value: _autoShareEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoShareEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: ref.watch(currentUserProvider) != null ? _createCrew : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Create Crew'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ref.watch(currentUserProvider) != null ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
