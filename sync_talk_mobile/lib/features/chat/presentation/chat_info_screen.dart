// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../profile/presentation/profile_screen.dart';
// import '../../../features/auth/data/user_model.dart';
// import '../../../core/theme/app_colors.dart';

// class ChatInfoScreen extends ConsumerWidget {
//   final Map<String, dynamic> conversation;
//   const ChatInfoScreen({super.key, required this.conversation});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isGroup = conversation["isGroup"] ?? false;
//     final name = conversation["name"] ?? "Chat";
//     final avatar = conversation["avatar"] ??
//         "https://ui-avatars.com/api/?name=$name&background=0A81D1&color=fff";

//     return Scaffold(
//       appBar: AppBar(title: const Text("Chat Info")),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           CircleAvatar(radius: 45, backgroundImage: NetworkImage(avatar)),
//           const SizedBox(height: 12),
//           Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text(isGroup ? "${conversation["participants"].length} members" : "Personal Chat",
//               style: const TextStyle(color: Colors.grey)),
//           const SizedBox(height: 20),
//           const Divider(),

//           // ---------------- ACTIONS ----------------
//           if (!isGroup)
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text("View Profile"),
//               onTap: () {
//                 final user = UserModel(
//                   id: conversation["userId"],
//                   name: name,
//                   email: conversation["email"] ?? "",
//                   avatar: avatar,
//                 );
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => ProfileScreen(user: user)),
//                 );
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.block, color: Colors.red),
//             title: const Text("Block User"),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.flag, color: Colors.orange),
//             title: const Text("Report User"),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.delete_forever, color: Colors.red),
//             title: const Text("Clear Chat"),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/config/app_env.dart';
// import '../../../core/utils/token_store.dart';

// class ChatInfoScreen extends ConsumerStatefulWidget {
//   final Map<String, dynamic> conversation;
//   const ChatInfoScreen({super.key, required this.conversation});

//   @override
//   ConsumerState<ChatInfoScreen> createState() => _ChatInfoScreenState();
// }

// class _ChatInfoScreenState extends ConsumerState<ChatInfoScreen> {
//   Map<String, dynamic>? group;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadGroup();
//   }

//   Future<void> _loadGroup() async {
//     try {
//       final dio = Dio();
//       final token = await TokenStore.read();
//       final res = await dio.get("${AppEnv.apiBaseUrl}/groups/${widget.conversation["_id"]}",
//           options: Options(headers: {"Authorization": "Bearer $token"}));
//       setState(() {
//         group = res.data["data"];
//         loading = false;
//       });
//     } catch (_) {
//       setState(() => loading = false);
//     }
//   }

//   Future<void> _addMembers() async {
//     // Simple demo: prompt comma-separated userIds (replace with a proper picker later)
//     final ctrl = TextEditingController();
//     final ids = await showDialog<List<String>>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Add members (user IDs, comma separated)"),
//         content: TextField(controller: ctrl),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text.split(",").map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList()), child: const Text("Add")),
//         ],
//       ),
//     );
//     if (ids == null || ids.isEmpty) return;

//     final dio = Dio();
//     final token = await TokenStore.read();
//     await dio.post("${AppEnv.apiBaseUrl}/groups/members/add",
//       data: {"conversationId": widget.conversation["_id"], "members": ids},
//       options: Options(headers: {"Authorization": "Bearer $token"}),
//     );
//     _loadGroup();
//   }

//   Future<void> _removeMember(String userId) async {
//     final dio = Dio();
//     final token = await TokenStore.read();
//     await dio.post("${AppEnv.apiBaseUrl}/groups/members/remove",
//       data: {"conversationId": widget.conversation["_id"], "userId": userId},
//       options: Options(headers: {"Authorization": "Bearer $token"}),
//     );
//     _loadGroup();
//   }

//   Future<void> _leaveGroup() async {
//     final dio = Dio();
//     final token = await TokenStore.read();
//     await dio.post("${AppEnv.apiBaseUrl}/groups/leave",
//       data: {"conversationId": widget.conversation["_id"]},
//       options: Options(headers: {"Authorization": "Bearer $token"}),
//     );
//     if (mounted) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Left group")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isGroup = widget.conversation["isGroup"] ?? false;
//     final name = widget.conversation["name"] ?? "Chat";
//     final avatar = widget.conversation["avatar"] ??
//         "https://ui-avatars.com/api/?name=$name&background=0A81D1&color=fff";

//     return Scaffold(
//       appBar: AppBar(title: const Text("Chat Info")),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   CircleAvatar(radius: 45, backgroundImage: NetworkImage(avatar)),
//                   const SizedBox(height: 12),
//                   Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 6),
//                   Text(isGroup ? "${group?["participants"]?.length ?? 0} members" : "Personal Chat",
//                       style: const TextStyle(color: Colors.grey)),
//                   const SizedBox(height: 16),
//                   const Divider(),

//                   if (isGroup) ...[
//                     ListTile(
//                       leading: const Icon(Icons.group_add),
//                       title: const Text("Add members"),
//                       onTap: _addMembers,
//                     ),
//                     const Divider(height: 0),
//                     ListTile(
//                       leading: const Icon(Icons.logout, color: Colors.red),
//                       title: const Text("Leave group"),
//                       onTap: _leaveGroup,
//                     ),
//                     const Divider(),
//                     const Padding(
//                       padding: EdgeInsets.all(12.0),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text("Members", style: TextStyle(fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                     ...List<Widget>.from((group?["participants"] ?? []).map<Widget>((u) {
//                       final id = u["_id"] as String;
//                       final uname = (u["name"] ?? "") as String;
//                       final uavatar = (u["avatar"] ?? "") as String;
//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: NetworkImage(
//                             uavatar.isNotEmpty
//                                 ? uavatar
//                                 : "https://ui-avatars.com/api/?name=$uname&background=0A81D1&color=fff",
//                           ),
//                         ),
//                         title: Text(uname),
//                         subtitle: Text(u["email"] ?? ""),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.remove_circle, color: Colors.red),
//                           onPressed: () => _removeMember(id),
//                         ),
//                       );
//                     })),
//                   ],
//                 ],
//               ),
//             ),
//     );
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_env.dart';
import '../../../core/utils/secure_token_store.dart';

class ChatInfoScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> conversation;
  const ChatInfoScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends ConsumerState<ChatInfoScreen> {
  Map<String, dynamic>? group;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    try {
      final dio = Dio();
      final token = await SecureTokenStore.read();
      final res = await dio.get(
        "${AppEnv.apiBaseUrl}/groups/${widget.conversation["_id"]}",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      setState(() {
        group = res.data["data"];
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _addMembers() async {
    // Simple demo: prompt comma-separated userIds (replace with a proper picker later)
    final ctrl = TextEditingController();
    final ids = await showDialog<List<String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add members (user IDs, comma separated)"),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              ctrl.text
                  .split(",")
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
    if (ids == null || ids.isEmpty) return;

    final dio = Dio();
    final token = await TokenStore.read();
    await dio.post(
      "${AppEnv.apiBaseUrl}/groups/members/add",
      data: {"conversationId": widget.conversation["_id"], "members": ids},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    _loadGroup();
  }

  Future<void> _removeMember(String userId) async {
    final dio = Dio();
    final token = await TokenStore.read();
    await dio.post(
      "${AppEnv.apiBaseUrl}/groups/members/remove",
      data: {"conversationId": widget.conversation["_id"], "userId": userId},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    _loadGroup();
  }

  Future<void> _leaveGroup() async {
    final dio = Dio();
    final token = await TokenStore.read();
    await dio.post(
      "${AppEnv.apiBaseUrl}/groups/leave",
      data: {"conversationId": widget.conversation["_id"]},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Left group")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = widget.conversation["isGroup"] ?? false;
    final name = widget.conversation["name"] ?? "Chat";
    final avatar =
        widget.conversation["avatar"] ??
        "https://ui-avatars.com/api/?name=$name&background=0A81D1&color=fff";

    return Scaffold(
      appBar: AppBar(title: const Text("Chat Info")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(avatar),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isGroup
                        ? "${group?["participants"]?.length ?? 0} members"
                        : "Personal Chat",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),

                  if (isGroup) ...[
                    ListTile(
                      leading: const Icon(Icons.group_add),
                      title: const Text("Add members"),
                      onTap: _addMembers,
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Leave group"),
                      onTap: _leaveGroup,
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Members",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ...List<Widget>.from(
                      (group?["participants"] ?? []).map<Widget>((u) {
                        final id = u["_id"] as String;
                        final uname = (u["name"] ?? "") as String;
                        final uavatar = (u["avatar"] ?? "") as String;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              uavatar.isNotEmpty
                                  ? uavatar
                                  : "https://ui-avatars.com/api/?name=$uname&background=0A81D1&color=fff",
                            ),
                          ),
                          title: Text(uname),
                          subtitle: Text(u["email"] ?? ""),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeMember(id),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

// Text(
//   (widget.conversation["isGroup"] ?? false)
//       ? "${(widget.conversation["participants"] as List?)?.length ?? ''} members"
//       : (isOnline ? "Online" : "Last seen recently"),
//   style: const TextStyle(fontSize: 12, color: Colors.white70),
// ),
