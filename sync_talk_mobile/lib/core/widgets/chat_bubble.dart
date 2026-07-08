// import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';

// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isMine;

//   const ChatBubble({super.key, required this.message, required this.isMine});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//         decoration: BoxDecoration(
//           color: isMine ? AppColors.primary : Colors.grey[300],
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(12),
//             topRight: const Radius.circular(12),
//             bottomLeft: isMine ? const Radius.circular(12) : Radius.zero,
//             bottomRight: isMine ? Radius.zero : const Radius.circular(12),
//           ),
//         ),
//         child: Text(
//           message,
//           style: TextStyle(
//             color: isMine ? Colors.white : Colors.black,
//             fontSize: 15,
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../theme/app_colors.dart';

// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isMine;
//   final DateTime time;
//   final String? senderName;
//   final bool showSender;

//   const ChatBubble({
//     super.key,
//     required this.message,
//     required this.isMine,
//     required this.time,
//     this.senderName,
//     this.showSender = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final timeLabel = DateFormat('hh:mm a').format(time);

//     return Align(
//       alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         decoration: BoxDecoration(
//           color: isMine ? AppColors.primary : Colors.grey[200],
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(12),
//             topRight: const Radius.circular(12),
//             bottomLeft: isMine ? const Radius.circular(12) : Radius.zero,
//             bottomRight: isMine ? Radius.zero : const Radius.circular(12),
//           ),
//         ),
//         constraints: const BoxConstraints(maxWidth: 280),
//         child: Column(
//           crossAxisAlignment:
//               isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             if (showSender && senderName != null)
//               Text(
//                 senderName!,
//                 style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//               ),
//             Text(
//               message,
//               style: TextStyle(
//                 color: isMine ? Colors.white : Colors.black87,
//                 fontSize: 15,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               timeLabel,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: isMine ? Colors.white70 : Colors.black54,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../utils/date_helper.dart';

// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isMine;
//   final String time;
//   final String status; // sent, delivered, seen
//   final VoidCallback? onLongPress;
//   final bool isReply;
//   final String? replyText;

//   const ChatBubble({
//     super.key,
//     required this.message,
//     required this.isMine,
//     required this.time,
//     required this.status,
//     this.onLongPress,
//     this.isReply = false,
//     this.replyText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bubbleColor = isMine
//         ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
//         : Colors.grey.shade300;

//     return Align(
//       alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
//       child: GestureDetector(
//         onLongPress: onLongPress,
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 4),
//           padding: const EdgeInsets.all(10),
//           constraints: const BoxConstraints(maxWidth: 280),
//           decoration: BoxDecoration(
//             color: bubbleColor,
//             borderRadius: BorderRadius.only(
//               topLeft: const Radius.circular(16),
//               topRight: const Radius.circular(16),
//               bottomLeft: Radius.circular(isMine ? 16 : 0),
//               bottomRight: Radius.circular(isMine ? 0 : 16),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment:
//                 isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//             children: [
//               if (isReply && replyText != null)
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   margin: const EdgeInsets.only(bottom: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.black12,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     replyText!,
//                     style: const TextStyle(fontSize: 12, color: Colors.black87),
//                   ),
//                 ),
//               Text(message, style: const TextStyle(fontSize: 15)),
//               const SizedBox(height: 5),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(time, style: const TextStyle(fontSize: 11)),
//                   const SizedBox(width: 6),
//                   if (isMine)
//                     Icon(
//                       status == 'seen'
//                           ? Icons.done_all
//                           : status == 'delivered'
//                               ? Icons.done_all
//                               : Icons.check,
//                       size: 16,
//                       color:
//                           status == 'seen' ? Colors.blue : Colors.black54,
//                     )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isMine;
//   final String time;
//   final String status;
//   final VoidCallback? onLongPress;
//   final List<String>? reactions;

//   const ChatBubble({
//     super.key,
//     required this.message,
//     required this.isMine,
//     required this.time,
//     required this.status,
//     this.onLongPress,
//     this.reactions,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bubbleColor = isMine
//         ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
//         : Colors.grey.shade300;

//     return GestureDetector(
//       onLongPress: onLongPress,
//       child: Align(
//         alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
//         child: Column(
//           crossAxisAlignment: isMine
//               ? CrossAxisAlignment.end
//               : CrossAxisAlignment.start,
//           children: [
//             Container(
//               margin: const EdgeInsets.symmetric(vertical: 4),
//               padding: const EdgeInsets.all(12),
//               constraints: const BoxConstraints(maxWidth: 280),
//               decoration: BoxDecoration(
//                 color: bubbleColor,
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(16),
//                   topRight: const Radius.circular(16),
//                   bottomLeft: Radius.circular(isMine ? 16 : 0),
//                   bottomRight: Radius.circular(isMine ? 0 : 16),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: isMine
//                     ? CrossAxisAlignment.end
//                     : CrossAxisAlignment.start,
//                 children: [
//                   Text(message, style: const TextStyle(fontSize: 15)),
//                   const SizedBox(height: 6),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(time, style: const TextStyle(fontSize: 11)),
//                       const SizedBox(width: 6),
//                       if (isMine)
//                         Icon(
//                           status == 'seen'
//                               ? Icons.done_all
//                               : status == 'delivered'
//                               ? Icons.done_all
//                               : Icons.check,
//                           size: 16,
//                           color: status == 'seen'
//                               ? Colors.blue
//                               : Colors.black54,
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             if (reactions != null && reactions!.isNotEmpty)
//               Container(
//                 margin: const EdgeInsets.only(top: 2),
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.black12),
//                 ),
//                 child: Wrap(
//                   spacing: 4,
//                   children: reactions!
//                       .map((e) => Text(e, style: const TextStyle(fontSize: 16)))
//                       .toList(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../utils/date_helper.dart';

// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isMine;
//   final String time;
//   final String status; // sent, delivered, seen
//   final VoidCallback? onLongPress;
//   final bool isReply;
//   final String? replyText;

//   const ChatBubble({
//     super.key,
//     required this.message,
//     required this.isMine,
//     required this.time,
//     required this.status,
//     this.onLongPress,
//     this.isReply = false,
//     this.replyText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bubbleColor = isMine
//         ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
//         : Colors.grey.shade300;

//     return Align(
//       alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
//       child: GestureDetector(
//         onLongPress: onLongPress,
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 4),
//           padding: const EdgeInsets.all(10),
//           constraints: const BoxConstraints(maxWidth: 280),
//           decoration: BoxDecoration(
//             color: bubbleColor,
//             borderRadius: BorderRadius.only(
//               topLeft: const Radius.circular(16),
//               topRight: const Radius.circular(16),
//               bottomLeft: Radius.circular(isMine ? 16 : 0),
//               bottomRight: Radius.circular(isMine ? 0 : 16),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment:
//                 isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//             children: [
//               if (isReply && replyText != null)
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   margin: const EdgeInsets.only(bottom: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.black12,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     replyText!,
//                     style: const TextStyle(fontSize: 12, color: Colors.black87),
//                   ),
//                 ),
//               Text(message, style: const TextStyle(fontSize: 15)),
//               const SizedBox(height: 5),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(time, style: const TextStyle(fontSize: 11)),
//                   const SizedBox(width: 6),
//                   if (isMine)
//                     Icon(
//                       status == 'seen'
//                           ? Icons.done_all
//                           : status == 'delivered'
//                               ? Icons.done_all
//                               : Icons.check,
//                       size: 16,
//                       color:
//                           status == 'seen' ? Colors.blue : Colors.black54,
//                     )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String time;
  final String status;
  final VoidCallback? onLongPress;
  final List<String>? reactions;
  final Color? color;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.time,
    required this.status,
    this.onLongPress,
    this.reactions,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = color ?? (isMine
        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
        : Colors.grey.shade300);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 0),
                  bottomRight: Radius.circular(isMine ? 0 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(message, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 6),
                      if (isMine)
                        Icon(
                          status == 'seen'
                              ? Icons.done_all
                              : status == 'delivered'
                              ? Icons.done_all
                              : Icons.check,
                          size: 16,
                          color: status == 'seen'
                              ? Colors.blue
                              : Colors.black54,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (reactions != null && reactions!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Wrap(
                  spacing: 4,
                  children: reactions!
                      .map((e) => Text(e, style: const TextStyle(fontSize: 16)))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
