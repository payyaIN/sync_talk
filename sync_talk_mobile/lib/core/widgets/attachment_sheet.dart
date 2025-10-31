// import 'package:flutter/material.dart';

// class AttachmentSheet extends StatelessWidget {
//   final VoidCallback onPickImage;
//   final VoidCallback onPickCamera;
//   final VoidCallback onPickFile;

//   const AttachmentSheet({
//     super.key,
//     required this.onPickImage,
//     required this.onPickCamera,
//     required this.onPickFile,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Wrap(
//         children: [
//           ListTile(
//             leading: const Icon(Icons.image, color: Colors.blue),
//             title: const Text("Image from gallery"),
//             onTap: onPickImage,
//           ),
//           ListTile(
//             leading: const Icon(Icons.camera_alt, color: Colors.orange),
//             title: const Text("Camera"),
//             onTap: onPickCamera,
//           ),
//           ListTile(
//             leading: const Icon(Icons.attach_file, color: Colors.green),
//             title: const Text("File"),
//             onTap: onPickFile,
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class AttachmentSheet extends StatelessWidget {
//   final VoidCallback onImagePick;
//   final VoidCallback onFilePick;

//   const AttachmentSheet({
//     super.key,
//     required this.onImagePick,
//     required this.onFilePick,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 160,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               _attachmentIcon(Icons.image, "Gallery", onImagePick),
//               const SizedBox(width: 20),
//               _attachmentIcon(Icons.insert_drive_file, "File", onFilePick),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _attachmentIcon(IconData icon, String label, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Column(
//         children: [
//           CircleAvatar(radius: 26, child: Icon(icon, size: 28)),
//           const SizedBox(height: 8),
//           Text(label),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AttachmentSheet extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickCamera;
  final VoidCallback onPickFile;

  const AttachmentSheet({
    super.key,
    required this.onPickImage,
    required this.onPickCamera,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.image, color: Colors.blue),
            title: const Text("Image from gallery"),
            onTap: onPickImage,
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.orange),
            title: const Text("Camera"),
            onTap: onPickCamera,
          ),
          ListTile(
            leading: const Icon(Icons.attach_file, color: Colors.green),
            title: const Text("File"),
            onTap: onPickFile,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
