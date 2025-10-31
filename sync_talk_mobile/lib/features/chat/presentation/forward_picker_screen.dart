import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/chat_viewmodel.dart';

class ForwardPickerScreen extends ConsumerWidget {
  final Map<String, dynamic> sourceMessage; // the message being forwarded
  const ForwardPickerScreen({super.key, required this.sourceMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Forward to')),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (_, i) {
          final c = chats[i];
          final title = c["name"] ?? "Chat";
          return ListTile(
            title: Text(title),
            onTap: () async {
              await ref
                  .read(chatViewModelProvider)
                  .forwardMessage(
                    targetConversationId: c["_id"],
                    forwardOf: sourceMessage["_id"],
                    // Optional: also copy text
                    text: sourceMessage["message"] ?? "",
                  );
              if (context.mounted) Navigator.pop(context, true);
            },
          );
        },
      ),
    );
  }
}
