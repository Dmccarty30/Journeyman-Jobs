import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../electrical_components/circuit_board_background.dart';
import '../../electrical_components/jj_electrical_notifications.dart';
import '../../electrical_components/jj_electrical_interactive_widgets.dart';
import '../../electrical_components/jj_electrical_page_transitions.dart';
import '../../electrical_components/electrical_rotation_meter.dart';
import '../../design_system/app_theme.dart';
import '../../navigation/app_router.dart';
import '../tools/electrical_components_showcase_screen.dart';

/// Quick demo screen showcasing the electrical theme enhancements
/// This provides an easy way to see the new electrical components in action
class ElectricalDemoScreen extends StatefulWidget {
  const ElectricalDemoScreen({super.key});

  @override
  State<ElectricalDemoScreen> createState() => _ElectricalDemoScreenState();
}

class _ElectricalDemoScreenState extends State<ElectricalDemoScreen> {
  final _textController = TextEditingController();
  String? _selectedComponent;
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚡ Electrical Theme Demo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              Navigator.of(context).push(
                JJElectricalPageTransitions.lightningTransition(
                  child: const ElectricalComponentsShowcaseScreen(),
                  settings: const RouteSettings(name: '/showcase'),
                ),
              );
            },
            tooltip: 'Full Showcase',
          ),
        ],
      ),
      
      body: Stack(
        children: [
          // Animated circuit board background
          const Positioned.fill(
            child: ElectricalCircuitBackground(
              opacity: 0.08,
              animationSpeed: 2.0,
              componentDensity: ComponentDensity.high,
              enableCurrentFlow: true,
              enableInteractiveComponents: true,
            ),
          ),
          
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _buildCardDecoration(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentCopper,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.electrical_services,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                          .animate()
                          .scale(
                            delay: const Duration(milliseconds: 200),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Electrical Theme Enhancements',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 500),
                      )
                      .slideY(
                        begin: -0.2,
                        end: 0,
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 500),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Experience the new electrical-themed components with animated backgrounds, responsive buttons, and lightning effects!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 500),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 50),
                  duration: const Duration(milliseconds: 600),
                )
                .slideY(
                  begin: 0.1,
                  end: 0,
                  delay: const Duration(milliseconds: 50),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                ),
                
                const SizedBox(height: 20),
                
                // Interactive demo section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _buildCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interactive Elements:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 500),
                      ),
                      const SizedBox(height: 16),
                      
                      // Electrical buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          JJElectricalButton(
                            onPressed: () {
                              JJElectricalNotifications.showElectricalToast(
                                context: context,
                                message: 'Success! ⚡ Power ON',
                                type: ElectricalNotificationType.success,
                                showLightning: true,
                              );
                            },
                            sparkColor: Colors.green,
                            child: const Text('Power ON'),
                          ),
                          JJElectricalButton(
                            onPressed: () {
                              JJElectricalNotifications.showElectricalToast(
                                context: context,
                                message: 'Warning! ⚠️ High Voltage',
                                type: ElectricalNotificationType.warning,
                                showLightning: true,
                              );
                            },
                            sparkColor: Colors.amber,
                            glowColor: Colors.amber,
                            child: const Text('Warning'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Text field with current flow
                      JJElectricalTextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Electrical Input Field',
                          hintText: 'Watch the current flow when focused...',
                          helperText: 'Tap to see animated current flow',
                        ),
                        enableCurrentFlow: true,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Dropdown with spark effects
                      JJElectricalDropdown<String>(
                        value: _selectedComponent,
                        hint: const Text('Select Component'),
                        enableSparks: true,
                        items: const [
                          DropdownMenuItem(value: 'transformer', child: Text('⚡ Transformer')),
                          DropdownMenuItem(value: 'breaker', child: Text('🔌 Circuit Breaker')),
                          DropdownMenuItem(value: 'meter', child: Text('📊 Electrical Meter')),
                          DropdownMenuItem(value: 'capacitor', child: Text('🔋 Capacitor')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedComponent = value;
                          });
                          JJElectricalNotifications.showElectricalSnackBar(
                            context: context,
                            message: 'Selected: ${value?.toUpperCase()} ⚡',
                            type: ElectricalNotificationType.info,
                            actionLabel: 'Cool!',
                          );
                        },
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 350),
                  duration: const Duration(milliseconds: 600),
                )
                .slideY(
                  begin: 0.1,
                  end: 0,
                  delay: const Duration(milliseconds: 350),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                ),

                const SizedBox(height: 20),
                
                // Loading animation showcase
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _buildCardDecoration(),
                  child: Column(
                    children: [
                      const Text(
                        'Three-Phase Rotation Meter:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 600),
                        duration: const Duration(milliseconds: 500),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          JJElectricalNotifications.electricalTooltip(
                            message: 'This meter shows electrical system loading',
                            type: ElectricalNotificationType.info,
                            child: const ElectricalRotationMeter(
                              size: 100,
                              label: 'System Load',
                              duration: Duration(seconds: 3),
                            ),
                          )
                          .animate()
                          .scale(
                            delay: const Duration(milliseconds: 700),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 550),
                  duration: const Duration(milliseconds: 600),
                )
                .slideY(
                  begin: 0.1,
                  end: 0,
                  delay: const Duration(milliseconds: 550),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                ),
                
                const SizedBox(height: 20),
                
                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _buildCardDecoration(),
                  child: Column(
                    children: [
                      const Text(
                        'Explore More:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 800),
                        duration: const Duration(milliseconds: 500),
                      ),
                      const SizedBox(height: 16),
                      
                      JJElectricalButton(
                        onPressed: () {
                          context.push(AppRouter.electricalShowcase);
                        },
                        sparkColor: const Color(0xFF00D4FF),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fullscreen, size: 20),
                            SizedBox(width: 8),
                            Text('View Full Showcase'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          JJElectricalButton(
                            onPressed: () {
                              JJElectricalNotifications.showElectricalToast(
                                context: context,
                                message: 'Feature coming in next update! 🚀',
                                type: ElectricalNotificationType.info,
                              );
                            },
                            child: const Text('Page Transitions'),
                          ),
                          JJElectricalButton(
                            onPressed: () {
                              JJElectricalNotifications.showElectricalToast(
                                context: context,
                                message: 'Background patterns are active! ✨',
                                type: ElectricalNotificationType.success,
                              );
                            },
                            child: const Text('Backgrounds'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),
        ],
      ),
      
      // Floating action button with electrical theme
      floatingActionButton: JJElectricalNotifications.electricalTooltip(
        message: 'Test all notifications',
        type: ElectricalNotificationType.info,
        child: FloatingActionButton(
          onPressed: () {
            _showNotificationDemo();
          },
          backgroundColor: AppTheme.accentCopper,
          child: const Icon(
            Icons.flash_on,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showNotificationDemo() {
    // Show multiple notifications in sequence
    JJElectricalNotifications.showElectricalToast(
      context: context,
      message: 'System Check: All circuits operational ✅',
      type: ElectricalNotificationType.success,
      showLightning: true,
    );
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Voltage fluctuation detected ⚠️',
        type: ElectricalNotificationType.warning,
        showLightning: true,
      );
    });
    
    Future.delayed(const Duration(milliseconds: 3000), () {
      JJElectricalNotifications.showElectricalSnackBar(
        context: context,
        message: '⚡ Electrical theme demo complete! All systems ready.',
        type: ElectricalNotificationType.info,
        actionLabel: 'Awesome!',
      );
    });
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      border: Border.all(
        color: AppTheme.accentCopper,
        width: AppTheme.borderWidthCopper,
      ),
      boxShadow: [
        AppTheme.shadowSm,
        AppTheme.shadowElectricalInfo,
      ],
    );
  }
}

