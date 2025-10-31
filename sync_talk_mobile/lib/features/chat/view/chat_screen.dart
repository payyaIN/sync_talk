// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../../../services/sockets.dart';
// import '../../chat/data/chat_repo.dart';
// import '../../../services/session.dart';
// import '../../../services/offline_queue.dart';
// import '../../ai/data/ai_repo.dart';
// import '../../../services/connectivity_service.dart';
// import 'widgets/message_bubble.dart';

// class ChatScreen extends StatefulWidget {
//   final String conversationId;
//   const ChatScreen({super.key, required this.conversationId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   bool aiLoading = false;
//   Future<void> aiSuggest() async {
//     setState(() => aiLoading = true);
//     final ctx = messages.reversed
//         .take(8)
//         .map((m) => (m['content'] ?? '').toString())
//         .where((s) => s.isNotEmpty)
//         .toList();
//     try {
//       final sug = await aiRepo.suggestReply(ctx);
//       controller.text = sug;
//     } catch (_) {}
//     setState(() => aiLoading = false);
//   }

//   final controller = TextEditingController();
//   final searchCtrl = TextEditingController();
//   final List<Map<String, dynamic>> messages = [];
//   IO.Socket? chat;
//   String typingText = '';
//   String? nextCursor;
//   bool loadingMore = false;
//   bool searching = false;

//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   Future<void> init() async {
//     await offlineQueue.init();
//     sockets.joinConversation(widget.conversationId);
//     await loadMore(initial: true);
//     chat = sockets.chat;
//     chat?.on('message:new', (data) {
//       if (data['conversationId'] == widget.conversationId) {
//         setState(() {
//           messages.add({
//             'id': data['id'],
//             'sender': data['sender'],
//             'content': data['content'],
//             'attachments': data['attachments'] ?? [],
//             'createdAt': data['createdAt'],
//             'readBy': [],
//           });
//         });
//       }
//     });
//     chat?.on('typing', (data) {
//       if (data['conversationId'] == widget.conversationId) {
//         setState(() => typingText = '${data['userId']} is typing...');
//         Future.delayed(const Duration(seconds: 1), () {
//           if (mounted) setState(() => typingText = '');
//         });
//       }
//     });
//     chat?.on('message:read', (data) {
//       final i = messages.indexWhere((m) => m['id'] == data['messageId']);
//       if (i >= 0) {
//         final rb = (messages[i]['readBy'] as List?) ?? [];
//         if (!rb.contains(data['userId'])) {
//           rb.add(data['userId']);
//           setState(() => messages[i]['readBy'] = rb);
//         }
//       }
//     });
//   }

//   Future<void> loadMore({bool initial = false}) async {
//     if (loadingMore) return;
//     setState(() => loadingMore = true);
//     final resp = await chatRepo.listMessagesPaginated(
//       widget.conversationId,
//       cursor: initial ? null : nextCursor,
//     );
//     final List items = resp['items'] ?? [];
//     nextCursor = resp['nextCursor'];
//     if (initial) {
//       messages.clear();
//       messages.addAll(items.cast<Map<String, dynamic>>());
//     } else {
//       messages.insertAll(0, items.cast<Map<String, dynamic>>());
//     }
//     setState(() => loadingMore = false);
//   }

//   Future<void> send() async {
//     final text = controller.text.trim();
//     if (text.isEmpty) return;
//     controller.clear();
//     if (!connectivityService.online) {
//       await offlineQueue.enqueue(
//         OutboxItem(widget.conversationId, text, const [], null),
//       );
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Offline: queued message')));
//       return;
//     }
//     try {
//       await chatRepo.sendMessage(widget.conversationId, content: text);
//     } catch (_) {
//       await offlineQueue.enqueue(
//         OutboxItem(widget.conversationId, text, const [], null),
//       );
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Queued (will resend)')));
//     }
//   }

//   Future<void> pickAndUpload() async {
//     final result = await FilePicker.platform.pickFiles();
//     if (result != null && result.files.single.path != null) {
//       final file = File(result.files.single.path!);
//       try {
//         final url = await chatRepo.uploadFile(
//           file.path,
//           result.files.single.name ?? 'file',
//         );
//         await chatRepo.sendMessage(widget.conversationId, attachments: [url]);
//       } catch (_) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Attachment failed')));
//       }
//     }
//   }

//   bool isMine(Map m) =>
//       (m['sender']?.toString() ?? '') == (session.userId ?? '');

//   @override
//   Widget build(BuildContext context) {
//     final list = searching
//         ? messages
//               .where(
//                 (m) => (m['content'] ?? '').toString().toLowerCase().contains(
//                   searchCtrl.text.toLowerCase(),
//                 ),
//               )
//               .toList()
//         : messages;
//     return Scaffold(
//       appBar: AppBar(
//         title: searching
//             ? TextField(
//                 controller: searchCtrl,
//                 autofocus: true,
//                 decoration: const InputDecoration(
//                   hintText: 'Search messages...',
//                 ),
//                 onChanged: (_) => setState(() {}),
//               )
//             : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Chat ${widget.conversationId}'),
//                   if (typingText.isNotEmpty)
//                     Text(
//                       typingText,
//                       style: const TextStyle(fontSize: 12, color: Colors.teal),
//                     ),
//                 ],
//               ),
//         actions: [
//           IconButton(
//             icon: Icon(searching ? Icons.close : Icons.search),
//             onPressed: () {
//               setState(() => searching = !searching);
//               if (!searching) searchCtrl.clear();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (typingText.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(6),
//               child: Text(
//                 typingText,
//                 style: const TextStyle(fontStyle: FontStyle.italic),
//               ),
//             ),
//           Expanded(
//             child: NotificationListener<ScrollNotification>(
//               onNotification: (n) {
//                 if (n.metrics.pixels <= 80 &&
//                     nextCursor != null &&
//                     !loadingMore) {
//                   loadMore();
//                 }
//                 return false;
//               },
//               child: ListView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                 itemCount: list.length,
//                 itemBuilder: (_, i) {
//                   final m = list[i];
//                   final mine = isMine(m);
//                   final prev = i > 0 ? list[i - 1] : null;
//                   final sameSenderAsPrev =
//                       prev != null && prev['sender'] == m['sender'];
//                   final isFirstOfBlock = !sameSenderAsPrev;
//                   final createdAt =
//                       DateTime.tryParse(m['createdAt']?.toString() ?? '') ??
//                       DateTime.now();
//                   final bubble = MessageBubble(
//                     isMine: mine,
//                     text: (m['content'] ?? '').toString(),
//                     attachments: (m['attachments'] as List?) ?? const [],
//                     time: createdAt,
//                     readBy: (m['readBy'] as List?) ?? const [],
//                     isGroup: true,
//                     isFirstOfBlock: isFirstOfBlock,
//                     displayName: mine
//                         ? 'You'
//                         : (m['sender']?.toString() ?? 'User'),
//                   );
//                   return Container(
//                     margin: EdgeInsets.only(
//                       top: isFirstOfBlock ? 8 : 2,
//                       bottom: 2,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: mine
//                           ? MainAxisAlignment.end
//                           : MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [bubble],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 // IconButton(
//                 //   icon: const Icon(Icons.auto_awesome),
//                 //   onPressed: aiSuggest,
//                 // ),
//                 IconButton(
//                   icon: aiLoading
//                       ? const Icon(Icons.hourglass_top)
//                       : const Icon(Icons.auto_awesome),
//                   onPressed: aiLoading ? null : aiSuggest,
//                   tooltip: 'AI Suggest',
//                 ),
//                 IconButton(
//                   icon: aiLoading
//                       ? const Icon(Icons.hourglass_top)
//                       : const Icon(Icons.auto_awesome),
//                   onPressed: aiLoading ? null : aiSuggest,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.attach_file),
//                   onPressed: pickAndUpload,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: controller,
//                     decoration: const InputDecoration(hintText: 'Message'),
//                   ),
//                 ),
//                 IconButton(icon: const Icon(Icons.send), onPressed: send),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../../../core/services/sockets.dart';
// import '../data/chat_repository.dart';
// import '../../../core/services/session.dart';
// import '../../../core/services/offline_queue.dart';
// import '../../ai/data/ai_repo.dart';
// import '../../../core/services/connectivity_service.dart';
// import 'widgets/message_bubble.dart';

// class ChatScreen extends StatefulWidget {
//   final String conversationId;
//   const ChatScreen({super.key, required this.conversationId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
//   // DEBUG: [CHAT] - Core controllers
//   final controller = TextEditingController();
//   final searchCtrl = TextEditingController();
//   final scrollController = ScrollController();
//   final focusNode = FocusNode();

//   // DEBUG: [CHAT] - State variables
//   final List<Map<String, dynamic>> messages = [];
//   IO.Socket? chat;
//   String typingText = '';
//   String? nextCursor;
//   bool loadingMore = false;
//   bool searching = false;
//   bool aiLoading = false;
//   bool isConnected = false;

//   // DEBUG: [ANIMATION] - Animation controllers
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     // DEBUG: [INIT] - Initializing chat screen
//     print(
//       '💬 DEBUG: [CHAT] - Initializing chat screen for: ${widget.conversationId}',
//     );

//     _initAnimations();
//     init();

//     // DEBUG: [SCROLL] - Setup auto-scroll on new messages
//     scrollController.addListener(_onScroll);
//   }

//   /// Initialize animations
//   void _initAnimations() {
//     print('🎬 DEBUG: [ANIMATION] - Setting up chat animations');

//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     _slideController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
//           CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
//         );

//     _fadeController.forward();
//     _slideController.forward();
//   }

//   /// Initialize chat connection and load messages
//   Future<void> init() async {
//     try {
//       print('🔄 DEBUG: [CHAT] - Initializing offline queue');
//       await offlineQueue.init();

//       print(
//         '🔌 DEBUG: [SOCKET] - Joining conversation: ${widget.conversationId}',
//       );
//       sockets.joinConversation(widget.conversationId);

//       print('📥 DEBUG: [CHAT] - Loading initial messages');
//       await loadMore(initial: true);

//       print('🎧 DEBUG: [SOCKET] - Registering event listeners');
//       _registerSocketListeners();

//       setState(() => isConnected = true);
//       print('✅ DEBUG: [CHAT] - Chat initialization complete');
//     } catch (e) {
//       print('❌ DEBUG: [CHAT] - Error during initialization: $e');
//       _showError('Failed to load chat');
//     }
//   }

//   /// Register Socket.IO event listeners
//   void _registerSocketListeners() {
//     chat = sockets.chat;

//     // DEBUG: [SOCKET] - New message event
//     chat?.on('message:new', (data) {
//       print('📨 DEBUG: [SOCKET] - Received new message: ${data['id']}');
//       if (data['conversationId'] == widget.conversationId) {
//         setState(() {
//           messages.add({
//             'id': data['id'],
//             'sender': data['sender'],
//             'content': data['content'],
//             'attachments': data['attachments'] ?? [],
//             'createdAt': data['createdAt'],
//             'readBy': [],
//           });
//         });

//         // DEBUG: [SCROLL] - Auto-scroll to bottom on new message
//         _scrollToBottom();

//         // DEBUG: [SOCKET] - Mark message as read
//         _markAsRead(data['id']);
//       }
//     });

//     // DEBUG: [SOCKET] - Typing indicator event
//     chat?.on('typing', (data) {
//       print('⌨️ DEBUG: [SOCKET] - Typing event from: ${data['userId']}');
//       if (data['conversationId'] == widget.conversationId) {
//         setState(() => typingText = '${data['userId']} is typing...');

//         // DEBUG: [TYPING] - Clear typing indicator after 2 seconds
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) setState(() => typingText = '');
//         });
//       }
//     });

//     // DEBUG: [SOCKET] - Read receipt event
//     chat?.on('message:read', (data) {
//       print('✅ DEBUG: [SOCKET] - Message read by: ${data['userId']}');
//       final i = messages.indexWhere((m) => m['id'] == data['messageId']);
//       if (i >= 0) {
//         final rb = (messages[i]['readBy'] as List?) ?? [];
//         if (!rb.contains(data['userId'])) {
//           rb.add(data['userId']);
//           setState(() => messages[i]['readBy'] = rb);
//         }
//       }
//     });

//     // DEBUG: [SOCKET] - Message deleted event (admin moderation)
//     chat?.on('message:deleted', (data) {
//       print('🗑️ DEBUG: [SOCKET] - Message deleted: ${data['messageId']}');
//       setState(() {
//         messages.removeWhere((m) => m['id'] == data['messageId']);
//       });
//     });
//   }

//   /// Load more messages with pagination
//   Future<void> loadMore({bool initial = false}) async {
//     if (loadingMore) {
//       print('⏸️ DEBUG: [CHAT] - Already loading messages, skipping');
//       return;
//     }

//     setState(() => loadingMore = true);
//     print(
//       '📥 DEBUG: [CHAT] - Loading messages | Initial: $initial | Cursor: $nextCursor',
//     );

//     try {
//       // DEBUG: [API] - Using correct signature: listMessagesPaginated(String convId, {String? cursor, int limit})
//       final resp = await chatRepo.listMessagesPaginated(
//         widget.conversationId,
//         cursor: initial ? null : nextCursor,
//         limit: 30,
//       );

//       print('✅ DEBUG: [CHAT] - Loaded ${resp['items'].length} messages');

//       setState(() {
//         if (initial) {
//           messages.clear();
//         }
//         messages.insertAll(0, List<Map<String, dynamic>>.from(resp['items']));
//         nextCursor = resp['nextCursor'];
//         loadingMore = false;
//       });

//       if (initial) {
//         // DEBUG: [SCROLL] - Scroll to bottom after initial load
//         WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//       }
//     } catch (e) {
//       print('❌ DEBUG: [CHAT] - Error loading messages: $e');
//       setState(() => loadingMore = false);
//       _showError('Failed to load messages');
//     }
//   }

//   /// Send a message
//   Future<void> sendMessage() async {
//     final text = controller.text.trim();
//     if (text.isEmpty) {
//       print('⚠️ DEBUG: [CHAT] - Empty message, not sending');
//       return;
//     }

//     print('📤 DEBUG: [CHAT] - Sending message: $text');
//     controller.clear();

//     try {
//       // DEBUG: [OFFLINE] - Check connectivity first
//       if (!connectivityService.online) {
//         print('🔌 DEBUG: [OFFLINE] - No connection, queueing message');
//         await offlineQueue.enqueue(
//           OutboxItem(widget.conversationId, text, const [], null),
//         );
//         _showError('Offline: message queued for sending');
//         return;
//       }

//       final tempId = DateTime.now().millisecondsSinceEpoch.toString();

//       // DEBUG: [UI] - Optimistic update
//       setState(() {
//         messages.add({
//           'id': tempId,
//           'sender': session.userId,
//           'content': text,
//           'attachments': [],
//           'createdAt': DateTime.now().toIso8601String(),
//           'readBy': [],
//           '_sending': true,
//         });
//       });

//       _scrollToBottom();

//       // DEBUG: [API] - Send message using correct signature: sendMessage(String convId, {String content, List<String> attachments, String? parentMessage})
//       final messageId = await chatRepo.sendMessage(
//         widget.conversationId,
//         content: text,
//         attachments: const [],
//       );

//       print('✅ DEBUG: [CHAT] - Message sent successfully: $messageId');

//       // DEBUG: [UI] - Update temp message with real ID
//       setState(() {
//         final index = messages.indexWhere((m) => m['id'] == tempId);
//         if (index >= 0) {
//           messages[index] = {
//             ...messages[index],
//             'id': messageId,
//             '_sending': false,
//           };
//         }
//       });
//     } catch (e) {
//       print('❌ DEBUG: [CHAT] - Error sending message: $e');

//       // DEBUG: [OFFLINE] - Add to retry queue using OutboxItem object
//       await offlineQueue.enqueue(
//         OutboxItem(widget.conversationId, text, const [], null),
//       );

//       _showError('Message will be sent when online');
//     }
//   }

//   /// AI smart reply suggestion
//   Future<void> aiSuggest() async {
//     print('🤖 DEBUG: [AI] - Requesting smart reply suggestion');
//     setState(() => aiLoading = true);

//     // DEBUG: [AI] - Get conversation context (last 8 messages)
//     final ctx = messages.reversed
//         .take(8)
//         .map((m) => (m['content'] ?? '').toString())
//         .where((s) => s.isNotEmpty)
//         .toList();

//     print('🤖 DEBUG: [AI] - Context messages: ${ctx.length}');

//     try {
//       final sug = await aiRepo.suggestReply(ctx);
//       print('✅ DEBUG: [AI] - Suggestion received: $sug');
//       controller.text = sug;

//       // DEBUG: [UI] - Show feedback
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('💡 AI suggestion applied!'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       print('❌ DEBUG: [AI] - Error getting suggestion: $e');
//       _showError('AI suggestion unavailable');
//     } finally {
//       setState(() => aiLoading = false);
//     }
//   }

//   /// Upload and attach file
//   Future<void> attachFile() async {
//     print('📎 DEBUG: [FILE] - Opening file picker');

//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.any,
//         allowMultiple: false,
//       );

//       if (result == null || result.files.isEmpty) {
//         print('⚠️ DEBUG: [FILE] - No file selected');
//         return;
//       }

//       final file = result.files.first;
//       if (file.path == null) {
//         print('❌ DEBUG: [FILE] - File path is null');
//         return;
//       }

//       print('📎 DEBUG: [FILE] - Selected file: ${file.name}');

//       // DEBUG: [UI] - Show uploading feedback
//       _showError('Uploading ${file.name}...');

//       // DEBUG: [API] - Upload file
//       final url = await chatRepo.uploadFile(file.path!, file.name);
//       print('✅ DEBUG: [FILE] - File uploaded: $url');

//       // DEBUG: [API] - Send message with attachment
//       await chatRepo.sendMessage(
//         widget.conversationId,
//         content: '',
//         attachments: [url],
//       );

//       print('✅ DEBUG: [FILE] - Attachment message sent');
//       _showError('File sent successfully');
//     } catch (e) {
//       print('❌ DEBUG: [FILE] - Error attaching file: $e');
//       _showError('Failed to attach file');
//     }
//   }

//   /// Mark message as read (using correct method name: markRead)
//   Future<void> _markAsRead(String messageId) async {
//     try {
//       print('✓ DEBUG: [CHAT] - Marking message as read: $messageId');
//       await chatRepo.markRead(
//         messageId,
//       ); // Correct method name: markRead (not markAsRead)
//     } catch (e) {
//       print('❌ DEBUG: [CHAT] - Error marking as read: $e');
//     }
//   }

//   /// Scroll to bottom of chat
//   void _scrollToBottom() {
//     if (!scrollController.hasClients) return;

//     print('⬇️ DEBUG: [SCROLL] - Scrolling to bottom');
//     scrollController.animateTo(
//       scrollController.position.maxScrollExtent,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   /// Handle scroll events for load more
//   void _onScroll() {
//     if (scrollController.position.pixels <= 100 &&
//         nextCursor != null &&
//         !loadingMore) {
//       print('⬆️ DEBUG: [SCROLL] - Near top, loading more messages');
//       loadMore();
//     }
//   }

//   /// Send typing indicator
//   void _sendTypingIndicator() {
//     print('⌨️ DEBUG: [SOCKET] - Sending typing indicator');
//     chat?.emit('typing', {
//       'conversationId': widget.conversationId,
//       'userId': session.userId,
//     });
//   }

//   /// Show error snackbar
//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   void dispose() {
//     print('🧹 DEBUG: [CHAT] - Disposing chat screen');
//     controller.dispose();
//     searchCtrl.dispose();
//     scrollController.dispose();
//     focusNode.dispose();
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       // DEBUG: [UI] - Modern app bar
//       appBar: AppBar(
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Conversation', style: theme.textTheme.titleLarge),
//             if (typingText.isNotEmpty)
//               Text(
//                 typingText,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: theme.colorScheme.primary,
//                   fontStyle: FontStyle.italic,
//                 ),
//               )
//             else if (isConnected)
//               Text(
//                 'Online',
//                 style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
//               ),
//           ],
//         ),
//         actions: [
//           // DEBUG: [UI] - Video call button
//           IconButton(
//             icon: const Icon(Icons.videocam),
//             tooltip: 'Start video call',
//             onPressed: () {
//               print('📹 DEBUG: [NAVIGATION] - Starting video call');
//               // Navigate to call screen
//               // Navigator.pushNamed(context, '/call/${widget.conversationId}');
//             },
//           ),

//           // DEBUG: [UI] - Search button
//           IconButton(
//             icon: const Icon(Icons.search),
//             tooltip: 'Search messages',
//             onPressed: () {
//               print('🔍 DEBUG: [CHAT] - Opening message search');
//               setState(() => searching = !searching);
//             },
//           ),

//           // DEBUG: [UI] - More options
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               print('⚙️ DEBUG: [MENU] - Selected: $value');
//               // Handle menu actions
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'mute',
//                 child: Text('Mute notifications'),
//               ),
//               const PopupMenuItem(value: 'clear', child: Text('Clear chat')),
//             ],
//           ),
//         ],
//       ),

//       body: Column(
//         children: [
//           // DEBUG: [UI] - Search bar (if active)
//           if (searching)
//             Container(
//               padding: const EdgeInsets.all(8),
//               color: theme.colorScheme.surface,
//               child: TextField(
//                 controller: searchCtrl,
//                 decoration: InputDecoration(
//                   hintText: 'Search messages...',
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => setState(() => searching = false),
//                   ),
//                 ),
//                 onChanged: (query) {
//                   print('🔍 DEBUG: [SEARCH] - Query: $query');
//                   // Implement local search filtering
//                   setState(() {});
//                 },
//               ),
//             ),

//           // DEBUG: [UI] - Message list
//           Expanded(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: messages.isEmpty
//                     ? _buildEmptyState()
//                     : ListView.builder(
//                         controller: scrollController,
//                         padding: const EdgeInsets.all(16),
//                         itemCount: messages.length + (loadingMore ? 1 : 0),
//                         itemBuilder: (context, index) {
//                           if (index == 0 && loadingMore) {
//                             return const Center(
//                               child: Padding(
//                                 padding: EdgeInsets.all(16),
//                                 child: CircularProgressIndicator(),
//                               ),
//                             );
//                           }

//                           final messageIndex = loadingMore ? index - 1 : index;
//                           final message = messages[messageIndex];
//                           final isMine = message['sender'] == session.userId;

//                           // Filter messages if searching
//                           if (searching && searchCtrl.text.isNotEmpty) {
//                             final content = (message['content'] ?? '')
//                                 .toString()
//                                 .toLowerCase();
//                             if (!content.contains(
//                               searchCtrl.text.toLowerCase(),
//                             )) {
//                               return const SizedBox.shrink();
//                             }
//                           }

//                           return MessageBubble(
//                             isMine: isMine,
//                             text: message['content'] ?? '',
//                             attachments: message['attachments'] ?? [],
//                             time: DateTime.parse(message['createdAt']),
//                             readBy: message['readBy'] ?? [],
//                             isSending: message['_sending'] == true,
//                           );
//                         },
//                       ),
//               ),
//             ),
//           ),

//           // DEBUG: [UI] - Typing indicator
//           if (typingText.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.surfaceVariant,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text('...', style: theme.textTheme.bodyMedium),
//                         const SizedBox(width: 4),
//                         Text('typing', style: theme.textTheme.bodySmall),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           // DEBUG: [UI] - Input area
//           _buildInputArea(theme),
//         ],
//       ),
//     );
//   }

//   /// Build input area
//   Widget _buildInputArea(ThemeData theme) {
//     return Container(
//       decoration: BoxDecoration(
//         color: theme.scaffoldBackgroundColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       child: SafeArea(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             // DEBUG: [UI] - Attach file button
//             IconButton(
//               icon: Icon(Icons.attach_file, color: theme.colorScheme.primary),
//               tooltip: 'Attach file',
//               onPressed: () {
//                 print('📎 DEBUG: [INPUT] - Attach button pressed');
//                 attachFile();
//               },
//             ),

//             // DEBUG: [UI] - Text input field
//             Expanded(
//               child: Container(
//                 constraints: const BoxConstraints(
//                   minHeight: 40,
//                   maxHeight: 120,
//                 ),
//                 decoration: BoxDecoration(
//                   color: theme.brightness == Brightness.dark
//                       ? Colors.grey.shade800
//                       : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: controller,
//                         focusNode: focusNode,
//                         maxLines: null,
//                         textCapitalization: TextCapitalization.sentences,
//                         decoration: InputDecoration(
//                           hintText: 'Message',
//                           hintStyle: TextStyle(
//                             color: theme.textTheme.bodySmall?.color
//                                 ?.withOpacity(0.5),
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 10,
//                           ),
//                         ),
//                         onChanged: (_) {
//                           _sendTypingIndicator();
//                           setState(() {});
//                         },
//                         onSubmitted: (_) {
//                           if (controller.text.trim().isNotEmpty) {
//                             print('📤 DEBUG: [INPUT] - Submit via Enter key');
//                             sendMessage();
//                           }
//                         },
//                       ),
//                     ),

//                     // DEBUG: [UI] - AI suggest button (show when empty)
//                     if (controller.text.trim().isEmpty)
//                       IconButton(
//                         icon: aiLoading
//                             ? SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation(
//                                     theme.colorScheme.primary,
//                                   ),
//                                 ),
//                               )
//                             : Icon(
//                                 Icons.auto_awesome,
//                                 color: theme.colorScheme.tertiary,
//                                 size: 22,
//                               ),
//                         tooltip: 'AI smart reply',
//                         onPressed: aiLoading
//                             ? null
//                             : () {
//                                 print(
//                                   '🤖 DEBUG: [INPUT] - AI suggest button pressed',
//                                 );
//                                 aiSuggest();
//                               },
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(width: 8),

//             // DEBUG: [UI] - Send button (animated)
//             FloatingActionButton(
//               mini: true,
//               elevation: controller.text.trim().isNotEmpty ? 2 : 0,
//               backgroundColor: controller.text.trim().isNotEmpty
//                   ? theme.colorScheme.primary
//                   : Colors.grey.shade300,
//               onPressed: controller.text.trim().isNotEmpty
//                   ? () {
//                       print('📤 DEBUG: [INPUT] - Send button pressed');
//                       sendMessage();
//                     }
//                   : null,
//               child: Icon(
//                 Icons.send,
//                 size: 20,
//                 color: controller.text.trim().isNotEmpty
//                     ? Colors.white
//                     : Colors.grey.shade500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Empty state widget
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.chat_bubble_outline,
//             size: 80,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No messages yet',
//             style: Theme.of(
//               context,
//             ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Start the conversation!',
//             style: Theme.of(
//               context,
//             ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
//           ),
//         ],
//       ),
//     );
//   }
// }
