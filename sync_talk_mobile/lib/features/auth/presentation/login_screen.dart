// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/utils/secure_token_store.dart';
// import '../../../core/widgets/app_button.dart';
// import '../../../core/widgets/app_input.dart';
// import '../../../core/routing/app_router.dart';
// import '../data/auth_repository.dart';
// import '../viewmodel/auth_providers.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final emailCtrl = TextEditingController(text: "");
//   final passCtrl = TextEditingController(text: "");
//   bool loading = false;

//   Future<void> _login() async {
//     setState(() => loading = true);
//     try {
//       final repo = ref.read(authRepoProvider);
//       final res = await repo.login(emailCtrl.text.trim(), passCtrl.text.trim());
//       final token = res.data["token"];
//       await SecureTokenStore.save(token);

//       ApiClient.dio.options.headers["Authorization"] = "Bearer $token";

//       final me = await repo.me();
//       ref.read(authStateProvider.notifier).state = me.data["data"];

//       if (mounted) {
//         appRouter.go("/home");
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Login failed. Check credentials.")),
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
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.message_rounded,
//                     size: 64,
//                     color: Colors.blue,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "SyncTalk",
//                     style: Theme.of(context).textTheme.headlineMedium,
//                   ),
//                   const SizedBox(height: 16),
//                   AppInput(controller: emailCtrl, hint: "Email"),
//                   const SizedBox(height: 12),
//                   AppInput(
//                     controller: passCtrl,
//                     hint: "Password",
//                     obscure: true,
//                   ),
//                   const SizedBox(height: 16),
//                   AppButton(
//                     label: loading ? "Please wait..." : "Login",
//                     onPressed: loading ? null : _login,
//                   ),
//                   const SizedBox(height: 8),
//                   TextButton(
//                     onPressed: () => appRouter.go("/register"),
//                     child: const Text("Create new account"),
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

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
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
//                 const Text("SyncTalk", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 24),
//                 AppInput(controller: email, hint: "Email"),
//                 const SizedBox(height: 12),
//                 AppInput(controller: password, hint: "Password", isPassword: true),
//                 const SizedBox(height: 16),
//                 AppButton(text: "Login", onPressed: () {}),
//                 const SizedBox(height: 12),
//                 TextButton(
//                   onPressed: () => context.go("/register"),
//                   child: const Text("Create an account"),
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
// import '../../../core/routing/app_router.dart'; // if you want to push to /home later

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
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
//                 const Text("SyncTalk", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 24),
//                 if (error != null) Text(error, style: const TextStyle(color: Colors.red)),
//                 const SizedBox(height: 8),
//                 AppInput(controller: email, hint: "Email"),
//                 const SizedBox(height: 12),
//                 AppInput(controller: password, hint: "Password", isPassword: true),
//                 const SizedBox(height: 16),
//                 AppButton(
//                   text: "Login",
//                   loading: loading,
//                   onPressed: () async {
//                     final ok = await ref.read(authViewModelProvider).login(email.text.trim(), password.text);
//                     if (ok && mounted) {
//                       // TODO: navigate to Home (we’ll create it next step)
//                       // context.go('/home');
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login success')));
//                     }
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextButton(
//                   onPressed: () => context.go("/register"),
//                   child: const Text("Create an account"),
//                 ),
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
// import '../../../core/utils/secure_token_store.dart';
// import '../../../core/widgets/app_button.dart';
// import '../../../core/widgets/app_input.dart';
// import '../../../core/routing/app_router.dart';
// import '../../../core/services/dio_client.dart';
// import '../data/auth_repository.dart';
// import '../viewmodel/auth_providers.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final emailCtrl = TextEditingController(text: "");
//   final passCtrl = TextEditingController(text: "");
//   bool loading = false;

//   Future<void> _login() async {
//     setState(() => loading = true);
//     try {
//       final repo = ref.read(authRepoProvider);
//       final res = await repo.login(emailCtrl.text.trim(), passCtrl.text.trim());
//       final token = res.data["token"];
//       await SecureTokenStore.save(token);

//       ApiClient.dio.options.headers["Authorization"] = "Bearer $token";

//       final me = await repo.me();
//       ref.read(authStateProvider.notifier).state = me.data["data"];

//       if (mounted) {
//         appRouter.go("/home");
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Login failed. Check credentials.")),
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
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.message_rounded, size: 64, color: Colors.blue),
//                   const SizedBox(height: 12),
//                   Text("SyncTalk", style: Theme.of(context).textTheme.headlineMedium),
//                   const SizedBox(height: 16),
//                   AppInput(controller: emailCtrl, hint: "Email"),
//                   const SizedBox(height: 12),
//                   AppInput(controller: passCtrl, hint: "Password", obscure: true),
//                   const SizedBox(height: 16),
//                   AppButton(
//                     label: loading ? "Please wait..." : "Login",
//                     onPressed: loading ? null : _login,
//                   ),
//                   const SizedBox(height: 8),
//                   TextButton(
//                     onPressed: () => appRouter.go("/register"),
//                     child: const Text("Create new account"),
//                   ),
//                   const SizedBox(height: 40),
//                   const Text("Made by Akshay Chandran",
//                     style: TextStyle(fontSize: 12, color: Colors.grey)),
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
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../shared/providers/auth_state.dart';
// import '../controllers/auth_controller.dart';
// import 'package:go_router/go_router.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _email = TextEditingController();
//   final _password = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authControllerProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
//             TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
//             const SizedBox(height: 16),
//             authState.isLoading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: () => ref.read(authControllerProvider.notifier).login(_email.text, _password.text),
//                     child: const Text("Login"),
//                   ),
//             TextButton(
//               onPressed: () => context.go('/register'),
//               child: const Text("Create account"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../services/api.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginState();
// }

// class _LoginState extends ConsumerState<LoginScreen> {
//   final email = TextEditingController(text: 'test@example.com');
//   final pass  = TextEditingController(text: 'Passw0rd!');
//   bool loading = false;
//   String? error;

//   Future<void> _doLogin() async {
//     setState(() { loading = true; error = null; });
//     try {
//       await ref.read(Api()).login(email.text.trim(), pass.text);
//       if (mounted) context.go('/home');
//     } catch (e) {
//       setState(() => error = e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) setState(() => loading = false);
//     }
//   }

//   Future<void> _doRegister() async {
//     setState(() { loading = true; error = null; });
//     try {
//       await ref.read(Api()).register(email.text.trim(), pass.text);
//       await ref.read(Api()).login(email.text.trim(), pass.text);
//       if (mounted) context.go('/home');
//     } catch (e) {
//       setState(() => error = e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('SyncTalk Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
//             const SizedBox(height: 12),
//             TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
//             const SizedBox(height: 12),
//             if (error != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.red.withOpacity(0.3)),
//                 ),
//                 child: Text(error!, style: const TextStyle(color: Colors.red)),
//               ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: loading ? null : _doLogin,
//                     child: Text(loading ? 'Please wait...' : 'Login'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: loading ? null : _doRegister,
//                     child: const Text('Register'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginState();
// }

// class _LoginState extends ConsumerState<LoginScreen> {
//   final email = TextEditingController(text: 'test@example.com');
//   final pass = TextEditingController(text: 'Passw0rd!');
//   bool loading = false;
//   String? error;

//   Future<void> _doLogin() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       await ref.read(apiProvider).login(email.text.trim(), pass.text);
//       if (mounted) context.go('/home');
//     } catch (e, st) {
//       debugPrint('LOGIN ERROR: $e');
//       debugPrintStack(stackTrace: st);
//       setState(() => error = e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) setState(() => loading = false);
//     }
//   }

//   Future<void> _doRegister() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       await ref.read(apiProvider).register(email.text.trim(), pass.text);
//       await ref.read(apiProvider).login(email.text.trim(), pass.text);
//       if (mounted) context.go('/home');
//     } catch (e, st) {
//       debugPrint('REGISTER ERROR: $e');
//       debugPrintStack(stackTrace: st);
//       setState(() => error = e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       if (mounted) setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('SyncTalk Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: email,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: pass,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 12),
//             if (error != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.red.withOpacity(0.3)),
//                 ),
//                 child: Text(error!, style: const TextStyle(color: Colors.red)),
//               ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: loading ? null : _doLogin,
//                     child: Text(loading ? 'Please wait...' : 'Login'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: loading ? null : _doRegister,
//                     child: const Text('Register'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
