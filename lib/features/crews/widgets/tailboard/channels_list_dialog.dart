import 'package:flutter/material.dart';
import '../../../../design_system/tailboard_theme.dart';
import '../../../../design_system/tailboard_components.dart';

class ChannelListDialog extends StatelessWidget {
  final VoidCallback? onNavigateToChat;

  const ChannelListDialog({
    super.key,
    this.onNavigateToChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: TailboardTheme.backgroundCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TailboardTheme.radiusXL),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(TailboardTheme.spacingL),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: TailboardTheme.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Channels',
                  style: TailboardTheme.headingMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TailboardTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Expanded(
            child: EmptyStateWidget(
              icon: Icons.tag,
              title: 'Channel Management',
              message: 'Create and manage crew channels for organized communication',
            ),
          ),
        ],
      ),
    );
  }
}
