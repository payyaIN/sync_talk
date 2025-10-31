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
      reverse: false,
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isTyping && index == messages.length) {
          return const Padding(
            padding: EdgeInsets.only(left: 8),
            child: TypingIndicator(),
          );
        }

        final message = messages[index];
        final isMine = message['sender'] == myId;
        final createdAt = DateTime.parse(message["createdAt"]);

        // Insert date separator
        bool showDateHeader = false;
        if (index == 0)
          showDateHeader = true;
        else {
          final prev = DateTime.parse(messages[index - 1]["createdAt"]);
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
              message: message["message"] ?? "",
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
