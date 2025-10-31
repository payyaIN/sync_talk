// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/utils/secure_token_store.dart';
// import '../../../core/routing/app_router.dart';

// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends ConsumerState<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     checkLogin();
//   }

//   Future<void> checkLogin() async {
//     final token = await SecureTokenStore.read();
//     await Future.delayed(const Duration(seconds: 1)); // smooth splash
//     if (token != null) {
//       appRouter.go('/home');
//     } else {
//       appRouter.go('/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/utils/secure_token_store.dart';
// import '../../../core/routing/app_router.dart';
// import '../data/auth_repository.dart';
// import '../viewmodel/auth_providers.dart';

// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends ConsumerState<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     checkSession();
//   }

//   Future<void> checkSession() async {
//     final token = await SecureTokenStore.read();
//     if (token == null) {
//       appRouter.go('/login');
//       return;
//     }

//     try {
//       final authRepo = ref.read(authRepoProvider);
//       final me = await authRepo.me();
//       ref.read(authStateProvider.notifier).state = me.data['data'];
//       appRouter.go('/home');
//     } catch (e) {
//       await SecureTokenStore.clear();
//       appRouter.go('/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/utils/secure_token_store.dart';
// import '../../../core/routing/app_router.dart';

// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends ConsumerState<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     checkLogin();
//   }

//   Future<void> checkLogin() async {
//     final token = await SecureTokenStore.read();
//     await Future.delayed(const Duration(seconds: 1)); // smooth splash
//     if (token != null) {
//       appRouter.go('/home');
//     } else {
//       appRouter.go('/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/utils/secure_token_store.dart';
// import '../../../core/routing/app_router.dart';
// import '../data/auth_repository.dart';
// import '../viewmodel/auth_providers.dart';

// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends ConsumerState<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     checkSession();
//   }

//   Future<void> checkSession() async {
//     final token = await SecureTokenStore.read();
//     if (token == null) {
//       appRouter.go('/login');
//       return;
//     }

//     try {
//       final authRepo = ref.read(authRepoProvider);
//       final me = await authRepo.me();
//       ref.read(authStateProvider.notifier).state = me.data['data'];
//       appRouter.go('/home');
//     } catch (e) {
//       await SecureTokenStore.clear();
//       appRouter.go('/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:go_router/go_router.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(const Duration(seconds: 2), () {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         context.go('/role');
//       } else {
//         context.go('/login');
//       }
//     });

//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        context.go('/login');
      } else {
        context.go('/role');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
