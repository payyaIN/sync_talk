// import 'package:flutter/material.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path/path.dart' as p;
// import '../services/file_service.dart';

// IconData _iconForExt(String ext) {
//   final e = ext.toLowerCase();
//   if (['pdf'].contains(e)) return Icons.picture_as_pdf;
//   if (['doc', 'docx'].contains(e)) return Icons.description;
//   if (['xls', 'xlsx', 'csv'].contains(e)) return Icons.grid_on;
//   if (['ppt', 'pptx', 'key'].contains(e)) return Icons.slideshow;
//   if (['zip', 'rar', '7z', 'gz'].contains(e)) return Icons.archive;
//   if (['txt', 'md', 'rtf'].contains(e)) return Icons.article;
//   return Icons.insert_drive_file;
// }

// class FileAttachmentTile extends StatefulWidget {
//   final String url;
//   final String? mime;   // optional, if backend returns
//   final bool isMine;

//   const FileAttachmentTile({
//     super.key,
//     required this.url,
//     this.mime,
//     required this.isMine,
//   });

//   @override
//   State<FileAttachmentTile> createState() => _FileAttachmentTileState();
// }

// class _FileAttachmentTileState extends State<FileAttachmentTile> {
//   bool _opening = false;

//   Future<void> _open() async {
//     try {
//       setState(() => _opening = true);
//       final filename = p.basename(Uri.parse(widget.url).path);
//       final path = await FileCache.downloadToCache(widget.url, filename: filename);
//       await OpenFilex.open(path);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to open file')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _opening = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filename = p.basename(Uri.parse(widget.url).path);
//     final ext = p.extension(filename).replaceFirst('.', '');
//     final icon = _iconForExt(ext);

//     return InkWell(
//       onTap: _opening ? null : _open,
//       child: Container(
//         width: 220,
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: widget.isMine ? Colors.white10 : Colors.black12,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: widget.isMine ? Colors.white : Colors.black87),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 filename,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: widget.isMine ? Colors.white : Colors.black87,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 6),
//             if (_opening)
//               const SizedBox(
//                 width: 18, height: 18,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:open_filex/open_filex.dart';

// class FileAttachmentTile extends StatelessWidget {
//   final String fileName;
//   final String fileUrl;
//   final bool isMine;

//   const FileAttachmentTile({
//     super.key,
//     required this.fileName,
//     required this.fileUrl,
//     required this.isMine,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = isMine ? Colors.blue.shade100 : Colors.grey.shade300;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.insert_drive_file, size: 24, color: Colors.black54),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
//           ),
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: () {
//               OpenFilex.open(fileUrl);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class FileAttachmentTile extends StatelessWidget {
  final String fileName;
  final String fileUrl;
  final bool isMine;

  const FileAttachmentTile({
    super.key,
    required this.fileName,
    required this.fileUrl,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMine ? Colors.blue.shade100 : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, size: 24, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              OpenFilex.open(fileUrl);
            },
          ),
        ],
      ),
    );
  }
}
