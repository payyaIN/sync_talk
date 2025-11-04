import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_talk_mobile/features/chat/presentation/chat_screen.dart';
import '../viewmodel/chat_viewmodel.dart';

class UserSearchScreen extends ConsumerWidget {
  UserSearchScreen({super.key});
  final searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("New Chat")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(hintText: "Search users..."),
              onChanged: (val) =>
                  ref.read(chatViewModelProvider).searchUsers(val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(results[i]['name']),
                onTap: () async {
                  final convo = await ref
                      .read(chatViewModelProvider)
                      .startPrivateChat(results[i]["_id"]);
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(conversation: convo),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
