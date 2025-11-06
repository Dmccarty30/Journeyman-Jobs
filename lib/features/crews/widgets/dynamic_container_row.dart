import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// A reusable row of tappable containers that change appearance based on selection.
///
/// This widget creates 4 equally-sized containers with electrical-themed styling
/// that respond to user taps with smooth animations and visual feedback.
///
/// **Design Features:**
/// - White background with copper borders by default
/// - Copper background with white text when selected
/// - Smooth scale animations on press/hover
/// - Consistent electrical theme integration
/// - Responsive sizing with flex layout
///
/// **Usage:**
/// ```dart
/// DynamicContainerRow(
///   labels: ['Feed', 'Jobs', 'Chat', 'Members'],
///   selectedIndex: 0,
///   onTap: (index) {
///     print('Tapped container at index: $index');
///   },
/// )
/// ```
class DynamicContainerRow extends StatefulWidget {
  /// The text labels to display in each container
  final List<String> labels;

  /// The currently selected container index (0-based)
  final int selectedIndex;

  /// Callback when a container is tapped, receives the tapped index
  final ValueChanged<int>? onTap;

  /// Optional custom height for containers (defaults to 60.0)
  final double? height;

  /// Optional spacing between containers (defaults to spacingSm)
  final double? spacing;

  const DynamicContainerRow({
    super.key,
    required this.labels,
    this.selectedIndex = 0,
    this.onTap,
    this.height,
    this.spacing,
  }) : assert(labels.length == 4, 'DynamicContainerRow requires exactly 4 labels');

  @override
  State<DynamicContainerRow> createState() => _DynamicContainerRowState();
}

class _DynamicContainerRowState extends State<DynamicContainerRow> {
  /// Tracks which container is currently being pressed for hover effect
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    final containerHeight = widget.height ?? 60.0;
    final containerSpacing = widget.spacing ?? AppTheme.spacingSm;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: List.generate(
          widget.labels.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < widget.labels.length - 1 ? containerSpacing : 0,
              ),
              child: _buildContainer(
                index: index,
                label: widget.labels[index],
                isSelected: index == widget.selectedIndex,
                height: containerHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an individual container with electrical theme styling
  ///
  /// Handles three states:
  /// - Default: white background, copper border
  /// - Selected: copper background, white text
  /// - Pressed: subtle scale animation
  Widget _buildContainer({
    required int index,
    required String label,
    required bool isSelected,
    required double height,
  }) {
    final isPressed = _pressedIndex == index;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressedIndex = index;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressedIndex = null;
        });
        widget.onTap?.call(index);
      },
      onTapCancel: () {
        setState(() {
          _pressedIndex = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: height,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentCopper : AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.accentCopper,
            width: AppTheme.borderWidthCopper,
          ),
          boxShadow: [
            AppTheme.shadowMd,
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: isSelected ? AppTheme.white : AppTheme.accentCopper,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          // Scale animation on press for tactile feedback
          .animate(
            target: isPressed ? 1 : 0,
          )
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.95, 0.95),
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          ),
    );
  }
}

/// A variant with custom icons alongside labels
///
/// This extended version allows adding icons to each container
/// for enhanced visual communication.
///
/// **Usage:**
/// ```dart
/// DynamicContainerRowWithIcons(
///   labels: ['Feed', 'Jobs', 'Chat', 'Members'],
///   icons: [
///     Icons.feed_outlined,
///     Icons.work_outline,
///     Icons.chat_bubble_outline,
///     Icons.group_outlined,
///   ],
///   selectedIndex: 0,
///   onTap: (index) {
///     print('Tapped container at index: $index');
///   },
/// )
/// ```
class DynamicContainerRowWithIcons extends StatefulWidget {
  /// The text labels to display in each container
  final List<String> labels;

  /// The icons to display above each label
  final List<IconData> icons;

  /// The currently selected container index (0-based)
  final int selectedIndex;

  /// Callback when a container is tapped, receives the tapped index
  final ValueChanged<int>? onTap;

  /// Optional custom height for containers (defaults to 80.0 for icons)
  final double? height;

  /// Optional spacing between containers (defaults to spacingSm)
  final double? spacing;

  const DynamicContainerRowWithIcons({
    super.key,
    required this.labels,
    required this.icons,
    this.selectedIndex = 0,
    this.onTap,
    this.height,
    this.spacing,
  }) : assert(labels.length == 4 && icons.length == 4,
          'DynamicContainerRowWithIcons requires exactly 4 labels and 4 icons');

  @override
  State<DynamicContainerRowWithIcons> createState() => _DynamicContainerRowWithIconsState();
}

class _DynamicContainerRowWithIconsState extends State<DynamicContainerRowWithIcons> {
  /// Tracks which container is currently being pressed for hover effect
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    final containerHeight = widget.height ?? 80.0;
    final containerSpacing = widget.spacing ?? AppTheme.spacingSm;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: List.generate(
          widget.labels.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < widget.labels.length - 1 ? containerSpacing : 0,
              ),
              child: _buildContainerWithIcon(
                index: index,
                label: widget.labels[index],
                icon: widget.icons[index],
                isSelected: index == widget.selectedIndex,
                height: containerHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an individual container with icon and electrical theme styling
  Widget _buildContainerWithIcon({
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
    required double height,
  }) {
    final isPressed = _pressedIndex == index;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressedIndex = index;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressedIndex = null;
        });
        widget.onTap?.call(index);
      },
      onTapCancel: () {
        setState(() {
          _pressedIndex = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: height,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentCopper : AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.accentCopper,
            width: AppTheme.borderWidthCopper,
          ),
          boxShadow: [
            AppTheme.shadowMd,
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppTheme.iconMd,
              color: isSelected ? AppTheme.white : AppTheme.accentCopper,
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: isSelected ? AppTheme.white : AppTheme.accentCopper,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )
          // Scale animation on press for tactile feedback
          .animate(
            target: isPressed ? 1 : 0,
          )
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.95, 0.95),
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          ),
    );
  }
}
