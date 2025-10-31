// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../../../core/services/socket_service.dart';

// class ChatInput extends StatefulWidget {
//   final String roomId;
//   final Function(String) onSend;

//   const ChatInput({
//     super.key,
//     required this.roomId,
//     required this.onSend,
//   });

//   @override
//   State<ChatInput> createState() => _ChatInputState();
// }

// class _ChatInputState extends State<ChatInput> {
//   final controller = TextEditingController();
//   Timer? _typingTimer;

//   void _handleTyping(String text) {
//     SocketService.typing(widget.roomId);
//     _typingTimer?.cancel();
//     _typingTimer = Timer(const Duration(seconds: 2), () {
//       SocketService.stopTyping(widget.roomId);
//     });
//   }

//   void _send() {
//     final text = controller.text.trim();
//     if (text.isEmpty) return;
//     widget.onSend(text);
//     controller.clear();
//     SocketService.stopTyping(widget.roomId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: controller,
//                 onChanged: _handleTyping,
//                 decoration: InputDecoration(
//                   hintText: "Message",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 ),
//                 onSubmitted: (_) => _send(),
//               ),
//             ),
//             const SizedBox(width: 8),
//             CircleAvatar(
//               child: IconButton(
//                 icon: const Icon(Icons.send),
//                 onPressed: _send,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../../../core/services/socket_service.dart';

// class ChatInput extends StatefulWidget {
//   final String roomId;
//   final Function(String) onSend;

//   // NEW: reply banner support
//   final String? replyText;
//   final VoidCallback? onCancelReply;

//   const ChatInput({
//     super.key,
//     required this.roomId,
//     required this.onSend,
//     this.replyText,
//     this.onCancelReply,
//   });

//   @override
//   State<ChatInput> createState() => _ChatInputState();
// }

// class _ChatInputState extends State<ChatInput> {
//   final controller = TextEditingController();
//   Timer? _typingTimer;

//   void _handleTyping(String _) {
//     SocketService.typing(widget.roomId);
//     _typingTimer?.cancel();
//     _typingTimer = Timer(const Duration(seconds: 2), () {
//       SocketService.stopTyping(widget.roomId);
//     });
//   }

//   void _send() {
//     final text = controller.text.trim();
//     if (text.isEmpty) return;
//     widget.onSend(text);
//     controller.clear();
//     SocketService.stopTyping(widget.roomId);
//     widget.onCancelReply?.call(); // clear reply state after send
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Reply banner (if any)
//           if (widget.replyText != null && widget.replyText!.isNotEmpty)
//             Container(
//               width: double.infinity,
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.black12),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.reply, size: 18),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       widget.replyText!,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close, size: 18),
//                     onPressed: widget.onCancelReply,
//                   )
//                 ],
//               ),
//             ),

//           // Input row
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: controller,
//                     onChanged: _handleTyping,
//                     decoration: InputDecoration(
//                       hintText: "Message",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 10,
//                       ),
//                     ),
//                     onSubmitted: (_) => _send(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 CircleAvatar(
//                   child: IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: _send,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/socket_service.dart';
import 'attachment_sheet.dart';

class ChatInput extends StatefulWidget {
  final String roomId;
  final Function(String) onSendText;
  final Function(String, String) onSendAttachment;
  final String? replyText;
  final VoidCallback? onCancelReply;

  const ChatInput({
    super.key,
    required this.roomId,
    required this.onSendText,
    required this.onSendAttachment,
    this.replyText,
    this.onCancelReply,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final controller = TextEditingController();
  Timer? _typingTimer;

  void _handleTyping(String _) {
    SocketService.typing(widget.roomId);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      SocketService.stopTyping(widget.roomId);
    });
  }

  void _send() {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendText(text);
      controller.clear();
      widget.onCancelReply?.call();
    }
  }

  void _openAttachments() {
    showModalBottomSheet(
      context: context,
      builder: (_) => AttachmentSheet(
        onPickImage: _pickImage,
        onPickCamera: _pickCamera,
        onPickFile: _pickFile,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) widget.onSendAttachment(file.path, "image");
  }

  Future<void> _pickCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) widget.onSendAttachment(file.path, "image");
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.first.path != null) {
      widget.onSendAttachment(result.files.first.path!, "file");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          if (widget.replyText != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.replyText!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onCancelReply,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _openAttachments,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: _handleTyping,
                  decoration: const InputDecoration(
                    hintText: "Message",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _send),
            ],
          ),
        ],
      ),
    );
  }
}
