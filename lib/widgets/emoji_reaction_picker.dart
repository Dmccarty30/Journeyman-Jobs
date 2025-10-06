import 'package:flutter/material.dart';
import 'reaction_animation.dart';
import '../design_system/app_theme.dart';

/// A widget that displays a grid of selectable emojis for reacting to content.
///
/// It presents a list of emojis in a themed container, and allows the user
/// to select one, triggering a callback with the chosen emoji.
class EmojiReactionPicker extends StatelessWidget {
  /// A callback function that is invoked when an emoji is selected.
  /// It passes the selected emoji as a `String`.
  final Function(String emoji) onEmojiSelected;
  /// The list of emoji strings to be displayed as available reactions.
  final List<String> availableEmojis;

  /// Creates an [EmojiReactionPicker] widget.
  const EmojiReactionPicker({
    super.key,
    required this.onEmojiSelected,
    required this.availableEmojis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black87, // Electrical background
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.accentCopper, width: 2.0), // Copper accent border
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCopper.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: availableEmojis.length,
        itemBuilder: (context, index) {
          final emoji = availableEmojis[index];
          return EnhancedReactionAnimation(
            emoji: emoji,
            isSelected: false, // Will be managed by parent
            onTap: () => onEmojiSelected(emoji),
          );
        },
      ),
    );
  }
}