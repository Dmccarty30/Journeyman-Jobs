import 'package:flutter/material.dart';

/// Responsive layout manager for transformer trainer
class ResponsiveLayoutManager {
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.largeMobile;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// Get layout configuration for current device
  static LayoutConfig getLayoutConfig(BuildContext context) {
    final DeviceType deviceType = getDeviceType(context);
    final Size screenSize = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;
    
    switch (deviceType) {
      case DeviceType.mobile:
        return _getMobileLayout(screenSize, orientation);
      case DeviceType.largeMobile:
        return _getLargeMobileLayout(screenSize, orientation);
      case DeviceType.tablet:
        return _getTabletLayout(screenSize, orientation);
      case DeviceType.desktop:
        return _getDesktopLayout(screenSize, orientation);
    }
  }
  
  /// Mobile layout (< 480px)
  static LayoutConfig _getMobileLayout(Size screenSize, Orientation orientation) => LayoutConfig(
      controlsPosition: ControlsPosition.bottomSheet,
      diagramSize: Size(
        screenSize.width - 32, // Account for padding
        (screenSize.height * 0.6).clamp(300, 500),
      ),
      connectionPointSize: 32,
      touchTargetSize: 44,
      showFloatingInstructions: true,
      enableMagnification: true,
      scrollableDiagram: true,
      compactControls: true,
      showModeToggleInDialog: true,
      bankTypeSelectorRows: 3, // Stack bank types in rows
      instructionPosition: InstructionPosition.floating,
      enableQuickActions: true,
    );
  
  /// Large mobile layout (480px - 768px)
  static LayoutConfig _getLargeMobileLayout(Size screenSize, Orientation orientation) {
    final bool isLandscape = orientation == Orientation.landscape;
    
    return LayoutConfig(
      controlsPosition: isLandscape ? ControlsPosition.sidebar : ControlsPosition.topPanel,
      diagramSize: Size(
        isLandscape ? screenSize.width * 0.7 : screenSize.width - 32,
        isLandscape ? screenSize.height - 100 : screenSize.height * 0.65,
      ),
      connectionPointSize: 34,
      touchTargetSize: 46,
      showFloatingInstructions: !isLandscape,
      enableMagnification: true,
      scrollableDiagram: isLandscape,
      compactControls: false,
      showModeToggleInDialog: false,
      bankTypeSelectorRows: 2,
      instructionPosition: isLandscape ? InstructionPosition.sidebar : InstructionPosition.top,
      enableQuickActions: true,
    );
  }
  
  /// Tablet layout (768px - 1024px)
  static LayoutConfig _getTabletLayout(Size screenSize, Orientation orientation) {
    final bool isLandscape = orientation == Orientation.landscape;
    
    return LayoutConfig(
      controlsPosition: ControlsPosition.sidebar,
      diagramSize: Size(
        isLandscape ? screenSize.width * 0.75 : screenSize.width * 0.7,
        isLandscape ? screenSize.height - 80 : screenSize.height * 0.7,
      ),
      connectionPointSize: 36,
      touchTargetSize: 48,
      showFloatingInstructions: false,
      enableMagnification: false,
      scrollableDiagram: false,
      compactControls: false,
      showModeToggleInDialog: false,
      bankTypeSelectorRows: 1,
      instructionPosition: InstructionPosition.sidebar,
      enableQuickActions: false,
    );
  }
  
  /// Desktop layout (>= 1024px)
  static LayoutConfig _getDesktopLayout(Size screenSize, Orientation orientation) => LayoutConfig(
      controlsPosition: ControlsPosition.sidebar,
      diagramSize: Size(
        screenSize.width * 0.8,
        (screenSize.height * 0.8).clamp(400, 800),
      ),
      connectionPointSize: 28,
      touchTargetSize: 40,
      showFloatingInstructions: false,
      enableMagnification: false,
      scrollableDiagram: false,
      compactControls: false,
      showModeToggleInDialog: false,
      bankTypeSelectorRows: 1,
      instructionPosition: InstructionPosition.sidebar,
      enableQuickActions: false,
    );
  
  /// Get appropriate padding for current device
  static EdgeInsets getPadding(BuildContext context) {
    final DeviceType deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(8);
      case DeviceType.largeMobile:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.desktop:
        return const EdgeInsets.all(20);
    }
  }
  
  /// Get appropriate font sizes for current device
  static TextScaling getTextScaling(BuildContext context) {
    final DeviceType deviceType = getDeviceType(context);
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    double baseScale;
    switch (deviceType) {
      case DeviceType.mobile:
        baseScale = 1.1; // Slightly larger on mobile
        break;
      case DeviceType.largeMobile:
        baseScale = 1.05;
        break;
      case DeviceType.tablet:
      case DeviceType.desktop:
        baseScale = 1.0;
        break;
    }
    
    return TextScaling(
      labelScale: baseScale * textScaleFactor,
      instructionScale: (baseScale + 0.1) * textScaleFactor,
      titleScale: (baseScale + 0.2) * textScaleFactor,
    );
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  largeMobile,
  tablet,
  desktop,
}

/// Controls position options
enum ControlsPosition {
  topPanel,
  bottomSheet,
  sidebar,
  floating,
}

/// Instruction position options
enum InstructionPosition {
  top,
  bottom,
  sidebar,
  floating,
  overlay,
}

/// Layout configuration class
class LayoutConfig {
  
  const LayoutConfig({
    required this.controlsPosition,
    required this.diagramSize,
    required this.connectionPointSize,
    required this.touchTargetSize,
    required this.showFloatingInstructions,
    required this.enableMagnification,
    required this.scrollableDiagram,
    required this.compactControls,
    required this.showModeToggleInDialog,
    required this.bankTypeSelectorRows,
    required this.instructionPosition,
    required this.enableQuickActions,
  });
  final ControlsPosition controlsPosition;
  final Size diagramSize;
  final double connectionPointSize;
  final double touchTargetSize;
  final bool showFloatingInstructions;
  final bool enableMagnification;
  final bool scrollableDiagram;
  final bool compactControls;
  final bool showModeToggleInDialog;
  final int bankTypeSelectorRows;
  final InstructionPosition instructionPosition;
  final bool enableQuickActions;
}

/// Text scaling configuration
class TextScaling {
  
  const TextScaling({
    required this.labelScale,
    required this.instructionScale,
    required this.titleScale,
  });
  final double labelScale;
  final double instructionScale;
  final double titleScale;
}

/// Responsive builder widget
class ResponsiveTransformerLayout extends StatelessWidget {
  
  const ResponsiveTransformerLayout({
    required this.builder, super.key,
  });
  final Widget Function(BuildContext context, LayoutConfig config) builder;
  
  @override
  Widget build(BuildContext context) {
    final LayoutConfig config = ResponsiveLayoutManager.getLayoutConfig(context);
    return builder(context, config);
  }
}

/// Helper extension for responsive dimensions
extension ResponsiveDimensions on BuildContext {
  /// Get responsive diagram size
  Size get responsiveDiagramSize => ResponsiveLayoutManager.getLayoutConfig(this).diagramSize;
  
  /// Get responsive connection point size
  double get responsiveConnectionPointSize => ResponsiveLayoutManager.getLayoutConfig(this).connectionPointSize;
  
  /// Get responsive touch target size
  double get responsiveTouchTargetSize => ResponsiveLayoutManager.getLayoutConfig(this).touchTargetSize;
  
  /// Check if current device needs compact layout
  bool get needsCompactLayout => ResponsiveLayoutManager.getLayoutConfig(this).compactControls;
  
  /// Check if floating instructions should be shown
  bool get shouldShowFloatingInstructions => ResponsiveLayoutManager.getLayoutConfig(this).showFloatingInstructions;
}