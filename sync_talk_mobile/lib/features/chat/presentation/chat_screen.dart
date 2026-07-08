import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_talk_mobile/core/services/api.dart' as ApiClient;
import 'package:sync_talk_mobile/core/services/sockets.dart';
import 'package:sync_talk_mobile/features/chat/data/chat_repository.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/widgets/chat_header.dart';
import '../../auth/viewmodel/auth_providers.dart';
import 'messages_list.dart';
import 'chat_input.dart';

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
  String chatTitle = "Chat";
  String? chatAvatarUrl;
  String? myId;
  StreamSubscription? _presenceSubscription;

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  @override
  void dispose() {
    _presenceSubscription?.cancel();
    if (myId != null) {
      SocketService.disconnect(myId!);
    }
    super.dispose();
  }

  Future<void> _loadChat() async {
    try {
      final meRes = await ApiClient.dio.get('/users/me');
      myId = meRes.data['id'] ?? meRes.data['_id'];

      // Connect to Chat SocketService
      SocketService.connect(myId!);

      // Load conversation info
      final info = await ApiClient.dio.get(
        '/conversations/${widget.conversationId}',
      );
      chatInfo = info.data['data'] ?? {};
      
      // Resolve peer info
      final participants = chatInfo['participants'] as List?;
      if (chatInfo['isGroup'] == true) {
        chatTitle = chatInfo['groupName'] ?? "Group";
        chatAvatarUrl = chatInfo['groupImage'];
      } else if (participants != null && myId != null) {
        final other = participants.firstWhere(
          (p) => (p['_id'] ?? p['id']) != myId,
          orElse: () => null,
        );
        if (other != null) {
          chatTitle = other['displayName'] ?? other['email'] ?? "Chat";
          chatAvatarUrl = other['avatarUrl'];
          chatInfo['peerId'] = other['_id'] ?? other['id'];
        }
      }

      // Start listening to presence changes
      _listenPresence();

      // Load messages
      final res = await ApiClient.dio.get('/messages/${widget.conversationId}');
      final rawMessages = res.data['items'] ?? res.data['data'] ?? [];
      // ListView reverse is true, so we need newest messages first
      messages = List.from(rawMessages.reversed);

      // Join socket room
      SocketService.join(widget.conversationId);
      
      // Listen for socket messages
      SocketService.onMessage((m) {
        if (mounted && (m['conversation'] == widget.conversationId || m['conversationId'] == widget.conversationId)) {
          setState(() {
            messages.insert(0, m);
          });
        }
      });

      setState(() => loading = false);
    } catch (e) {
      print('Error loading chat: $e');
      setState(() => loading = false);
    }
  }

  void _listenPresence() {
    if (chatInfo['peerId'] != null) {
      // Set initial status
      isOnline = sockets.onlineUsers.contains(chatInfo['peerId']);
      
      // Listen for updates
      _presenceSubscription = sockets.onlineStream.listen((onlineUsers) {
        if (mounted) {
          setState(() {
            isOnline = onlineUsers.contains(chatInfo['peerId']);
          });
        }
      });
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty || myId == null) return;
    SocketService.send(widget.conversationId, text, myId!);
  }

  Future<void> _sendAttachment(String path, String type) async {
    if (myId == null) return;
    try {
      final filename = path.split('/').last;
      
      // Temporary placeholder message in list to show uploading status
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final tempMsg = {
        'id': tempId,
        'sender': myId,
        'content': 'Sending attachment...',
        'attachments': [path],
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'sending',
      };
      
      setState(() {
        messages.insert(0, tempMsg);
      });

      // Upload file to storage
      final fileUrl = await chatRepo.uploadFile(path, filename);
      
      // Remove temporary placeholder
      setState(() {
        messages.removeWhere((m) => m['id'] == tempId);
      });

      // Send message via SocketService with the attachment URL
      SocketService.send(
        widget.conversationId,
        "",
        myId!,
        attachments: [fileUrl],
      );
    } catch (e) {
      print('Error sending attachment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send attachment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatHeader(
        title: chatTitle,
        avatarUrl: chatAvatarUrl,
        subtitle: isOnline ? "Online" : "Offline",
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
