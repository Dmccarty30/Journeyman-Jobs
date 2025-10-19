import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/features/crews/providers/global_feed_riverpod_provider.dart';
import 'package:journeyman_jobs/features/crews/providers/messaging_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import 'package:journeyman_jobs/widgets/chat_input.dart';
import 'package:journeyman_jobs/widgets/message_bubble.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalMessages = ref.watch(globalMessagesProvider);
    final currentUser = ref.watch(auth_providers.currentUserProvider);
    final messageService = ref.watch(messageServiceProvider);

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view global chat.'));
    }

    return Column(
      children: [
        Expanded(
          child: globalMessages.isEmpty
              ? const Center(child: Text('No messages yet.'))
              : ListView.builder(
                  reverse: true,
                  itemCount: globalMessages.length,
                  itemBuilder: (context, index) {
                    final message = globalMessages[index];
                    return MessageBubble(
                      message: message,
                      isMe: message.senderId == currentUser.uid,
                    );
                  },
                ),
        ),
        ChatInput(
          crewId: 'default',
          convId: 'global',
          onSendMessage: (content) {
            messageService.sendGlobalMessage(
              senderId: currentUser.uid,
              content: content,
            );
          },
        ),
      ],
    );
  }
}
