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
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;

class CreateCrewScreen extends ConsumerStatefulWidget {
  const CreateCrewScreen({super.key});

  @override
  CreateCrewScreenState createState() => CreateCrewScreenState();
}

class CreateCrewScreenState extends ConsumerState<CreateCrewScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _crewNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedJobType = 'Inside Wireman';
  bool _autoShareEnabled = false;

  // Animation controllers for enhanced button
  late AnimationController _buttonAnimationController;
  late AnimationController _glowAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Main button scale animation
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Glow pulse animation
    _glowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));

    _sparkleAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _crewNameController.dispose();
    _descriptionController.dispose();
    _buttonAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  Future<void> _createCrew() async {
    if (_formKey.currentState!.validate()) {
      // Button press animation
      _buttonAnimationController.forward().then((_) {
        _buttonAnimationController.reverse();
      });
      
      try {
        final crewService = ref.read(crewServiceProvider);
        final currentUser = ref.read(auth_providers.currentUserProvider);

        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Debug logging for authentication troubleshooting
        print('🔍 DEBUG - Creating crew with user:');
        print('   User UID: ${currentUser.uid}');
        print('   User email: ${currentUser.email}');
        print('   Is anonymous: ${currentUser.isAnonymous}');
        print('   Email verified: ${currentUser.emailVerified}');

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

        print('✅ DEBUG - Crew created successfully');

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

  Widget _buildEnhancedCreateButton() {
    final isEnabled = ref.watch(auth_providers.currentUserProvider) != null;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_buttonAnimationController, _glowAnimationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: isEnabled ? [
                // Primary glow effect
                BoxShadow(
                  color: AppTheme.accentCopper.withValues(alpha: _glowAnimation.value * 0.6),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                  offset: const Offset(0, 4),
                ),
                // Secondary copper glow
                BoxShadow(
                  color: AppTheme.secondaryCopper.withValues(alpha: _glowAnimation.value * 0.3),
                  blurRadius: 30 * _glowAnimation.value,
                  spreadRadius: 4 * _glowAnimation.value,
                  offset: const Offset(0, 6),
                ),
                // Depth shadow
                const BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
              ] : [
                const BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: isEnabled 
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryNavy,
                          AppTheme.secondaryNavy,
                          AppTheme.primaryNavy.withValues(alpha: 0.9),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade500],
                      ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: isEnabled 
                      ? AppTheme.accentCopper.withValues(alpha: 0.8)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Animated sparkle effect
                  if (isEnabled)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd - 2),
                        child: Transform.translate(
                          offset: _sparkleAnimation.value * 50,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  AppTheme.accentCopper.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Button content
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isEnabled ? _createCrew : null,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingLg,
                          vertical: AppTheme.spacingMd + 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.electrical_services,
                              color: AppTheme.white,
                              size: AppTheme.iconMd,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                              'Create Crew',
                              style: AppTheme.buttonLarge.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.accentCopper,
                              size: AppTheme.iconSm,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                      DropdownMenuItem(value: 'Journeyman Electrician', child: Text('Journeyman Electrician')),
                      DropdownMenuItem(value: 'Inside Wireman', child: Text('Inside Wireman')),
                      DropdownMenuItem(value: 'Journeyman Wireman', child: Text('Journeyman Wireman')),
                      DropdownMenuItem(value: 'Operator', child: Text('Operator')),
                      DropdownMenuItem(value: 'Tree Trimmer', child: Text('Tree Trimmer')),
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.accentCopper,
                        width: AppTheme.borderWidthCopper,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      color: AppTheme.white,
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Auto-share matching jobs',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      value: _autoShareEnabled,
                      onChanged: (value) {
                        setState(() {
                          _autoShareEnabled = value;
                        });
                      },
                      activeColor: AppTheme.accentCopper,
                      activeTrackColor: AppTheme.accentCopper.withValues(alpha: 0.3),
                      inactiveThumbColor: AppTheme.mediumGray,
                      inactiveTrackColor: AppTheme.lightGray,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Enhanced Create Crew Button
                  _buildEnhancedCreateButton(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}