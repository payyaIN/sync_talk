// import 'package:flutter/material.dart';
// import '../../auth/data/user_model.dart';

// class ProfileScreen extends StatelessWidget {
//   final UserModel user;
//   const ProfileScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Profile")),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           CircleAvatar(
//             radius: 45,
//             backgroundImage: NetworkImage(
//               user.avatar ??
//                   "https://ui-avatars.com/api/?name=${user.name}&background=0A81D1&color=fff",
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
//           Text(user.email, style: const TextStyle(color: Colors.grey)),
//           const SizedBox(height: 20),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.message),
//             title: const Text("Send Message"),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.block),
//             title: const Text("Block User"),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.person, size: 80),
            Text(user.email ?? ''),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
