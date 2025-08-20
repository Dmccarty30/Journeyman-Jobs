import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import '../models/transformer_models_export.dart';

/// Accessibility manager for transformer trainer
class AccessibilityManager {
  static bool _isScreenReaderEnabled = false;
  static bool _isHighContrastEnabled = false;
  static bool _isLargeTextEnabled = false;
  static double _textScaleFactor = 1;
  // Track last announced text to avoid duplicate announcements
  static String _lastAnnouncement = '';
  
  /// Initialize accessibility features
  static void initialize(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    
    _isScreenReaderEnabled = mediaQuery.accessibleNavigation;
    _isHighContrastEnabled = mediaQuery.highContrast;
    _textScaleFactor = mediaQuery.textScaleFactor;
    _isLargeTextEnabled = _textScaleFactor > 1.3;
  }
  
  /// Get accessibility-enhanced connection point widget
  static Widget buildAccessibleConnectionPoint({
    required Widget child,
    required ConnectionPoint connectionPoint,
    required bool isSelected,
    required bool isConnected,
    required bool isCompatible,
    required VoidCallback onTap,
    String? customHint,
  }) => Semantics(
      label: _getConnectionPointLabel(connectionPoint),
      hint: customHint ?? _getConnectionPointHint(connectionPoint, isSelected, isConnected, isCompatible),
      value: _getConnectionPointValue(connectionPoint, isSelected, isConnected),
      button: true,
      enabled: true,
      focusable: true,
      selected: isSelected,
      onTap: onTap,
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
        if (!isConnected)
          const CustomSemanticsAction(label: 'Connect'): onTap,
        if (isConnected)
          const CustomSemanticsAction(label: 'Disconnect'): onTap,
      },
      child: _wrapWithAccessibilityContainer(
        child: child,
        connectionPoint: connectionPoint,
        isSelected: isSelected,
        isConnected: isConnected,
      ),
    );
  
  /// Wrap widget with accessibility-enhanced container
  static Widget _wrapWithAccessibilityContainer({
    required Widget child,
    required ConnectionPoint connectionPoint,
    required bool isSelected,
    required bool isConnected,
  }) => DecoratedBox(
      decoration: BoxDecoration(
        border: _isHighContrastEnabled
            ? Border.all(
                color: _getHighContrastBorderColor(isSelected, isConnected),
                width: isSelected ? 3.0 : 2.0,
              )
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  
  /// Get accessibility label for connection point
  static String _getConnectionPointLabel(ConnectionPoint connectionPoint) {
    final String typeDescription = _getConnectionTypeDescription(connectionPoint.type);
    final String inputOutput = connectionPoint.isInput ? 'input' : 'output';
    
    return '${connectionPoint.label} $typeDescription $inputOutput terminal';
  }
  
  /// Get accessibility hint for connection point
  static String _getConnectionPointHint(
    ConnectionPoint connectionPoint,
    bool isSelected,
    bool isConnected,
    bool isCompatible,
  ) {
    if (isConnected) {
      return 'Connected terminal. Double tap to disconnect.';
    }
    
    if (isSelected) {
      return 'Selected terminal. Choose another terminal to connect to.';
    }
    
    if (isCompatible) {
      return 'Compatible terminal. Double tap to connect.';
    }
    
    return 'Connection terminal. Double tap to select.';
  }
  
  /// Get accessibility value for connection point
  static String _getConnectionPointValue(
    ConnectionPoint connectionPoint,
    bool isSelected,
    bool isConnected,
  ) {
    final List<String> status = <String>[];
    
    if (isConnected) status.add('connected');
    if (isSelected) status.add('selected');
    
    return status.isEmpty ? 'available' : status.join(', ');
  }
  
  /// Get connection type description
  static String _getConnectionTypeDescription(ConnectionType type) {
    switch (type) {
      case ConnectionType.primary:
        return 'primary side';
      case ConnectionType.secondary:
        return 'secondary side';
      case ConnectionType.neutral:
        return 'neutral';
      case ConnectionType.ground:
        return 'ground';
    }
  }
  
  /// Get high contrast border color
  static Color _getHighContrastBorderColor(bool isSelected, bool isConnected) {
    if (isConnected) return Colors.green.shade800;
    if (isSelected) return Colors.blue.shade800;
    return Colors.grey.shade600;
  }
  
  /// Build accessible transformer diagram
  static Widget buildAccessibleTransformerDiagram({
    required Widget child,
    required TransformerBankType bankType,
    required List<WireConnection> connections,
    required int totalConnectionPoints,
  }) => Semantics(
      label: 'Transformer bank diagram',
      hint: _getTransformerDiagramHint(bankType, connections, totalConnectionPoints),
      child: ExcludeSemantics(
        excluding: !_isScreenReaderEnabled,
        child: child,
      ),
    );
  
  /// Get transformer diagram accessibility hint
  static String _getTransformerDiagramHint(
    TransformerBankType bankType,
    List<WireConnection> connections,
    int totalConnectionPoints,
  ) {
    final String bankTypeDescription = _getBankTypeDescription(bankType);
    final int connectionCount = connections.length;
    final int correctConnections = connections.where((WireConnection c) => c.isCorrect).length;
    
    return '$bankTypeDescription transformer bank. '
           '$connectionCount of $totalConnectionPoints connections made. '
           '$correctConnections correct connections.';
  }
  
  /// Get bank type description
  static String _getBankTypeDescription(TransformerBankType bankType) {
    switch (bankType) {
      case TransformerBankType.wyeToWye:
        return 'Wye to Wye';
      case TransformerBankType.deltaToDelta:
        return 'Delta to Delta';
      case TransformerBankType.wyeToDelta:
        return 'Wye to Delta';
      case TransformerBankType.deltaToWye:
        return 'Delta to Wye';
      case TransformerBankType.openDelta:
        return 'Open Delta';
    }
  }
  
  /// Build accessible control panel
  static Widget buildAccessibleControlPanel({
    required Widget child,
    required String title,
    String? description,
  }) => Semantics(
      header: true,
      label: title,
      hint: description,
      child: child,
    );
  
  /// Build accessible mode toggle
  static Widget buildAccessibleModeToggle({
    required Widget child,
    required TrainingMode currentMode,
    required Function(TrainingMode) onModeChanged,
  }) => Semantics(
      label: 'Training mode selector',
      hint: 'Current mode: ${_getModeDescription(currentMode)}. Swipe left or right to change mode.',
      value: _getModeDescription(currentMode),
      child: child,
    );
  
  /// Get mode description
  static String _getModeDescription(TrainingMode mode) {
    switch (mode) {
      case TrainingMode.guided:
        return 'Guided learning mode with step-by-step instructions';
      case TrainingMode.quiz:
        return 'Quiz mode for testing knowledge';
    }
  }
  
  /// Build accessible bank type selector
  static Widget buildAccessibleBankTypeSelector({
    required Widget child,
    required TransformerBankType currentBankType,
    required Function(TransformerBankType) onBankTypeChanged,
  }) => Semantics(
      label: 'Transformer bank type selector',
      hint: 'Current type: ${_getBankTypeDescription(currentBankType)}. Use navigation gestures to select different bank types.',
      value: _getBankTypeDescription(currentBankType),
      child: child,
    );
  
  /// Build accessible instruction text
  static Widget buildAccessibleInstructions({
    required String text,
    bool isError = false,
    bool isSuccess = false,
  }) {
    // Semantics doesn't have an `announcement` named parameter.
    // To trigger a screen reader announcement, announce after the widget
    // is built using SemanticsService. We avoid duplicate announcements
    // by tracking the last announced text.
    return Semantics(
      label: 'Instruction',
      hint: text,
      liveRegion: true,
      child: Builder(
        builder: (BuildContext context) {
          if ((isError || isSuccess) &&
              _isScreenReaderEnabled &&
              text.isNotEmpty &&
              text != _lastAnnouncement) {
            // Announce on next frame to ensure the semantics tree is ready.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                SemanticsService.announce(text, Directionality.of(context));
                _lastAnnouncement = text;
              } catch (_) {
                // In some test environments SemanticsService may not be available.
              }
            });
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getInstructionBackgroundColor(isError, isSuccess),
              border: _isHighContrastEnabled
                  ? Border.all(
                      color: _getInstructionBorderColor(isError, isSuccess),
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: _getAccessibleFontSize(16),
                fontWeight: isError || isSuccess ? FontWeight.bold : FontWeight.normal,
                color: _getInstructionTextColor(isError, isSuccess),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// Get instruction background color
  static Color _getInstructionBackgroundColor(bool isError, bool isSuccess) {
    if (_isHighContrastEnabled) {
      if (isError) return Colors.red.shade900;
      if (isSuccess) return Colors.green.shade900;
      return Colors.grey.shade900;
    }
    
    if (isError) return Colors.red.shade50;
    if (isSuccess) return Colors.green.shade50;
    return Colors.blue.shade50;
  }
  
  /// Get instruction border color
  static Color _getInstructionBorderColor(bool isError, bool isSuccess) {
    if (isError) return Colors.red.shade700;
    if (isSuccess) return Colors.green.shade700;
    return Colors.blue.shade700;
  }
  
  /// Get instruction text color
  static Color _getInstructionTextColor(bool isError, bool isSuccess) {
    if (_isHighContrastEnabled) {
      return Colors.white;
    }
    
    if (isError) return Colors.red.shade800;
    if (isSuccess) return Colors.green.shade800;
    return Colors.blue.shade800;
  }
  
  /// Get accessible font size
  static double _getAccessibleFontSize(double baseSize) => baseSize * _textScaleFactor.clamp(1.0, 2.0);
  
  /// Announce to screen reader
  static void announceToScreenReader(String message) {
    if (_isScreenReaderEnabled) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }
  
  /// Provide haptic feedback with accessibility consideration
  static void accessibleHapticFeedback({
    required bool isSuccess,
    bool isImportant = false,
  }) {
    if (isImportant) {
      HapticFeedback.heavyImpact();
    } else if (isSuccess) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }
  
  /// Build accessible progress indicator
  static Widget buildAccessibleProgress({
    required int currentStep,
    required int totalSteps,
    required Widget child,
  }) {
    final int progress = totalSteps > 0 ? (currentStep / totalSteps * 100).round() : 0;
    
    return Semantics(
      label: 'Training progress',
      value: 'Step $currentStep of $totalSteps, $progress% complete',
      child: child,
    );
  }
  
  /// Check if accessibility features are enabled
  static bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  static bool get isHighContrastEnabled => _isHighContrastEnabled;
  static bool get isLargeTextEnabled => _isLargeTextEnabled;
  static double get textScaleFactor => _textScaleFactor;
}

/// Extension for accessible widgets
extension AccessibilityExtensions on Widget {
  /// Add accessibility semantics to any widget
  Widget addAccessibilitySemantics({
    String? label,
    String? hint,
    String? value,
    bool button = false,
    bool header = false,
    VoidCallback? onTap,
  }) => Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      onTap: onTap,
      child: this,
    );
  
  /// Make widget screen reader focusable
  Widget makeScreenReaderFocusable({
    required String label,
    String? hint,
  }) => Semantics(
      label: label,
      hint: hint,
      focusable: true,
      child: this,
    );
}

/// Accessible color schemes
class AccessibleColors {
  static const Color primaryHighContrast = Color(0xFF000000);
  static const Color secondaryHighContrast = Color(0xFFFFFFFF);
  static const Color successHighContrast = Color(0xFF00AA00);
  static const Color errorHighContrast = Color(0xFFDD0000);
  static const Color warningHighContrast = Color(0xFFFF8800);
  
  /// Get accessible color based on contrast settings
  static Color getAccessibleColor({
    required Color normalColor,
    required Color highContrastColor,
  }) => AccessibilityManager.isHighContrastEnabled
        ? highContrastColor
        : normalColor;
}