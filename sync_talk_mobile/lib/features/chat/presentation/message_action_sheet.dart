import 'package:flutter/material.dart';

class MessageActionSheet extends StatelessWidget {
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const MessageActionSheet({
    super.key,
    required this.onReply,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text("Reply"),
            onTap: onReply,
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text("Copy"),
            onTap: onCopy,
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text("Delete for me"),
            onTap: onDelete,
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
