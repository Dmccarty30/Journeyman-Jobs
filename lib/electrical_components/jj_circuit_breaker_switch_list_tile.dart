import 'package:flutter/material.dart';
import 'jj_circuit_breaker_switch.dart';

/// A list tile widget that uses JJCircuitBreakerSwitch instead of the standard Material switch
/// Provides the same API as SwitchListTile while maintaining the electrical theme
class JJCircuitBreakerSwitchListTile extends StatelessWidget {
  /// The primary content of the list tile
  final Widget? title;
  
  /// Additional content displayed below the title
  final Widget? subtitle;
  
  /// A widget to display before the title (typically an icon)
  final Widget? secondary;
  
  /// Whether this switch is checked
  final bool value;
  
  /// Called when the user toggles the switch
  final ValueChanged<bool>? onChanged;
  
  /// Size of the circuit breaker switch
  final JJCircuitBreakerSize size;
  
  /// Whether to show electrical effects when toggling
  final bool showElectricalEffects;
  
  /// Whether this list tile is part of a vertically dense list
  final bool dense;
  
  /// The tile's internal padding
  final EdgeInsetsGeometry? contentPadding;
  
  /// Whether to render icons and text in the activeColor
  final bool? selected;
  
  /// Defines the color used for icons and text when the list tile is selected
  final Color? selectedTileColor;
  
  /// The background color of the tile
  final Color? tileColor;
  
  /// Whether this list tile is interactive
  final bool enabled;
  
  /// Called when the user taps this list tile
  final GestureTapCallback? onTap;
  
  /// The shape of the list tile
  final ShapeBorder? shape;
  
  /// Whether to apply a visual indication that this tile is enabled or disabled
  final bool? enableFeedback;
  
  /// The horizontal gap between the titles and the leading/trailing widgets
  final double? horizontalTitleGap;
  
  /// The minimum padding on the top and bottom of the title and subtitle widgets
  final double? minVerticalPadding;
  
  /// Defines how compact the list tile's layout will be
  final VisualDensity? visualDensity;
  
  /// How to align the leading and trailing widgets vertically
  final ListTileControlAffinity controlAffinity;

  const JJCircuitBreakerSwitchListTile({
    super.key,
    this.title,
    this.subtitle,
    this.secondary,
    required this.value,
    this.onChanged,
    this.size = JJCircuitBreakerSize.small,
    this.showElectricalEffects = true,
    this.dense = false,
    this.contentPadding,
    this.selected,
    this.selectedTileColor,
    this.tileColor,
    this.enabled = true,
    this.onTap,
    this.shape,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.visualDensity,
    this.controlAffinity = ListTileControlAffinity.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && onChanged != null;
    
    // Create the circuit breaker switch
    final switchWidget = JJCircuitBreakerSwitch(
      value: value,
      onChanged: isEnabled ? onChanged : null,
      size: size,
      showElectricalEffects: showElectricalEffects,
    );
    
    // Handle different control positions
    Widget? leading;
    Widget? trailing;
    
    switch (controlAffinity) {
      case ListTileControlAffinity.leading:
        leading = switchWidget;
        trailing = secondary;
        break;
      case ListTileControlAffinity.trailing:
        leading = secondary;
        trailing = switchWidget;
        break;
      case ListTileControlAffinity.platform:
        // On most platforms, switches are trailing
        leading = secondary;
        trailing = switchWidget;
        break;
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? (isEnabled ? () => onChanged?.call(!value) : null),
        customBorder: shape,
        enableFeedback: enableFeedback ?? true,
        child: Container(
          decoration: BoxDecoration(
            color: tileColor ?? (selected == true ? selectedTileColor : null),
            shape: BoxShape.rectangle,
          ),
          child: ListTile(
            leading: leading,
            title: _buildTitle(context, isEnabled),
            subtitle: _buildSubtitle(context, isEnabled),
            trailing: trailing,
            dense: dense,
            contentPadding: contentPadding,
            selected: selected ?? false,
            enabled: isEnabled,
            horizontalTitleGap: horizontalTitleGap,
            minVerticalPadding: minVerticalPadding,
            visualDensity: visualDensity,
            // Don't set onTap here as we handle it in the InkWell above
          ),
        ),
      ),
    );
  }
  
  Widget? _buildTitle(BuildContext context, bool isEnabled) {
    if (title == null) return null;
    
    if (title is Text) {
      final textWidget = title as Text;
      return Text(
        textWidget.data ?? '',
        style: _getTitleStyle(context, isEnabled).merge(textWidget.style),
        overflow: textWidget.overflow,
        maxLines: textWidget.maxLines,
        textAlign: textWidget.textAlign,
        softWrap: textWidget.softWrap,
      );
    }
    
    return title;
  }
  
  Widget? _buildSubtitle(BuildContext context, bool isEnabled) {
    if (subtitle == null) return null;
    
    if (subtitle is Text) {
      final textWidget = subtitle as Text;
      return Text(
        textWidget.data ?? '',
        style: _getSubtitleStyle(context, isEnabled).merge(textWidget.style),
        overflow: textWidget.overflow,
        maxLines: textWidget.maxLines,
        textAlign: textWidget.textAlign,
        softWrap: textWidget.softWrap,
      );
    }
    
    return subtitle;
  }
  
  TextStyle _getTitleStyle(BuildContext context, bool isEnabled) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    if (!isEnabled) {
      return textTheme.bodyLarge!.copyWith(
        color: theme.disabledColor,
      );
    }
    
    if (selected == true) {
      return textTheme.bodyLarge!.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w500,
      );
    }
    
    return textTheme.bodyLarge!.copyWith(
      fontWeight: FontWeight.w500,
    );
  }
  
  TextStyle _getSubtitleStyle(BuildContext context, bool isEnabled) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    if (!isEnabled) {
      return textTheme.bodyMedium!.copyWith(
        color: theme.disabledColor.withValues(alpha: 0.6),
      );
    }
    
    return textTheme.bodyMedium!.copyWith(
      color: theme.textTheme.bodySmall?.color,
    );
  }
}