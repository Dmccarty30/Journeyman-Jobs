import 'package:flutter/material.dart';
import '../../../../design_system/tailboard_theme.dart';
import '../../../../design_system/tailboard_components.dart';

class DirectMessagesDialog extends StatelessWidget {
  final VoidCallback? onNavigateToChat;

  const DirectMessagesDialog({
    super.key,
    this.onNavigateToChat,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: TailboardTheme.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        padding: const EdgeInsets.all(TailboardTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Direct Messages',
                  style: TailboardTheme.headingMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TailboardTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: TailboardTheme.spacingL),
            const Expanded(
              child: EmptyStateWidget(
                icon: Icons.forum,
                title: 'Direct Messaging',
                message: 'Send private messages to crew members',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
