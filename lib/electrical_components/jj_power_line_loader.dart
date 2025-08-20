import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';
import 'power_line_loader.dart';

/// JJ-themed wrapper for PowerLineLoader with consistent styling
/// Provides a standardized loading indicator with electrical theme
class JJPowerLineLoader extends StatelessWidget {
  /// Message to display below the loader
  final String? message;
  
  /// Size of the loader animation
  final double size;
  
  /// Color of the power lines
  final Color? color;
  
  /// Whether to show the message
  final bool showMessage;
  
  /// Text style for the message
  final TextStyle? messageStyle;
  
  /// Padding around the entire widget
  final EdgeInsets padding;
  
  /// Background color for the loader area
  final Color? backgroundColor;
  
  /// Whether to show a semi-transparent overlay
  final bool showOverlay;
  
  const JJPowerLineLoader({
    super.key,
    this.message,
    this.size = 80.0,
    this.color,
    this.showMessage = true,
    this.messageStyle,
    this.padding = const EdgeInsets.all(AppTheme.spacingMd),
    this.backgroundColor,
    this.showOverlay = false,
  });
  
  /// Factory constructor for overlay loading (full screen)
  factory JJPowerLineLoader.overlay({
    String? message,
    double size = 100.0,
    Color? color,
    TextStyle? messageStyle,
  }) {
    return JJPowerLineLoader(
      message: message,
      size: size,
      color: color,
      messageStyle: messageStyle,
      showOverlay: true,
      backgroundColor: AppTheme.black.withValues(alpha: 0.7),
      padding: const EdgeInsets.all(AppTheme.spacingXl),
    );
  }
  
  /// Factory constructor for inline loading (within content)
  factory JJPowerLineLoader.inline({
    String? message,
    double size = 60.0,
    Color? color,
    bool showMessage = true,
  }) {
    return JJPowerLineLoader(
      message: message,
      size: size,
      color: color,
      showMessage: showMessage,
      showOverlay: false,
      padding: const EdgeInsets.all(AppTheme.spacingSm),
    );
  }
  
  /// Factory constructor for small loading indicators
  factory JJPowerLineLoader.small({
    String? message,
    Color? color,
  }) {
    return JJPowerLineLoader(
      message: message,
      size: 40.0,
      color: color,
      showMessage: message != null,
      padding: const EdgeInsets.all(AppTheme.spacingXs),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.accentCopper;
    final effectiveMessageStyle = messageStyle ?? AppTheme.bodyMedium.copyWith(
      color: showOverlay ? AppTheme.white : AppTheme.darkGray,
    );
    
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Power line loader animation
        PowerLineLoader(
          width: size * 3, // Make width proportional to size
          height: size,
          pulseColor: effectiveColor,
          lineColor: showOverlay ? AppTheme.white.withValues(alpha: 0.7) : AppTheme.darkGray,
          towerColor: showOverlay ? AppTheme.white.withValues(alpha: 0.8) : AppTheme.secondaryNavy,
        ),
        
        // Message text
        if (showMessage && message != null) ...[
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            message!,
            style: effectiveMessageStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
    
    // Wrap with padding
    content = Padding(
      padding: padding,
      child: content,
    );
    
    // Add background if specified
    if (backgroundColor != null) {
      content = Container(
        color: backgroundColor,
        child: content,
      );
    }
    
    // Add overlay behavior if needed
    if (showOverlay) {
      content = Material(
        color: Colors.transparent,
        child: Center(child: content),
      );
    }
    
    return content;
  }
}

/// Extension methods for easy usage
extension JJPowerLineLoaderExtensions on BuildContext {
  /// Show a power line loader overlay
  void showPowerLineLoader({
    String? message,
    double size = 100.0,
    Color? color,
  }) {
    showDialog(
      context: this,
      barrierDismissible: false,
      barrierColor: AppTheme.black.withValues(alpha: 0.7),
      builder: (context) => JJPowerLineLoader.overlay(
        message: message,
        size: size,
        color: color,
      ),
    );
  }
  
  /// Hide the power line loader overlay
  void hidePowerLineLoader() {
    Navigator.of(this).pop();
  }
}

/// Utility class for managing power line loader states
class PowerLineLoaderController {
  bool _isLoading = false;
  String? _message;
  
  /// Whether the loader is currently showing
  bool get isLoading => _isLoading;
  
  /// Current message being displayed
  String? get message => _message;
  
  /// Show the loader with optional message
  void show(BuildContext context, {String? message}) {
    if (!_isLoading) {
      _isLoading = true;
      _message = message;
      context.showPowerLineLoader(message: message);
    }
  }
  
  /// Hide the loader
  void hide(BuildContext context) {
    if (_isLoading) {
      _isLoading = false;
      _message = null;
      context.hidePowerLineLoader();
    }
  }
  
  /// Update the message while loader is showing
  void updateMessage(String message) {
    _message = message;
    // Note: This would require a more complex implementation
    // to update the existing dialog. For now, just store the message.
  }
  
  /// Dispose of the controller
  void dispose() {
    _isLoading = false;
    _message = null;
  }
}
