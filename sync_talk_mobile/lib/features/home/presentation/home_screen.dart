import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/dio_client.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/utils/secure_token_store.dart';
import '../../../core/routing/app_router.dart';
import '../../auth/viewmodel/auth_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List chats = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final me = await ApiClient.dio.get('/auth/me');
      ref.read(authStateProvider.notifier).state = me.data['data'];

      final myId = me.data['data']['_id'];
      SocketService.connect(myId);

      final res = await ApiClient.dio.get('/conversations');
      setState(() {
        chats = res.data['data'];
        loading = false;
      });
    } catch (e) {
      loading = false;
    }
  }

  Future<void> _logout() async {
    await SecureTokenStore.clear();
    ref.read(authStateProvider.notifier).state = null;
    appRouter.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("SyncTalk"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
          ? const Center(child: Text("No chats yet"))
          : ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = chats[i];
                final isGroup = c['isGroup'] == true;
                String title = "Unknown";

                if (isGroup) {
                  title = c['groupName'] ?? 'Group';
                } else {
                  final others = (c['participants'] as List)
                      .where((p) => p['_id'] != myId)
                      .toList();
                  title = others.isNotEmpty ? others[0]['name'] : 'Chat';
                }

                return ListTile(
                  title: Text(title),
                  subtitle: Text(
                    c['lastMessage'] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => appRouter.go('/chat/${c['_id']}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final searchCtrl = TextEditingController();
          final email = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Start Chat"),
              content: TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  hintText: "Search user by name/email",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, searchCtrl.text.trim()),
                  child: const Text("Search"),
                ),
              ],
            ),
          );

          if (email != null && email.isNotEmpty) {
            final users = await ApiClient.dio.get(
              '/auth/search',
              queryParameters: {'q': email},
            );
            final list = users.data['data'] as List;
            if (list.isNotEmpty) {
              final otherId = list[0]['_id'];
              final chat = await ApiClient.dio.post(
                '/conversations/private',
                data: {'userId': otherId},
              );
              if (mounted) appRouter.go('/chat/${chat.data['data']['_id']}');
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("User not found")));
            }
          }
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
