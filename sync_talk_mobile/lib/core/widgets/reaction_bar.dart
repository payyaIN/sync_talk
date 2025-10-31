// import 'package:flutter/material.dart';

// class ReactionBar extends StatelessWidget {
//   final Function(String) onReact;

//   const ReactionBar({super.key, required this.onReact});

//   @override
//   Widget build(BuildContext context) {
//     final emojis = ["👍", "❤️", "🔥", "😂", "😮", "😢"];
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: emojis
//             .map((e) => InkWell(
//                   onTap: () => onReact(e),
//                   child: Padding(padding: const EdgeInsets.all(6), child: Text(e, style: const TextStyle(fontSize: 22))),
//                 ))
//             .toList(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ReactionBar extends StatelessWidget {
  final Function(String) onReact;

  const ReactionBar({super.key, required this.onReact});

  @override
  Widget build(BuildContext context) {
    final reactions = ["❤️", "😂", "🔥", "👍", "👎", "💯"];

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(blurRadius: 6, color: Colors.black26.withOpacity(0.15)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: reactions.map((emoji) {
            return GestureDetector(
              onTap: () => onReact(emoji),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
