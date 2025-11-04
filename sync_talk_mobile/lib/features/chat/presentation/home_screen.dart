// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/socket_service.dart';
// import '../viewmodel/chat_viewmodel.dart';
// import 'chat_screen.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     SocketService.connect();
//     ref.read(chatViewModelProvider).loadConversations();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chats = ref.watch(chatListProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text("SyncTalk")),
//       body: ListView.builder(
//         itemCount: chats.length,
//         itemBuilder: (_, i) {
//           final c = chats[i];
//           return ListTile(
//             title: Text(c["name"] ?? "Chat"),
//             subtitle: Text(c["lastMessage"] ?? "No messages yet"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => ChatScreen(conversation: c)),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
