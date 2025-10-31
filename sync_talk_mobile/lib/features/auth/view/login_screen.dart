// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/services/session.dart';
// import '../../../core/services/sockets.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../../auth/data/auth_repo.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final email = TextEditingController();
//   final password = TextEditingController();
//   bool loading = false;
//   String? error;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             if (error != null)
//               Text(error!, style: const TextStyle(color: Colors.red)),
//             TextField(
//               controller: email,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: password,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: loading
//                   ? null
//                   : () async {
//                       setState(() {
//                         loading = true;
//                         error = null;
//                       });
//                       try {
//                         await authRepo.login(email.text, password.text);
//                         sockets.connect(userId: session.userId!);
//                         if (mounted) context.go('/home');
//                       } catch (e) {
//                         setState(() => error = 'Login failed');
//                       }
//                       setState(() => loading = false);
//                     },
//               child: Text(loading ? '...' : 'Login'),
//             ),
//             TextButton(
//               onPressed: () => context.go('/register'),
//               child: const Text('Create account'),
//             ),
//             const SizedBox(height: 8),
//             OutlinedButton.icon(
//               onPressed: loading
//                   ? null
//                   : () async {
//                       setState(() {
//                         loading = true;
//                         error = null;
//                       });
//                       try {
//                         final g = GoogleSignIn();
//                         final acct = await g.signIn();
//                         final auth = await acct?.authentication;
//                         final token = auth?.idToken;
//                         if (token != null) {
//                           await authRepo.loginWithGoogle(token);
//                           sockets.connect(userId: session.userId!);
//                           if (mounted) context.go('/home');
//                         }
//                       } catch (e) {
//                         setState(() => error = 'Google sign-in failed');
//                       }
//                       setState(() => loading = false);
//                     },
//               icon: const Icon(Icons.g_mobiledata),
//               label: const Text('Sign in with Google'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
