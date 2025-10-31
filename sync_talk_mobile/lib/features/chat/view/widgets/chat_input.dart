// import 'package:flutter/material.dart';

// class ChatInput extends StatefulWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final bool aiLoading;
//   final VoidCallback onSend;
//   final VoidCallback onAttach;
//   final VoidCallback onAiSuggest;
//   final VoidCallback onTyping;

//   const ChatInput({
//     super.key,
//     required this.controller,
//     required this.focusNode,
//     required this.aiLoading,
//     required this.onSend,
//     required this.onAttach,
//     required this.onAiSuggest,
//     required this.onTyping,
//   });

//   @override
//   State<ChatInput> createState() => _ChatInputState();
// }

// class _ChatInputState extends State<ChatInput> {
//   bool _hasText = false;

//   @override
//   void initState() {
//     super.initState();
//     // DEBUG: [INPUT] - Listen for text changes
//     widget.controller.addListener(_onTextChanged);
//   }

//   void _onTextChanged() {
//     final hasText = widget.controller.text.trim().isNotEmpty;
//     if (hasText != _hasText) {
//       setState(() => _hasText = hasText);

//       if (hasText) {
//         // DEBUG: [TYPING] - Emit typing indicator
//         widget.onTyping();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     widget.controller.removeListener(_onTextChanged);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

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
//                 widget.onAttach();
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
//                         controller: widget.controller,
//                         focusNode: widget.focusNode,
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
//                         onSubmitted: (_) {
//                           if (_hasText) {
//                             print('📤 DEBUG: [INPUT] - Submit via Enter key');
//                             widget.onSend();
//                           }
//                         },
//                       ),
//                     ),

//                     // DEBUG: [UI] - AI suggest button
//                     if (!_hasText)
//                       IconButton(
//                         icon: widget.aiLoading
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
//                         onPressed: widget.aiLoading
//                             ? null
//                             : () {
//                                 print(
//                                   '🤖 DEBUG: [INPUT] - AI suggest button pressed',
//                                 );
//                                 widget.onAiSuggest();
//                               },
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(width: 8),

//             // DEBUG: [UI] - Send button (animated)
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               curve: Curves.easeInOut,
//               width: 44,
//               height: 44,
//               child: FloatingActionButton(
//                 mini: true,
//                 elevation: _hasText ? 2 : 0,
//                 backgroundColor: _hasText
//                     ? theme.colorScheme.primary
//                     : Colors.grey.shade300,
//                 onPressed: _hasText
//                     ? () {
//                         print('📤 DEBUG: [INPUT] - Send button pressed');
//                         widget.onSend();
//                       }
//                     : null,
//                 child: Icon(
//                   Icons.send,
//                   size: 20,
//                   color: _hasText ? Colors.white : Colors.grey.shade500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
