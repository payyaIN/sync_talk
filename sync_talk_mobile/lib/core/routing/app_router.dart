// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../features/auth/presentation/login_screen.dart';
// import '../features/auth/presentation/register_screen.dart';
// import '../features/home/presentation/home_screen.dart';
// import '../shared/providers/auth_state.dart';

// final appRouter = GoRouter(
//   initialLocation: '/login',
//   routes: [
//     GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
//     GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
//     GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
//   ],
//   redirect: (context, state) {
//     final container = ProviderScope.containerOf(context);
//     final isLoggedIn = container.read(authStateProvider);
//     final isAuthPage = state.location == '/login' || state.location == '/register';
//     if (!isLoggedIn && !isAuthPage) return '/login';
//     if (isLoggedIn && isAuthPage) return '/home';
//     return null;
//   },
//   debugLogDiagnostics: true,
// );

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../features/auth/viewmodel/auth_providers.dart';
// import '../../features/auth/presentation/login_screen.dart';
// import '../../features/auth/presentation/register_screen.dart';
// import '../../features/auth/presentation/splash_screen.dart';
// import '../../features/home/presentation/home_screen.dart';
// import '../../features/chat/presentation/chat_screen.dart';

// final _rootNavigatorKey = GlobalKey<NavigatorState>();

// final appRouter = GoRouter(
//   navigatorKey: _rootNavigatorKey,
//   initialLocation: '/splash',
//   routes: [
//     GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
//     GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
//     GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
//     GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
//     GoRoute(
//       path: '/chat/:id',
//       builder: (ctx, st) => ChatScreen(conversationId: st.pathParameters['id']!),
//     ),
//   ],
//   redirect: (context, state) {
//     final container = ProviderScope.containerOf(context);
//     final user = container.read(authStateProvider);
//     final loggingIn = state.subloc == '/login' || state.subloc == '/register';

//     if (user == null && !loggingIn && state.subloc != '/splash') {
//       return '/login';
//     }
//     if (user != null && loggingIn) return '/home';
//     return null;
//   },
// );

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/viewmodel/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/chat/:id',
      builder: (ctx, st) =>
          ChatScreen(conversationId: st.pathParameters['id']!),
    ),
  ],
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final user = container.read(authStateProvider);
    final loggingIn =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    if (user == null && !loggingIn && state.matchedLocation != '/splash') {
      return '/login';
    }
    if (user != null && loggingIn) return '/home';
    return null;
  },
);
