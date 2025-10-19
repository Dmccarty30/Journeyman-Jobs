import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/core_providers.dart' hide legacyCurrentUserProvider;

/// A dropdown widget for selecting a crew from the user's available crews.
/// 
/// This widget:
/// - Displays a list of crews the user belongs to
/// - Auto-selects the first crew if none is selected
/// - Handles loading and error states gracefully
/// - Uses ref.listen for side effects to avoid rebuild loops
class CrewSelectionDropdown extends ConsumerStatefulWidget {
  final bool isExpanded;
  
  const CrewSelectionDropdown({
    super.key,
    this.isExpanded = false,
  });

  @override
  ConsumerState<CrewSelectionDropdown> createState() => _CrewSelectionDropdownState();
}

class _CrewSelectionDropdownState extends ConsumerState<CrewSelectionDropdown> {
  /// Guards against showing the same error dialog multiple times
  String? _lastErrorKey;
  
  /// Guards against auto-selecting a crew multiple times
  bool _autoSelected = false;
  
  @override
  void initState() {
    super.initState();
    
    // Listen for error states and show dialog once per unique error
    // This prevents multiple dialogs on rebuild
    ref.listenManual(
      userCrewsStreamProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            // Create unique key for this error to prevent duplicate dialogs
            final errorKey = '${error.toString()}_${stackTrace.hashCode}';
            if (errorKey != _lastErrorKey && mounted) {
              _lastErrorKey = errorKey;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Loading Crews'),
                    content: Text('Failed to load crews: $error'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ref.invalidate(userCrewsStreamProvider);
                          // Reset error key to allow showing new errors
                          setState(() {
                            _lastErrorKey = null;
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              });
            }
          },
        );
      },
    );
    
    // Listen for data availability and auto-select first crew if needed
    // This runs once when data becomes available, avoiding rebuild loops
    ref.listenManual(
      userCrewsStreamProvider,
      (previous, next) {
        next.whenOrNull(
          data: (crews) {
            final selectedCrew = ref.read(selectedCrewProvider);
            // Only auto-select once when crews are available and nothing is selected
            if (crews.isNotEmpty && selectedCrew == null && !_autoSelected) {
              _autoSelected = true;
              final firstCrew = crews.first;
              // Auto-select first crew when data becomes available
              ref.read(selectedCrewProvider.notifier).setCrew(firstCrew);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch only what's needed for rendering - crews stream and selected crew state
    final crewsAsync = ref.watch(userCrewsStreamProvider);
    final selectedCrew = ref.watch(selectedCrewProvider);

    return crewsAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stackTrace) => const SizedBox(
        height: 56,
        child: Center(
          child: Text('Error loading crews'),
        ),
      ),
      data: (crews) {
        return DropdownButtonFormField<String>(
          key: ValueKey('crew_dropdown_${selectedCrew?.id}'),
          decoration: InputDecoration(
            labelText: selectedCrew == null ? 'Select Crew' : 'Selected Crew',
            border: const OutlineInputBorder(),
            hintText: crews.isEmpty ? 'No crews available' : 'Select a crew',
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          initialValue: selectedCrew?.id,
          isExpanded: widget.isExpanded,
          items: crews.map((Crew crew) {
            return DropdownMenuItem<String>(
              value: crew.id,
              child: Text(
                crew.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: crews.isEmpty ? null : (String? value) {
            if (value != null) {
              final crew = crews.firstWhere((c) => c.id == value);
              // Update selected crew state
              ref.read(selectedCrewProvider.notifier).setCrew(crew);
              
              // Close dropdown after selection
              if (context.mounted) {
                FocusScope.of(context).unfocus();
              }
            }
          },
        );
      },
    );
  }
}
