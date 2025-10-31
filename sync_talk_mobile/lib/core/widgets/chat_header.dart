// import 'package:flutter/material.dart';

// class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool isOnline;
//   final String? lastSeen;
//   final VoidCallback? onInfoTap;

//   const ChatHeader({
//     super.key,
//     required this.title,
//     required this.isOnline,
//     this.lastSeen,
//     this.onInfoTap,
//   });

//   String _getInitials(String name) {
//     if (name.isEmpty) return "?";
//     return name.trim().split(" ").map((e) => e[0]).take(2).join().toUpperCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       titleSpacing: 0,
//       title: Row(
//         children: [
//           CircleAvatar(radius: 20, child: Text(_getInitials(title))),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   isOnline ? "Online" : "last seen $lastSeen",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isOnline ? Colors.green : Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(icon: const Icon(Icons.info_outline), onPressed: onInfoTap),
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(60);
// }

// import 'package:flutter/material.dart';

// class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final String? subtitle;
//   final VoidCallback? onInfoTap;

//   const ChatHeader({
//     super.key,
//     required this.title,
//     this.subtitle,
//     this.onInfoTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       titleSpacing: 0,
//       title: Row(
//         children: [
//           const CircleAvatar(radius: 18, child: Icon(Icons.person)),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 if (subtitle != null)
//                   Text(subtitle!,
//                       style: const TextStyle(fontSize: 13, color: Colors.grey)),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.info_outline),
//           onPressed: onInfoTap,
//         ),
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(60);
// }

import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onInfoTap;

  const ChatHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          const CircleAvatar(radius: 18, child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.info_outline), onPressed: onInfoTap),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
