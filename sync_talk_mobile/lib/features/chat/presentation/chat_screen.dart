// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/dio_client.dart';
// import '../../../core/services/socket_service.dart';
// import '../../../core/utils/date_helper.dart';
// import '../../auth/viewmodel/auth_providers.dart';

// class ChatScreen extends ConsumerStatefulWidget {
//   final String conversationId;
//   const ChatScreen({super.key, required this.conversationId});

//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   List messages = [];
//   Map chatInfo = {};
//   bool loading = true;
//   final msgCtrl = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     loadChat();
//   }

//   Future<void> loadChat() async {
//     try {
//       // Load chat info
//       final resChat = await ApiClient.dio.get('/groups/${widget.conversationId}')
//           .catchError((_) async => await ApiClient.dio.get('/conversations'));
//       chatInfo = resChat.data['data'] ?? {};

//       // Load messages
//       final resMsg = await ApiClient.dio.get('/messages/${widget.conversationId}');
//       messages = resMsg.data['data'];

//       final myId = ref.read(currentUserIdProvider);
//       SocketService.join(widget.conversationId);
//       SocketService.onMessage((m) {
//         if (mounted && m['conversationId'] == widget.conversationId) {
//           setState(() => messages.add(m));
//         }
//       });

//       SocketService.seen(widget.conversationId);

//       setState(() => loading = false);
//     } catch (e) {
//       setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final myId = ref.watch(currentUserIdProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(chatInfo['isGroup'] == true
//             ? (chatInfo['groupName'] ?? "Group Chat")
//             : "Chat"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(8),
//                     itemCount: messages.length,
//                     itemBuilder: (_, i) {
//                       final m = messages[i];
//                       final isMine = m["sender"] == myId;

//                       return Align(
//                         alignment:
//                             isMine ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: isMine
//                                 ? Colors.blue.shade200
//                                 : Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(m["message"] ?? "",
//                                   style: const TextStyle(fontSize: 15)),
//                               const SizedBox(height: 5),
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     formatTime(DateTime.parse(m["createdAt"])),
//                                     style: const TextStyle(fontSize: 11),
//                                   ),
//                                   const SizedBox(width: 5),
//                                   Icon(
//                                     m['status'] == 'seen'
//                                         ? Icons.done_all
//                                         : Icons.check,
//                                     size: 16,
//                                     color: m['status'] == 'seen'
//                                         ? Colors.blue
//                                         : Colors.black54,
//                                   )
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//           SafeArea(
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: msgCtrl,
//                       decoration:
//                           const InputDecoration(hintText: "Type a message..."),
//                       onSubmitted: (_) => sendMessage(),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: sendMessage,
//                   )
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   void sendMessage() {
//     final text = msgCtrl.text.trim();
//     if (text.isEmpty) return;
//     SocketService.send(widget.conversationId, text);
//     msgCtrl.clear();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/dio_client.dart';
// import '../../../core/services/socket_service.dart';
// import '../../../core/widgets/chat_header.dart';
// import '../../auth/viewmodel/auth_providers.dart';
// import 'messages_list.dart';
// import 'chat_input.dart';

// class ChatScreen extends ConsumerStatefulWidget {
//   final String conversationId;
//   const ChatScreen({super.key, required this.conversationId});

//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   List messages = [];
//   Map chatInfo = {};
//   bool loading = true;
//   bool isTyping = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadChat();
//   }

//   Future<void> _loadChat() async {
//     try {
//       final info = await ApiClient.dio
//           .get('/conversations/${widget.conversationId}')
//           .catchError((_) async {
//         return await ApiClient.dio.get('/groups/${widget.conversationId}');
//       });

//       chatInfo = info.data['data'] ?? {};

//       final res = await ApiClient.dio.get('/messages/${widget.conversationId}');
//       messages = res.data['data'];

//       SocketService.join(widget.conversationId);
//       SocketService.onMessage((m) {
//         if (mounted && m['conversationId'] == widget.conversationId) {
//           setState(() => messages.add(m));
//         }
//       });
//       SocketService.onTyping((room) {
//         if (mounted && room == widget.conversationId) {
//           setState(() => isTyping = true);
//         }
//       });
//       SocketService.onStopTyping((room) {
//         if (mounted && room == widget.conversationId) {
//           setState(() => isTyping = false);
//         }
//       });

//       setState(() => loading = false);
//     } catch (e) {
//       loading = false;
//     }
//   }

//   void _sendMessage(String text) {
//     SocketService.send(widget.conversationId, text);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final myId = ref.watch(currentUserIdProvider);

//     String title = chatInfo['isGroup'] == true
//         ? (chatInfo['groupName'] ?? "Group Chat")
//         : "Chat";

//     return Scaffold(
//       appBar: ChatHeader(title: title),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   child: MessagesList(
//                     messages: messages,
//                     myId: myId!,
//                     isTyping: isTyping,
//                   ),
//                 ),
//                 ChatInput(
//                   roomId: widget.conversationId,
//                   onSend: _sendMessage,
//                 ),
//               ],
//             ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/dio_client.dart';
// import '../../../core/services/socket_service.dart';
// import '../../../core/widgets/chat_header.dart';
// import '../../auth/viewmodel/auth_providers.dart';
// import 'messages_list.dart';
// import 'chat_input.dart';
// import 'message_action_sheet.dart';
// import 'reaction_bar.dart';

// class ChatScreen extends ConsumerStatefulWidget {
//   final String conversationId;
//   const ChatScreen({super.key, required this.conversationId});

//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   List messages = [];
//   Map chatInfo = {};
//   bool loading = true;
//   bool isTyping = false;
//   String? replyText;
//   int? replyIndex;

//   @override
//   void initState() {
//     super.initState();
//     _loadChat();
//   }

//   Future<void> _loadChat() async {
//     try {
//       final info = await ApiClient.dio.get('/conversations/${widget.conversationId}');
//       chatInfo = info.data['data'] ?? {};

//       final res = await ApiClient.dio.get('/messages/${widget.conversationId}');
//       messages = res.data['data'];

//       SocketService.join(widget.conversationId);
//       SocketService.onMessage((m) {
//         if (mounted && m['conversationId'] == widget.conversationId) {
//           setState(() => messages.add(m));
//         }
//       });
//       SocketService.onTyping((room) {
//         if (mounted && room == widget.conversationId) {
//           setState(() => isTyping = true);
//         }
//       });
//       SocketService.onStopTyping((room) {
//         if (mounted && room == widget.conversationId) {
//           setState(() => isTyping = false);
//         }
//       });

//       setState(() => loading = false);
//     } catch (e) {
//       loading = false;
//     }
//   }

//   void _sendMessage(String text) {
//     SocketService.send(widget.conversationId, text);
//   }

//   void _onMessageLongPress(int index) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => MessageActionSheet(
//         onReply: () {
//           setState(() {
//             replyText = messages[index]['message'];
//             replyIndex = index;
//           });
//           Navigator.pop(context);
//         },
//         onCopy: () {
//           Navigator.pop(context);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Message copied")),
//           );
//         },
//         onDelete: () {
//           setState(() => messages.removeAt(index));
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   void _addReaction(int index) {
//     showDialog(
//       context: context,
//       builder: (_) => Center(
//         child: ReactionBar(
//           onReact: (emoji) {
//             setState(() {
//               messages[index]['reactions'] =
//                   (messages[index]['reactions'] ?? [])..add(emoji);
//             });
//             Navigator.pop(context);
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final myId = ref.watch(currentUserIdProvider);

//     String title = chatInfo['isGroup'] == true
//         ? (chatInfo['groupName'] ?? "Group Chat")
//         : "Chat";

//     return Scaffold(
//       appBar: ChatHeader(title: title),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     // Tap anywhere to close reply mode
//                     onTap: () => setState(() => replyText = null),
//                     child: MessagesList(
//                       messages: messages,
//                       myId: myId!,
//                       isTyping: isTyping,
//                     ),
//                   ),
//                 ),
//                 ChatInput(
//                   roomId: widget.conversationId,
//                   onSend: _sendMessage,
//                   replyText: replyText,
//                   onCancelReply: () {
//                     setState(() => replyText = null);
//                   },
//                 ),
//               ],
//             ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/services/dio_client.dart';
// import '../../../core/services/socket_service.dart';
// import '../../../core/widgets/chat_header.dart';
// import '../../auth/viewmodel/auth_providers.dart';
// import 'messages_list.dart';
// import 'chat_input.dart';
// import 'message_action_sheet.dart';
// import 'reaction_bar.dart';
// import 'file_attachment_tile.dart';
// import 'image_preview.dart';

// class ChatScreen extends ConsumerStatefulWidget {
//   final String conversationId;
//   const ChatScreen({super.key, required this.conversationId});

//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   List messages = [];
//   Map chatInfo = {};
//   bool loading = true;
//   bool isTyping = false;
//   String? replyText;
//   int? replyIndex;

//   @override
//   void initState() {
//     super.initState();
//     _loadChat();
//   }

//   Future<void> _loadChat() async {
//     try {
//       final info = await ApiClient.dio.get('/conversations/${widget.conversationId}');
//       chatInfo = info.data['data'] ?? {};

//       final res = await ApiClient.dio.get('/messages/${widget.conversationId}');
//       messages = res.data['data'];

//       SocketService.join(widget.conversationId);
//       SocketService.onMessage((m) {
//         if (mounted && m['conversationId'] == widget.conversationId) {
//           setState(() => messages.add(m));
//         }
//       });
//       SocketService.onTyping((room) {
//         if (mounted && room == widget.conversationId) {
//           setState(() => isTyping = true);
//         }
//       });
//       SocketService.onStopTyping((room) {
//         if (mounted && room == widget.conversationId) {
//           setState(() => isTyping = false);
//         }
//       });

//       setState(() => loading = false);
//     } catch (e) {
//       loading = false;
//     }
//   }

//   Future<void> _sendAttachment(String path, String type) async {
//     setState(() {
//       messages.add({
//         "message": "Uploading...",
//         "sender": ref.read(currentUserIdProvider),
//         "status": "uploading",
//         "type": type,
//         "localPath": path
//       });
//     });

//     try {
//       // Real upload logic will go here (Cloudinary or Files API)
//       // TODO: Replace with real upload API when Cloud keys are added
//       // For now, simulate success instantly:
//       await Future.delayed(const Duration(seconds: 1));
//       final uploadedUrl = path; // temp fallback for UI test

//       setState(() {
//         messages.last["message"] = uploadedUrl;
//         messages.last["status"] = "sent";
//       });

//       SocketService.send(widget.conversationId, uploadedUrl);
//     } catch (e) {
//       setState(() {
//         messages.last["status"] = "failed";
//       });
//     }
//   }

//   void _sendMessage(String text) {
//     SocketService.send(widget.conversationId, text);
//   }

//   void _onMessageLongPress(int index) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => MessageActionSheet(
//         onReply: () {
//           setState(() {
//             replyText = messages[index]['message'];
//             replyIndex = index;
//           });
//           Navigator.pop(context);
//         },
//         onCopy: () {
//           Navigator.pop(context);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Message copied")),
//           );
//         },
//         onDelete: () {
//           setState(() => messages.removeAt(index));
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   void _addReaction(int index) {
//     showDialog(
//       context: context,
//       builder: (_) => Center(
//         child: ReactionBar(
//           onReact: (emoji) {
//             setState(() {
//               messages[index]['reactions'] =
//                   (messages[index]['reactions'] ?? [])..add(emoji);
//             });
//             Navigator.pop(context);
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final myId = ref.watch(currentUserIdProvider);

//     return Scaffold(
//       appBar: ChatHeader(title: chatInfo['groupName'] ?? "Chat"),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (_, i) {
//                 final msg = messages[i];
//                 final isMine = msg["sender"] == myId;

//                 // Attachments
//                 if (msg["type"] == "image") {
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ImagePreview(imageUrl: msg["message"]),
//                         ),
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Image.file(File(msg["localPath"] ?? ""), height: 200),
//                     ),
//                   );
//                 } else if (msg["type"] == "file") {
//                   final fileName = msg["message"].split('/').last;
//                   return FileAttachmentTile(
//                     fileName: fileName,
//                     fileUrl: msg["message"],
//                     isMine: isMine,
//                   );
//                 }

//                 // Text Bubble
//                 return GestureDetector(
//                   onLongPress: () => _onMessageLongPress(i),
//                   onDoubleTap: () => _addReaction(i),
//                   child: MessagesList(
//                     messages: messages,
//                     myId: myId!,
//                     isTyping: isTyping,
//                   ),
//                 );
//               },
//             ),
//           ),
//           ChatInput(
//             roomId: widget.conversationId,
//             onSendText: _sendMessage,
//             onSendAttachment: _sendAttachment,
//             replyText: replyText,
//             onCancelReply: () {
//               setState(() => replyText = null);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_talk_mobile/core/services/api.dart' as ApiClient;
import '../../../core/services/socket_service.dart';
import '../../../core/widgets/chat_header.dart';
import '../../auth/viewmodel/auth_providers.dart';
import 'messages_list.dart';
import 'chat_input.dart';
import 'message_action_sheet.dart';
import 'reaction_bar.dart';
import 'file_attachment_tile.dart';
import 'image_preview.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  List messages = [];
  Map chatInfo = {};
  bool loading = true;
  bool isTyping = false;
  bool isOnline = false;
  String? lastSeen;
  String chatTitle = "Chat";
  String? replyText;

  @override
  void initState() {
    super.initState();
    _loadChat();
    _listenPresence();
  }

  Future<void> _loadChat() async {
    try {
      final info = await ApiClient.dio.get(
        '/conversations/${widget.conversationId}',
      );
      chatInfo = info.data['data'] ?? {};
      chatTitle = chatInfo['isGroup'] == true
          ? chatInfo['groupName'] ?? "Group"
          : "Chat"; // Change later when we fetch user details

      final res = await ApiClient.dio.get('/messages/${widget.conversationId}');
      messages = res.data['data'];

      SocketService.join(widget.conversationId);
      SocketService.onMessage((m) {
        if (mounted && m['conversationId'] == widget.conversationId) {
          setState(() => messages.add(m));
        }
      });

      setState(() => loading = false);
    } catch (e) {
      loading = false;
    }
  }

  void _listenPresence() {
    SocketService.onPresence((data) {
      if (data['userId'] == chatInfo['peerId']) {
        setState(() {
          isOnline = data['isOnline'];
          lastSeen = data['lastSeen'];
        });
      }
    });
  }

  void _sendMessage(String text) {
    SocketService.send(widget.conversationId, text);
  }

  Future<void> _sendAttachment(String path, String type) async {
    setState(() {
      messages.add({
        "message": "Uploading...",
        "type": type,
        "sender": ref.read(currentUserIdProvider),
        "status": "uploading",
        "localPath": path,
      });
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      messages.last["message"] = path;
      messages.last["status"] = "sent";
    });
    SocketService.send(widget.conversationId, path);
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: ChatHeader(
        title: chatTitle,
        isOnline: isOnline,
        lastSeen: lastSeen,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: MessagesList(
                    messages: messages,
                    myId: myId!,
                    isTyping: isTyping,
                  ),
                ),
                ChatInput(
                  roomId: widget.conversationId,
                  onSendText: _sendMessage,
                  onSendAttachment: _sendAttachment,
                ),
              ],
            ),
    );
  }
}
