// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/widgets/app_button.dart';
// import '../../../core/widgets/app_input.dart';
// import '../../../core/routing/app_router.dart';
// import '../data/auth_repository.dart';

// class RegisterScreen extends ConsumerStatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends ConsumerState<RegisterScreen> {
//   final nameCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final passCtrl = TextEditingController();
//   bool loading = false;

//   Future<void> _register() async {
//     setState(() => loading = true);
//     try {
//       final api = AuthRepository();
//       await api.register(
//         nameCtrl.text.trim(),
//         emailCtrl.text.trim(),
//         passCtrl.text.trim(),
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Account created successfully! Please login."),
//           ),
//         );
//         appRouter.go('/login');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Registration failed. Try again.")),
//       );
//     } finally {
//       if (mounted) setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 400),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   const Icon(
//                     Icons.person_add_alt_1,
//                     size: 64,
//                     color: Colors.blue,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Create Your Account",
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                   const SizedBox(height: 16),
//                   AppInput(controller: nameCtrl, hint: "Full Name"),
//                   const SizedBox(height: 12),
//                   AppInput(controller: emailCtrl, hint: "Email"),
//                   const SizedBox(height: 12),
//                   AppInput(
//                     controller: passCtrl,
//                     hint: "Password",
//                     obscure: true,
//                   ),
//                   const SizedBox(height: 16),
//                   AppButton(
//                     label: loading ? "Creating account..." : "Register",
//                     onPressed: loading ? null : _register,
//                   ),
//                   const SizedBox(height: 10),
//                   TextButton(
//                     onPressed: () => appRouter.go('/login'),
//                     child: const Text("Already have an account? Login here"),
//                   ),
//                   const SizedBox(height: 40),
//                   const Text(
//                     "Made by Akshay Chandran",
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/widgets/app_button.dart';
// import '../../../core/widgets/app_input.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final name = TextEditingController();
//   final email = TextEditingController();
//   final password = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: SizedBox(
//             width: 400,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("Create Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 24),
//                 AppInput(controller: name, hint: "Name"),
//                 const SizedBox(height: 12),
//                 AppInput(controller: email, hint: "Email"),
//                 const SizedBox(height: 12),
//                 AppInput(controller: password, hint: "Password", isPassword: true),
//                 const SizedBox(height: 16),
//                 AppButton(text: "Register", onPressed: () {}),
//                 const SizedBox(height: 12),
//                 TextButton(
//                   onPressed: () => context.go("/"),
//                   child: const Text("Back to Login"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../viewmodel/auth_viewmodel.dart';

// class RegisterScreen extends ConsumerStatefulWidget {
//   const RegisterScreen({super.key});
//   @override
//   ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends ConsumerState<RegisterScreen> {
//   final name = TextEditingController();
//   final email = TextEditingController();
//   final password = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final loading = ref.watch(authLoadingProvider);
//     final error = ref.watch(authErrorProvider);

//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: SizedBox(
//             width: 400,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("Create Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 24),
//                 if (error != null) Text(error, style: const TextStyle(color: Colors.red)),
//                 const SizedBox(height: 8),
//                 AppInput(controller: name, hint: "Name"),
//                 const SizedBox(height: 12),
//                 AppInput(controller: email, hint: "Email"),
//                 const SizedBox(height: 12),
//                 AppInput(controller: password, hint: "Password", isPassword: true),
//                 const SizedBox(height: 16),
//                 AppButton(
//                   text: "Register",
//                   loading: loading,
//                   onPressed: () async {
//                     final ok = await ref.read(authViewModelProvider).register(name.text.trim(), email.text.trim(), password.text);
//                     if (ok && mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created')));
//                       // context.go('/home');
//                     }
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextButton(onPressed: () => context.go("/"), child: const Text("Back to Login")),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/widgets/app_button.dart';
// import '../../../core/widgets/app_input.dart';
// import '../../../core/routing/app_router.dart';
// import '../data/auth_repository.dart';

// class RegisterScreen extends ConsumerStatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends ConsumerState<RegisterScreen> {
//   final nameCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final passCtrl = TextEditingController();
//   bool loading = false;

//   Future<void> _register() async {
//     setState(() => loading = true);
//     try {
//       final api = AuthRepository();
//       await api.register(nameCtrl.text.trim(), emailCtrl.text.trim(), passCtrl.text.trim());

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Account created successfully! Please login.")),
//         );
//         appRouter.go('/login');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Registration failed. Try again.")),
//       );
//     } finally {
//       if (mounted) setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 400),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   const Icon(Icons.person_add_alt_1, size: 64, color: Colors.blue),
//                   const SizedBox(height: 12),
//                   Text("Create Your Account", style: Theme.of(context).textTheme.headlineSmall),
//                   const SizedBox(height: 16),
//                   AppInput(controller: nameCtrl, hint: "Full Name"),
//                   const SizedBox(height: 12),
//                   AppInput(controller: emailCtrl, hint: "Email"),
//                   const SizedBox(height: 12),
//                   AppInput(controller: passCtrl, hint: "Password", obscure: true),
//                   const SizedBox(height: 16),
//                   AppButton(
//                     label: loading ? "Creating account..." : "Register",
//                     onPressed: loading ? null : _register,
//                   ),
//                   const SizedBox(height: 10),
//                   TextButton(
//                     onPressed: () => appRouter.go('/login'),
//                     child: const Text("Already have an account? Login here"),
//                   ),
//                   const SizedBox(height: 40),
//                   const Text("Made by Akshay Chandran",
//                       style: TextStyle(fontSize: 12, color: Colors.grey)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 16),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => ref
                        .read(authControllerProvider.notifier)
                        .register(_email.text, _password.text),
                    child: const Text("Register"),
                  ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text("Back to login"),
            ),
          ],
        ),
      ),
    );
  }
}
