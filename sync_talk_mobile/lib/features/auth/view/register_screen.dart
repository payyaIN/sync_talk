// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../auth/data/auth_repo.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final name = TextEditingController();
//   final email = TextEditingController();
//   final password = TextEditingController();
//   String? msg;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: name, decoration: const InputDecoration(labelText: 'Display name')),
//             TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
//             TextField(controller: password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
//             const SizedBox(height: 16),
//             ElevatedButton(onPressed: () async {
//               await authRepo.register(name.text, email.text, password.text);
//               setState(() => msg = 'Account created. Please login.');
//             }, child: const Text('Create account')),
//             if (msg != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(msg!)),
//             TextButton(onPressed: () => context.go('/login'), child: const Text('Back to login')),
//           ],
//         ),
//       ),
//     );
//   }
// }
