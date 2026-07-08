import 'package:flutter/material.dart';
import '../../../core/widgets/chat_bubble.dart';
import '../../../core/widgets/typing_indicator.dart';

class MessagesList extends StatelessWidget {
  final List messages;
  final String myId;
  final bool isTyping;

  const MessagesList({
    super.key,
    required this.messages,
    required this.myId,
    required this.isTyping,
  });

  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isTyping && index == 0) {
          return const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TypingIndicator(),
            ),
          );
        }

        final messageIndex = isTyping ? index - 1 : index;
        final message = messages[messageIndex];
        final isMine = message['sender'] == myId;
        final createdAt = DateTime.parse(message["createdAt"] ?? DateTime.now().toIso8601String());

        // Insert date separator
        bool showDateHeader = false;
        if (messageIndex == messages.length - 1) {
          showDateHeader = true;
        } else {
          final prev = DateTime.parse(messages[messageIndex + 1]["createdAt"] ?? DateTime.now().toIso8601String());
          if (_isDifferentDay(prev, createdAt)) {
            showDateHeader = true;
          }
        }

        return Column(
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Chip(
                  label: Text(
                    "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ChatBubble(
              message: message["content"] ?? message["message"] ?? "",
              isMine: isMine,
              time:
                  "${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}",
              status: message['status'] ?? 'sent',
            ),
          ],
        );
      },
    );
  }
}
