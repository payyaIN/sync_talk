// import 'package:flutter/material.dart';

// class MessageBubble extends StatelessWidget {
//   final bool isMine;
//   final String text;
//   final List attachments;
//   final DateTime time;
//   final String? avatarUrl;
//   final String? displayName;
//   final List readBy;
//   final bool isGroup;
//   final bool isFirstOfBlock;

//   const MessageBubble({
//     super.key,
//     required this.isMine,
//     required this.text,
//     required this.attachments,
//     required this.time,
//     required this.readBy,
//     this.avatarUrl,
//     this.displayName,
//     this.isGroup = false,
//     this.isFirstOfBlock = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bubbleColor = isMine
//         ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
//         : Theme.of(context).brightness == Brightness.dark
//             ? Colors.grey.shade800
//             : Colors.grey.shade200;
//     final radius = BorderRadius.only(
//       topLeft: Radius.circular(isMine ? 16 : 4),
//       topRight: Radius.circular(isMine ? 4 : 16),
//       bottomLeft: const Radius.circular(16),
//       bottomRight: const Radius.circular(16),
//     );

//     final timeStr = TimeOfDay.fromDateTime(time).format(context);
//     final seen = readBy.isNotEmpty;
//     final tick = isMine
//         ? Text(seen ? '✓✓' : '✓', style: TextStyle(fontSize: 11, color: seen ? Colors.lightBlue : Colors.grey))
//         : const SizedBox();

//     final textContent = text.isNotEmpty ? Text(text) : null;
//     final attachContent = (attachments.isNotEmpty)
//         ? Text('[Attachment] ${attachments.first}', style: const TextStyle(fontStyle: FontStyle.italic))
//         : null;

//     final bubble = Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       constraints: const BoxConstraints(maxWidth: 320),
//       decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (isGroup && !isMine && isFirstOfBlock && (displayName ?? '').isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 4),
//               child: Text(displayName!, style: TextStyle(fontSize: 12, color: Colors.teal.shade600, fontWeight: FontWeight.w600)),
//             ),
//           if (textContent != null) textContent,
//           if (attachContent != null) attachContent,
//           const SizedBox(height: 4),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Text(timeStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
//               const SizedBox(width: 6),
//               tick,
//             ],
//           ),
//         ],
//       ),
//     );

//     if (!isMine && isFirstOfBlock) {
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           CircleAvatar(
//             radius: 14,
//             backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty) ? NetworkImage(avatarUrl!) : null,
//             child: (avatarUrl == null || avatarUrl!.isEmpty) ? const Icon(Icons.person, size: 14) : null,
//           ),
//           const SizedBox(width: 8),
//           bubble,
//         ],
//       );
//     }
//     return bubble;
//   }
// }

// import 'package:flutter/material.dart';

// class MessageBubble extends StatelessWidget {
//   final bool isMine;
//   final String text;
//   final List attachments;
//   final DateTime time;
//   final List readBy;
//   final bool isSending;
//   final String? avatarUrl;
//   final String? displayName;
//   final bool isGroup;
//   final bool isFirstOfBlock;

//   const MessageBubble({
//     super.key,
//     required this.isMine,
//     required this.text,
//     required this.attachments,
//     required this.time,
//     required this.readBy,
//     this.isSending = false,
//     this.avatarUrl,
//     this.displayName,
//     this.isGroup = false,
//     this.isFirstOfBlock = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     // DEBUG: [UI] - Calculate bubble color based on theme
//     final bubbleColor = isMine
//         ? theme.colorScheme.primaryContainer.withOpacity(0.3)
//         : theme.brightness == Brightness.dark
//         ? Colors.grey.shade800
//         : Colors.grey.shade100;

//     // DEBUG: [UI] - Asymmetric bubble radius (Telegram style)
//     final radius = BorderRadius.only(
//       topLeft: Radius.circular(isMine ? 20 : 4),
//       topRight: Radius.circular(isMine ? 4 : 20),
//       bottomLeft: const Radius.circular(20),
//       bottomRight: const Radius.circular(20),
//     );

//     final timeStr = TimeOfDay.fromDateTime(time).format(context);
//     final seen = readBy.isNotEmpty;

//     // DEBUG: [UI] - Status indicator (sending/sent/seen)
//     Widget statusWidget;
//     if (isSending) {
//       statusWidget = SizedBox(
//         width: 12,
//         height: 12,
//         child: CircularProgressIndicator(
//           strokeWidth: 2,
//           valueColor: AlwaysStoppedAnimation(Colors.grey.shade400),
//         ),
//       );
//     } else if (isMine) {
//       statusWidget = Icon(
//         seen ? Icons.done_all : Icons.done,
//         size: 16,
//         color: seen ? theme.colorScheme.primary : Colors.grey.shade400,
//       );
//     } else {
//       statusWidget = const SizedBox();
//     }

//     final bubble = Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.of(context).size.width * 0.75,
//         minWidth: 80,
//       ),
//       decoration: BoxDecoration(
//         color: bubbleColor,
//         borderRadius: radius,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // DEBUG: [UI] - Sender name (group chats only)
//           if (isGroup &&
//               !isMine &&
//               isFirstOfBlock &&
//               (displayName ?? '').isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 4),
//               child: Text(
//                 displayName!,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: theme.colorScheme.primary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),

//           // DEBUG: [UI] - Message text
//           if (text.isNotEmpty)
//             Text(text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.4)),

//           // DEBUG: [UI] - Attachments preview
//           if (attachments.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: _buildAttachments(context),
//             ),

//           const SizedBox(height: 4),

//           // DEBUG: [UI] - Time and status row
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Text(
//                 timeStr,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   fontSize: 11,
//                   color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
//                 ),
//               ),
//               const SizedBox(width: 4),
//               statusWidget,
//             ],
//           ),
//         ],
//       ),
//     );

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         mainAxisAlignment: isMine
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // DEBUG: [UI] - Avatar for other users
//           if (!isMine && isFirstOfBlock)
//             Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: CircleAvatar(
//                 radius: 16,
//                 backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//                 backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
//                     ? NetworkImage(avatarUrl!)
//                     : null,
//                 child: (avatarUrl == null || avatarUrl!.isEmpty)
//                     ? Icon(
//                         Icons.person,
//                         size: 16,
//                         color: theme.colorScheme.primary,
//                       )
//                     : null,
//               ),
//             )
//           else if (!isMine)
//             const SizedBox(width: 40),

//           // DEBUG: [UI] - Message bubble
//           bubble,
//         ],
//       ),
//     );
//   }

//   /// Build attachments preview
//   Widget _buildAttachments(BuildContext context) {
//     final theme = Theme.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: attachments.map((att) {
//         final String url = att.toString();
//         final String filename = url.split('/').last;

//         // DEBUG: [UI] - Check if image
//         if (_isImage(filename)) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.network(
//               url,
//               width: 200,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => _buildFileChip(context, filename),
//             ),
//           );
//         }

//         return _buildFileChip(context, filename);
//       }).toList(),
//     );
//   }

//   /// Build file chip
//   Widget _buildFileChip(BuildContext context, String filename) {
//     final theme = Theme.of(context);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.insert_drive_file,
//             size: 20,
//             color: theme.colorScheme.primary,
//           ),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               filename,
//               style: theme.textTheme.bodySmall?.copyWith(
//                 fontStyle: FontStyle.italic,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Check if file is an image
//   bool _isImage(String filename) {
//     final ext = filename.split('.').last.toLowerCase();
//     return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
//   }
// }
