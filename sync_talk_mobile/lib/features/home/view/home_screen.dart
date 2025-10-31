// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sync_talk_mobile/src/services/session.dart';
// import 'package:sync_talk_mobile/src/services/sockets.dart';
// import '../../chat/data/chat_repo.dart';
// import '../../../services/api.dart';
// import 'dart:async';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<dynamic> convos = [];
//   List<dynamic> filtered = [];
//   bool loading = true;
//   final searchCtrl = TextEditingController();
//   Timer? _debounce;
//   List<dynamic> userResults = [];

//   @override
//   void initState() {
//     super.initState();
//     load();
//     searchCtrl.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     searchCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> load() async {
//     final list = await chatRepo.listConversations();
//     setState(() {
//       convos = list;
//       filtered = list;
//       loading = false;
//     });
//   }

//   void _onSearchChanged() {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () async {
//       final q = searchCtrl.text.trim().toLowerCase();
//       if (q.isEmpty) {
//         setState(() {
//           filtered = convos;
//           userResults = [];
//         });
//         return;
//       }
//       final loc = convos
//           .where(
//             (c) => (c['title']?.toString().toLowerCase() ?? '').contains(q),
//           )
//           .toList();
//       try {
//         final resp = await dio.get(
//           '/api/users/search',
//           queryParameters: {'q': q},
//         );
//         setState(() {
//           filtered = loc;
//           userResults = (resp.data as List);
//         });
//       } catch (_) {
//         setState(() {
//           filtered = loc;
//           userResults = [];
//         });
//       }
//     });
//   }

//   void _startChatWithUser(dynamic u) {
//     context.push('/chat/${u['id']}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('SyncTalk')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: TextField(
//               controller: searchCtrl,
//               decoration: const InputDecoration(
//                 prefixIcon: Icon(Icons.search),
//                 hintText: 'Search conversations or users...',
//               ),
//             ),
//           ),
//           if (loading)
//             const Expanded(child: Center(child: CircularProgressIndicator()))
//           else
//             Expanded(
//               child: StreamBuilder<Set<String>>(
//                 stream: sockets.onlineStream,
//                 builder: (context, snapshot) {
//                   final online = snapshot.data ?? const {};
//                   return ListView(
//                     children: [
//                       if (userResults.isNotEmpty)
//                         const Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 8,
//                           ),
//                           child: Text(
//                             'Users',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ...userResults
//                           .take(8)
//                           .map(
//                             (u) => ListTile(
//                               leading: const CircleAvatar(
//                                 child: Icon(Icons.person),
//                               ),
//                               title: Text(u['displayName'] ?? 'User'),
//                               subtitle: Text(u['email'] ?? ''),
//                               trailing: const Icon(Icons.chat),
//                               onTap: () => _startChatWithUser(u),
//                             ),
//                           ),
//                       const Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         child: Text(
//                           'Conversations',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       ...filtered.map(
//                         (c) => ListTile(
//                           leading: _presenceDot(c),
//                           title: Text(c['title']?.toString() ?? 'Conversation'),
//                           subtitle: Text(
//                             'Members: ${c['participants'].length}',
//                           ),
//                           onTap: () => context.push('/chat/${c['id']}'),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.video_call),
//                             onPressed: () => context.push('/call/${c['id']}'),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => context.push('/chat/new'),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// Widget _presenceDot(dynamic c) {
//   try {
//     final participants = (c['participants'] as List)
//         .map((e) => e.toString())
//         .toList();
//     // listen once; rebuilds when stream emits via StreamBuilder wrapper in a parent would be ideal, for now keep simple snapshot
//   } catch (_) {}
//   final me = session.userId ?? '';
//   final online = (sockets.onlineStream is Stream) ? null : null;
//   return Container(
//     width: 12,
//     height: 12,
//     decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
//   );
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/api.dart'; // DEBUG: [IMPORT] - Import dio from api service

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   List<Map<String, dynamic>> conversations = [];
//   bool loading = true;
//   final searchController = TextEditingController();
//   bool searching = false;

//   @override
//   void initState() {
//     super.initState();
//     // DEBUG: [HOME] - Initialize home screen
//     print('🏠 DEBUG: [HOME] - Initializing home screen');
//     _loadConversations();
//   }

//   Future<void> _loadConversations() async {
//     print('📥 DEBUG: [HOME] - Loading conversations');
//     setState(() => loading = true);

//     try {
//       // DEBUG: [API] - Using dio from api service (correct import)
//       final resp = await dio.get('/api/conversations');
//       print(
//         '✅ DEBUG: [HOME] - Loaded ${(resp.data as List).length} conversations',
//       );

//       setState(() {
//         conversations = List<Map<String, dynamic>>.from(resp.data as List);
//         loading = false;
//       });
//     } catch (e) {
//       print('❌ DEBUG: [HOME] - Error loading conversations: $e');
//       setState(() => loading = false);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load conversations: $e')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     print('🧹 DEBUG: [HOME] - Disposing home screen');
//     searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       // DEBUG: [UI] - Modern app bar with gradient
//       appBar: AppBar(
//         title: searching
//             ? TextField(
//                 controller: searchController,
//                 autofocus: true,
//                 decoration: InputDecoration(
//                   hintText: 'Search conversations...',
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(
//                     color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
//                   ),
//                 ),
//                 onChanged: (query) {
//                   print('🔍 DEBUG: [SEARCH] - Query: $query');
//                   // TODO: Implement search filtering
//                   setState(() {});
//                 },
//               )
//             : Text(
//                 'SyncTalk',
//                 style: theme.textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//         actions: [
//           // DEBUG: [UI] - Search toggle button
//           IconButton(
//             icon: Icon(searching ? Icons.close : Icons.search),
//             tooltip: searching ? 'Close search' : 'Search',
//             onPressed: () {
//               print('🔍 DEBUG: [HOME] - Toggle search: ${!searching}');
//               setState(() {
//                 searching = !searching;
//                 if (!searching) {
//                   searchController.clear();
//                 }
//               });
//             },
//           ),

//           // DEBUG: [UI] - More options menu
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               print('⚙️ DEBUG: [MENU] - Selected: $value');

//               switch (value) {
//                 case 'profile':
//                   print('👤 DEBUG: [NAVIGATION] - Navigate to profile');
//                   // Navigator.pushNamed(context, '/profile');
//                   break;
//                 case 'settings':
//                   print('⚙️ DEBUG: [NAVIGATION] - Navigate to settings');
//                   // Open settings
//                   break;
//                 case 'logout':
//                   print('🚪 DEBUG: [AUTH] - Logout requested');
//                   // Handle logout
//                   break;
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'profile',
//                 child: Row(
//                   children: [
//                     Icon(Icons.person),
//                     SizedBox(width: 12),
//                     Text('Profile'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'settings',
//                 child: Row(
//                   children: [
//                     Icon(Icons.settings),
//                     SizedBox(width: 12),
//                     Text('Settings'),
//                   ],
//                 ),
//               ),
//               const PopupMenuDivider(),
//               const PopupMenuItem(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout, color: Colors.red),
//                     SizedBox(width: 12),
//                     Text('Logout', style: TextStyle(color: Colors.red)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),

//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : conversations.isEmpty
//           ? _buildEmptyState()
//           : RefreshIndicator(
//               onRefresh: _loadConversations,
//               child: ListView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 itemCount: conversations.length,
//                 itemBuilder: (context, index) {
//                   final conv = conversations[index];

//                   // Filter conversations if searching
//                   if (searching && searchController.text.isNotEmpty) {
//                     final title = (conv['title'] ?? '')
//                         .toString()
//                         .toLowerCase();
//                     final lastMessage = (conv['lastMessage'] ?? '')
//                         .toString()
//                         .toLowerCase();
//                     final query = searchController.text.toLowerCase();

//                     if (!title.contains(query) &&
//                         !lastMessage.contains(query)) {
//                       return const SizedBox.shrink();
//                     }
//                   }

//                   return _ConversationCard(
//                     conversation: conv,
//                     onTap: () {
//                       final convId = conv['id'] ?? conv['_id'];
//                       print('💬 DEBUG: [HOME] - Opening conversation: $convId');
//                       // Navigator.pushNamed(context, '/chat/$convId');
//                     },
//                   );
//                 },
//               ),
//             ),

//       // DEBUG: [UI] - Floating action button with menu
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           print('➕ DEBUG: [HOME] - New conversation button pressed');
//           _showNewConversationDialog();
//         },
//         tooltip: 'New conversation',
//         child: const Icon(Icons.edit),
//       ),
//     );
//   }

//   /// Empty state widget
//   Widget _buildEmptyState() {
//     final theme = Theme.of(context);

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.chat_bubble_outline,
//             size: 100,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No conversations yet',
//             style: theme.textTheme.headlineSmall?.copyWith(
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Start a new conversation to begin chatting',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: Colors.grey.shade500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           ElevatedButton.icon(
//             onPressed: _showNewConversationDialog,
//             icon: const Icon(Icons.add),
//             label: const Text('Start Conversation'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Show new conversation dialog
//   void _showNewConversationDialog() {
//     print('📝 DEBUG: [HOME] - Showing new conversation dialog');

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('New Conversation'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               decoration: const InputDecoration(
//                 labelText: 'Search users',
//                 prefixIcon: Icon(Icons.search),
//               ),
//               onChanged: (query) {
//                 print('🔍 DEBUG: [HOME] - User search: $query');
//                 // TODO: Implement user search
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               print('❌ DEBUG: [HOME] - Dialog cancelled');
//               Navigator.pop(context);
//             },
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// 📇 Conversation Card Widget
// class _ConversationCard extends StatelessWidget {
//   final Map<String, dynamic> conversation;
//   final VoidCallback onTap;

//   const _ConversationCard({required this.conversation, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final title = conversation['title'] ?? 'Unknown';
//     final lastMessage = conversation['lastMessage'] ?? '';
//     final lastMessageAt = conversation['lastMessageAt'];
//     final unreadCount = conversation['unreadCount'] ?? 0;
//     final isOnline = conversation['isOnline'] ?? false;

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               // DEBUG: [UI] - Avatar with online indicator
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 28,
//                     backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//                     child: Text(
//                       title.isNotEmpty ? title[0].toUpperCase() : '?',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                         color: theme.colorScheme.primary,
//                       ),
//                     ),
//                   ),
//                   if (isOnline)
//                     Positioned(
//                       right: 0,
//                       bottom: 0,
//                       child: Container(
//                         width: 14,
//                         height: 14,
//                         decoration: BoxDecoration(
//                           color: Colors.green,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: theme.cardColor, width: 2),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(width: 12),

//               // DEBUG: [UI] - Conversation info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             title,
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: unreadCount > 0
//                                   ? FontWeight.w700
//                                   : FontWeight.w600,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         if (lastMessageAt != null)
//                           Text(
//                             _formatTime(lastMessageAt),
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.textTheme.bodySmall?.color
//                                   ?.withOpacity(0.6),
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             lastMessage,
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: unreadCount > 0
//                                   ? theme.textTheme.bodyMedium?.color
//                                   : theme.textTheme.bodyMedium?.color
//                                         ?.withOpacity(0.7),
//                               fontWeight: unreadCount > 0
//                                   ? FontWeight.w600
//                                   : FontWeight.w400,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         if (unreadCount > 0)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: theme.colorScheme.primary,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               unreadCount > 99 ? '99+' : unreadCount.toString(),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Format timestamp to relative time
//   String _formatTime(dynamic timestamp) {
//     try {
//       final DateTime time = timestamp is DateTime
//           ? timestamp
//           : DateTime.parse(timestamp.toString());

//       final now = DateTime.now();
//       final difference = now.difference(time);

//       if (difference.inMinutes < 1) {
//         return 'now';
//       } else if (difference.inHours < 1) {
//         return '${difference.inMinutes}m';
//       } else if (difference.inDays < 1) {
//         return '${difference.inHours}h';
//       } else if (difference.inDays < 7) {
//         return '${difference.inDays}d';
//       } else {
//         return '${time.month}/${time.day}';
//       }
//     } catch (e) {
//       print('❌ DEBUG: [HOME] - Error formatting time: $e');
//       return '';
//     }
//   }
// }
