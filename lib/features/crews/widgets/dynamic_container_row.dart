import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/tailboard_theme.dart';

/// Dynamic row of 4 clickable containers with labels that change based on selected tab
class DynamicContainerRow extends StatefulWidget {
  final List<String> labels;
  final Function(int) onContainerTap;

  const DynamicContainerRow({
    super.key,
    required this.labels,
    required this.onContainerTap,
  });

  @override
  State<DynamicContainerRow> createState() => _DynamicContainerRowState();
}

class _DynamicContainerRowState extends State<DynamicContainerRow> {
  int? _tappedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TailboardTheme.backgroundDark,
      padding: const EdgeInsets.symmetric(
        horizontal: TailboardTheme.spacingM,
        vertical: TailboardTheme.spacingS,
      ),
      child: Row(
        children: List.generate(
          widget.labels.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index > 0 ? TailboardTheme.spacingXS : 0,
                right: index < widget.labels.length - 1 ? TailboardTheme.spacingXS : 0,
              ),
              child: _buildContainer(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(int index) {
    final isTapped = _tappedIndex == index;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _tappedIndex = index;
        });
      },
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _tappedIndex = null;
            });
          }
        });
        widget.onContainerTap(index);
      },
      onTapCancel: () {
        setState(() {
          _tappedIndex = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: TailboardTheme.spacingS,
          vertical: TailboardTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: isTapped
              ? TailboardTheme.copper.withValues(alpha: 0.2)
              : TailboardTheme.backgroundCard,
          borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
          border: Border.all(
            color: isTapped
                ? TailboardTheme.copper
                : TailboardTheme.border,
            width: isTapped ? 2 : 1,
          ),
          boxShadow: isTapped
              ? [
                  BoxShadow(
                    color: TailboardTheme.copper.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            widget.labels[index],
            style: TailboardTheme.labelMedium.copyWith(
              color: isTapped
                  ? TailboardTheme.copper
                  : TailboardTheme.textSecondary,
              fontWeight: isTapped ? FontWeight.bold : FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ).animate(
        target: isTapped ? 1 : 0,
      ).scale(
        begin: const Offset(1, 1),
        end: const Offset(0.95, 0.95),
        duration: 150.ms,
      ),
    );
  }
}

/// Icon-based version of dynamic container row
class DynamicIconContainerRow extends StatefulWidget {
  final List<DynamicContainerItem> items;
  final Function(int) onContainerTap;

  const DynamicIconContainerRow({
    super.key,
    required this.items,
    required this.onContainerTap,
  });

  @override
  State<DynamicIconContainerRow> createState() => _DynamicIconContainerRowState();
}

class _DynamicIconContainerRowState extends State<DynamicIconContainerRow> {
  int? _tappedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TailboardTheme.backgroundDark,
      padding: const EdgeInsets.symmetric(
        horizontal: TailboardTheme.spacingM,
        vertical: TailboardTheme.spacingS,
      ),
      child: Row(
        children: List.generate(
          widget.items.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index > 0 ? TailboardTheme.spacingXS : 0,
                right: index < widget.items.length - 1 ? TailboardTheme.spacingXS : 0,
              ),
              child: _buildContainer(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(int index) {
    final item = widget.items[index];
    final isTapped = _tappedIndex == index;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _tappedIndex = index;
        });
      },
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _tappedIndex = null;
            });
          }
        });
        widget.onContainerTap(index);
      },
      onTapCancel: () {
        setState(() {
          _tappedIndex = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: TailboardTheme.spacingS,
          vertical: TailboardTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: isTapped
              ? TailboardTheme.copper.withValues(alpha: 0.2)
              : TailboardTheme.backgroundCard,
          borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
          border: Border.all(
            color: isTapped
                ? TailboardTheme.copper
                : TailboardTheme.border,
            width: isTapped ? 2 : 1,
          ),
          boxShadow: isTapped
              ? [
                  BoxShadow(
                    color: TailboardTheme.copper.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 24,
              color: isTapped
                  ? TailboardTheme.copper
                  : TailboardTheme.textSecondary,
            ),
            const SizedBox(height: TailboardTheme.spacingXS),
            Text(
              item.label,
              style: TailboardTheme.labelSmall.copyWith(
                color: isTapped
                    ? TailboardTheme.copper
                    : TailboardTheme.textTertiary,
                fontWeight: isTapped ? FontWeight.bold : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ).animate(
        target: isTapped ? 1 : 0,
      ).scale(
        begin: const Offset(1, 1),
        end: const Offset(0.95, 0.95),
        duration: 150.ms,
      ),
    );
  }
}

/// Container item model for icon-based row
class DynamicContainerItem {
  final String label;
  final IconData icon;

  const DynamicContainerItem({
    required this.label,
    required this.icon,
  });
}
