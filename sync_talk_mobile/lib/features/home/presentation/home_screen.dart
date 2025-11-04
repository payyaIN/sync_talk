// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/dio_client.dart';
// import '../../../core/services/socket_service.dart';
// import '../../../core/utils/secure_token_store.dart';
// import '../../../core/routing/app_router.dart';
// import '../../auth/viewmodel/auth_providers.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   List chats = [];
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadChats();
//   }

//   Future<void> _loadChats() async {
//     try {
//       final me = await ApiClient.dio.get('/auth/me');
//       ref.read(authStateProvider.notifier).state = me.data['data'];

//       final myId = me.data['data']['_id'];
//       SocketService.connect(myId);

//       final res = await ApiClient.dio.get('/conversations');
//       setState(() {
//         chats = res.data['data'];
//         loading = false;
//       });
//     } catch (e) {
//       loading = false;
//     }
//   }

//   Future<void> _logout() async {
//     await SecureTokenStore.clear();
//     ref.read(authStateProvider.notifier).state = null;
//     appRouter.go('/login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final myId = ref.watch(currentUserIdProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("SyncTalk"),
//         actions: [
//           IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : chats.isEmpty
//           ? const Center(child: Text("No chats yet"))
//           : ListView.separated(
//               itemCount: chats.length,
//               separatorBuilder: (_, __) => const Divider(height: 1),
//               itemBuilder: (_, i) {
//                 final c = chats[i];
//                 final isGroup = c['isGroup'] == true;
//                 String title = "Unknown";

//                 if (isGroup) {
//                   title = c['groupName'] ?? 'Group';
//                 } else {
//                   final others = (c['participants'] as List)
//                       .where((p) => p['_id'] != myId)
//                       .toList();
//                   title = others.isNotEmpty ? others[0]['name'] : 'Chat';
//                 }

//                 return ListTile(
//                   title: Text(title),
//                   subtitle: Text(
//                     c['lastMessage'] ?? "",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   onTap: () => appRouter.go('/chat/${c['_id']}'),
//                 );
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final searchCtrl = TextEditingController();
//           final email = await showDialog<String>(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text("Start Chat"),
//               content: TextField(
//                 controller: searchCtrl,
//                 decoration: const InputDecoration(
//                   hintText: "Search user by name/email",
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () =>
//                       Navigator.pop(context, searchCtrl.text.trim()),
//                   child: const Text("Search"),
//                 ),
//               ],
//             ),
//           );

//           if (email != null && email.isNotEmpty) {
//             final users = await ApiClient.dio.get(
//               '/auth/search',
//               queryParameters: {'q': email},
//             );
//             final list = users.data['data'] as List;
//             if (list.isNotEmpty) {
//               final otherId = list[0]['_id'];
//               final chat = await ApiClient.dio.post(
//                 '/conversations/private',
//                 data: {'userId': otherId},
//               );
//               if (mounted) appRouter.go('/chat/${chat.data['data']['_id']}');
//             } else {
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(const SnackBar(content: Text("User not found")));
//             }
//           }
//         },
//         child: const Icon(Icons.chat),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api.dart';
import '../../../core/services/session.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load user info
      final userResponse = await dio.get('/users/me');
      _currentUser = userResponse.data;

      // Load conversations
      final convResponse = await dio.get('/conversations');
      _conversations = List<Map<String, dynamic>>.from(convResponse.data);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _extractErrorMessage(e);
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  Future<void> _startNewChat() async {
    final searchText = await showDialog<String>(
      context: context,
      builder: (context) => _SearchUserDialog(controller: _searchController),
    );

    if (searchText == null || searchText.trim().isEmpty) return;

    try {
      // Search for user
      final response = await dio.get(
        '/users',
        queryParameters: {'search': searchText.trim()},
      );

      final users = List<Map<String, dynamic>>.from(response.data);

      if (!mounted) return;

      if (users.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No users found')));
        return;
      }

      // Show user selection dialog
      final selectedUser = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _SelectUserDialog(users: users),
      );

      if (selectedUser == null) return;

      // Create or get existing conversation
      final convResponse = await dio.post(
        '/conversations',
        data: {
          'participants': [selectedUser['_id']],
          'isGroup': false,
        },
      );

      if (!mounted) return;

      final conversationId = convResponse.data['id'];
      context.go('/chat/$conversationId');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${_extractErrorMessage(e)}')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await session.clear();
      if (!mounted) return;
      context.go('/login');
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return error.response?.data['error'] ??
            error.response?.data['message'] ??
            'Failed to load data';
      } else if (error.type == DioExceptionType.connectionError) {
        return 'Cannot connect to server. Please check your internet connection.';
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout. Please try again.';
      }
    }
    return 'An unexpected error occurred';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SyncTalk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'profile') {
                context.go('/profile');
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(theme),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewChat,
        icon: const Icon(Icons.add_comment),
        label: const Text('New Chat'),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error Loading Conversations',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text('No Conversations Yet', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Start a new conversation by tapping the button below',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationTile(conversation, theme);
      },
    );
  }

  Widget _buildConversationTile(
    Map<String, dynamic> conversation,
    ThemeData theme,
  ) {
    final myId = _currentUser?['_id'];
    String title = 'Chat';
    String? subtitle;
    String? avatarText;

    // Determine conversation title
    if (conversation['isGroup'] == true) {
      title = conversation['title'] ?? 'Group Chat';
      avatarText = title[0].toUpperCase();
    } else {
      final participants = conversation['participants'] as List?;
      if (participants != null) {
        final others = participants.where((p) => p['_id'] != myId).toList();
        if (others.isNotEmpty) {
          final other = others[0];
          title = other['displayName'] ?? other['email'] ?? 'User';
          avatarText = title[0].toUpperCase();
        }
      }
    }

    // Get last message info
    if (conversation['lastMessage'] != null) {
      subtitle = conversation['lastMessage'];
    }

    // Get timestamp
    String? timeText;
    if (conversation['lastMessageAt'] != null) {
      try {
        final date = DateTime.parse(conversation['lastMessageAt']);
        timeText = timeago.format(date, locale: 'en_short');
      } catch (e) {
        // Ignore date parsing errors
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            avatarText ?? '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)
            : const Text('No messages yet'),
        trailing: timeText != null
            ? Text(
                timeText,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            : null,
        onTap: () {
          context.go('/chat/${conversation['id'] ?? conversation['_id']}');
        },
      ),
    );
  }
}

class _SearchUserDialog extends StatelessWidget {
  final TextEditingController controller;

  const _SearchUserDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Chat'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Search by email or name',
          prefixIcon: Icon(Icons.search),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text.trim());
          },
          child: const Text('Search'),
        ),
      ],
    );
  }
}

class _SelectUserDialog extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const _SelectUserDialog({required this.users});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select User'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final name = user['displayName'] ?? user['email'] ?? 'User';
            return ListTile(
              leading: CircleAvatar(child: Text(name[0].toUpperCase())),
              title: Text(name),
              subtitle: Text(user['email'] ?? ''),
              onTap: () => Navigator.of(context).pop(user),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
