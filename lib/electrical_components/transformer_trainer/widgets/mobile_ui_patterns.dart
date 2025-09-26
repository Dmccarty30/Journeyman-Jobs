import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design_system/app_theme.dart';
import '../models/transformer_models_export.dart';
import '../utils/accessibility_manager.dart';

/// Mobile-specific bottom sheet for transformer controls
class MobileTransformerControlsSheet extends StatelessWidget {
  
  const MobileTransformerControlsSheet({
    required this.currentBankType, required this.currentMode, required this.currentDifficulty, required this.onBankTypeChanged, required this.onModeChanged, required this.onDifficultyChanged, super.key,
    this.onResetConnections,
    this.onShowHelp,
  });
  final TransformerBankType currentBankType;
  final TrainingMode currentMode;
  final DifficultyLevel currentDifficulty;
  final Function(TransformerBankType) onBankTypeChanged;
  final Function(TrainingMode) onModeChanged;
  final Function(DifficultyLevel) onDifficultyChanged;
  final VoidCallback? onResetConnections;
  final VoidCallback? onShowHelp;
  
  @override
  Widget build(BuildContext context) => AccessibilityManager.buildAccessibleControlPanel(
      title: 'Transformer Training Controls',
      description: 'Configure training settings and options',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.mediumGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Training Settings',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  if (onShowHelp != null)
                    IconButton(
                      onPressed: onShowHelp,
                      icon: const Icon(Icons.help_outline),
                      tooltip: 'Show help',
                    ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildModeSelector(context),
                    const SizedBox(height: 24),
                    _buildBankTypeSelector(context),
                    const SizedBox(height: 24),
                    _buildDifficultySelector(context),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildModeSelector(BuildContext context) => AccessibilityManager.buildAccessibleModeToggle(
      currentMode: currentMode,
      onModeChanged: onModeChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Training Mode',
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightGray),
            ),
            child: Column(
              children: TrainingMode.values.map((TrainingMode mode) {
                final bool isSelected = mode == currentMode;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onModeChanged(mode);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.primaryNavy.withValues(alpha: 0.1)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            mode == TrainingMode.guided 
                                ? Icons.school 
                                : Icons.quiz,
                            color: isSelected 
                                ? AppTheme.primaryNavy 
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  mode == TrainingMode.guided 
                                      ? 'Guided Learning' 
                                      : 'Quiz Mode',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: isSelected 
                                        ? AppTheme.primaryNavy 
                                        : AppTheme.textPrimary,
                                    fontWeight: isSelected 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  mode == TrainingMode.guided 
                                      ? 'Step-by-step instructions'
                                      : 'Test your knowledge',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryNavy,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  
  Widget _buildBankTypeSelector(BuildContext context) => AccessibilityManager.buildAccessibleBankTypeSelector(
      currentBankType: currentBankType,
      onBankTypeChanged: onBankTypeChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Transformer Configuration',
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TransformerBankType.values.map((TransformerBankType type) {
              final bool isSelected = type == currentBankType;
              return FilterChip(
                label: Text(_getBankTypeDisplayName(type)),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    HapticFeedback.selectionClick();
                    onBankTypeChanged(type);
                  }
                },
                selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.accentCopper,
                side: BorderSide(
                  color: isSelected 
                      ? AppTheme.accentCopper 
                      : AppTheme.mediumGray,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  
  Widget _buildDifficultySelector(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Difficulty Level',
          style: AppTheme.labelLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: DifficultyLevel.values.map((DifficultyLevel level) {
            final bool isSelected = level == currentDifficulty;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onDifficultyChanged(level);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.accentCopper.withValues(alpha: 0.2)
                            : AppTheme.lightGray,
                        border: Border.all(
                          color: isSelected 
                              ? AppTheme.accentCopper 
                              : AppTheme.mediumGray,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDifficultyDisplayName(level),
                        textAlign: TextAlign.center,
                        style: AppTheme.labelMedium.copyWith(
                          color: isSelected 
                              ? AppTheme.accentCopper 
                              : AppTheme.textSecondary,
                          fontWeight: isSelected 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  
  Widget _buildActionButtons(BuildContext context) => Column(
      children: <Widget>[
        if (onResetConnections != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onResetConnections!();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Connections'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  
  String _getBankTypeDisplayName(TransformerBankType type) {
    switch (type) {
      case TransformerBankType.wyeToWye:
        return 'Wye-Wye';
      case TransformerBankType.wyeToDelta:
        return 'Wye-Delta';
      case TransformerBankType.deltaToWye:
        return 'Delta-Wye';
      case TransformerBankType.deltaToDelta:
        return 'Delta-Delta';
      case TransformerBankType.openDelta:
        return 'Open-Delta';
    }
  }
  
  String _getDifficultyDisplayName(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }
}

/// Floating instruction card for mobile
class FloatingInstructionCard extends StatefulWidget {
  
  const FloatingInstructionCard({
    required this.instruction, super.key,
    this.isError = false,
    this.isSuccess = false,
    this.onDismiss,
    this.autoHideDuration,
  });
  final String instruction;
  final bool isError;
  final bool isSuccess;
  final VoidCallback? onDismiss;
  final Duration? autoHideDuration;
  
  @override
  State<FloatingInstructionCard> createState() => _FloatingInstructionCardState();
}

class _FloatingInstructionCardState extends State<FloatingInstructionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ),);
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);
    
    _animationController.forward();
    
    // Auto-hide after duration
    if (widget.autoHideDuration != null) {
      Future.delayed(widget.autoHideDuration!, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _dismiss() {
    _animationController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) => SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AccessibilityManager.buildAccessibleInstructions(
          text: widget.instruction,
          isError: widget.isError,
          isSuccess: widget.isSuccess,
        ),
      ),
    );
}

/// Mobile quick action button
class MobileQuickActionButton extends StatelessWidget {
  
  const MobileQuickActionButton({
    required this.icon, required this.label, required this.onPressed, super.key,
    this.backgroundColor,
    this.foregroundColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  
  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      icon: Icon(icon),
      label: Text(label),
      backgroundColor: backgroundColor ?? AppTheme.primaryNavy,
      foregroundColor: foregroundColor ?? AppTheme.white,
      elevation: 8,
    ).addAccessibilitySemantics(
      label: label,
      button: true,
      onTap: onPressed,
    );
}

/// Mobile magnification overlay
class MagnificationOverlay extends StatefulWidget {
  
  const MagnificationOverlay({
    required this.child, super.key,
    this.magnificationFactor = 2.0,
    this.enabled = true,
  });
  final Widget child;
  final double magnificationFactor;
  final bool enabled;
  
  @override
  State<MagnificationOverlay> createState() => _MagnificationOverlayState();
}

class _MagnificationOverlayState extends State<MagnificationOverlay> {
  Offset? _magnificationCenter;
  bool _showMagnification = false;
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        setState(() {
          _magnificationCenter = details.localPosition;
          _showMagnification = true;
        });
        HapticFeedback.mediumImpact();
      },
      onLongPressEnd: (_) {
        setState(() {
          _showMagnification = false;
        });
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        setState(() {
          _magnificationCenter = details.localPosition;
        });
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_showMagnification && _magnificationCenter != null)
            _buildMagnificationLens(),
        ],
      ),
    );
  }
  
  Widget _buildMagnificationLens() {
    const double lensSize = 120;
    final Offset center = _magnificationCenter!;
    
    return Positioned(
      left: (center.dx - lensSize / 2).clamp(0, double.infinity),
      top: (center.dy - lensSize / 2 - 60).clamp(0, double.infinity),
      child: Container(
        width: lensSize,
        height: lensSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryNavy, width: 3),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Transform.scale(
            scale: widget.magnificationFactor,
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile-specific tab bar for transformer modes
class MobileTransformerTabBar extends StatelessWidget {
  
  const MobileTransformerTabBar({
    required this.currentIndex, required this.onIndexChanged, required this.items, super.key,
  });
  final int currentIndex;
  final Function(int) onIndexChanged;
  final List<MobileTabItem> items;
  
  @override
  Widget build(BuildContext context) => Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: items.asMap().entries.map((MapEntry<int, MobileTabItem> entry) {
          final int index = entry.key;
          final MobileTabItem item = entry.value;
          final bool isSelected = index == currentIndex;
          
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onIndexChanged(index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        item.icon,
                        color: isSelected 
                            ? AppTheme.primaryNavy 
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTheme.labelSmall.copyWith(
                          color: isSelected 
                              ? AppTheme.primaryNavy 
                              : AppTheme.textSecondary,
                          fontWeight: isSelected 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
}

/// Mobile tab item data class
class MobileTabItem {
  
  const MobileTabItem({
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;
}