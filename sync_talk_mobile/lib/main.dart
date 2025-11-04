// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'src/features/auth/view/login_screen.dart';
// import 'src/features/auth/view/register_screen.dart';
// import 'src/features/home/view/home_screen.dart';
// import 'src/features/chat/view/chat_screen.dart';
// import 'src/features/call/view/call_screen.dart';
// import 'src/features/profile/view/profile_screen.dart';
// import 'src/services/session.dart';
// import 'src/services/push_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initSession();
//   // await pushService.init();
//   runApp(const ProviderScope(child: SyncTalkApp()));
// }

// class SyncTalkApp extends ConsumerWidget {
//   const SyncTalkApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = GoRouter(
//       redirect: (context, state) {
//         final conv = pushService.lastOpenConversationId;
//         if (conv != null && state.fullPath == '/home') {
//           pushService.lastOpenConversationId = null;
//           return '/chat/$conv';
//         }
//         return null;
//       },

//       initialLocation: '/login',
//       routes: [
//         GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
//         GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
//         GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
//         GoRoute(
//           path: '/chat/:id',
//           builder: (ctx, st) =>
//               ChatScreen(conversationId: st.pathParameters['id']!),
//         ),
//         GoRoute(
//           path: '/call/:id',
//           builder: (ctx, st) =>
//               CallScreen(conversationId: st.pathParameters['id']!),
//         ),
//         GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
//       ],
//     );

//     return MaterialApp.router(
//       title: 'SyncTalk',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//       ),
//       darkTheme: ThemeData.dark(useMaterial3: true),
//       routerConfig: router,
//     );
//   }
// }

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sync_talk_mobile/core/services/push_service.dart';
// import 'package:sync_talk_mobile/firebase_options.dart';
// import 'package:sync_talk_mobile/src/core/theme/app_theme.dart';
// import 'src/features/auth/view/login_screen.dart';
// import 'src/features/auth/view/register_screen.dart';
// import 'src/features/home/view/home_screen.dart';
// import 'src/features/chat/view/chat_screen.dart';
// import 'src/features/call/view/call_screen.dart';
// import 'src/features/profile/view/profile_screen.dart';
// import 'src/services/session.dart';
// import 'src/services/push_service.dart';
// import 'src/core/theme/app_theme.dart';

// void main() async {
//   // DEBUG: [INIT] - Initializing SyncTalk app
//   print('🚀 DEBUG: [INIT] - Starting SyncTalk initialization');

//   WidgetsFlutterBinding.ensureInitialized();

//   // DEBUG: [INIT] - Setting system UI overlays
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//       systemNavigationBarColor: Colors.white,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ),
//   );

//   print('🔐 DEBUG: [SESSION] - Initializing secure session storage');
//   await initSession();
//   print('✅ DEBUG: [SESSION] - Session initialized successfully');

//   print('✅ DEBUG: [INIT] - App initialization complete, launching UI');
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const ProviderScope(child: SyncTalkApp()));
// }

// class SyncTalkApp extends ConsumerWidget {
//   const SyncTalkApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // DEBUG: [ROUTER] - Configuring app navigation
//     print(
//       '🧭 DEBUG: [ROUTER] - Setting up GoRouter with push notification redirect',
//     );

//     final router = GoRouter(
//       redirect: (context, state) {
//         // DEBUG: [FCM] - Checking for push notification deep link
//         final conv = pushService.lastOpenConversationId;
//         if (conv != null && state.fullPath == '/home') {
//           print(
//             '📬 DEBUG: [FCM] - Redirecting to conversation from push: $conv',
//           );
//           pushService.lastOpenConversationId = null;
//           return '/chat/$conv';
//         }
//         return null;
//       },
//       initialLocation: '/login',
//       routes: [
//         GoRoute(
//           path: '/login',
//           builder: (_, __) {
//             print('🔐 DEBUG: [ROUTER] - Navigating to Login screen');
//             return const LoginScreen();
//           },
//         ),
//         GoRoute(
//           path: '/register',
//           builder: (_, __) {
//             print('📝 DEBUG: [ROUTER] - Navigating to Register screen');
//             return const RegisterScreen();
//           },
//         ),
//         GoRoute(
//           path: '/home',
//           builder: (_, __) {
//             print('🏠 DEBUG: [ROUTER] - Navigating to Home screen');
//             return const HomeScreen();
//           },
//         ),
//         GoRoute(
//           path: '/chat/:id',
//           builder: (ctx, st) {
//             final conversationId = st.pathParameters['id']!;
//             print('💬 DEBUG: [ROUTER] - Navigating to Chat: $conversationId');
//             return ChatScreen(conversationId: conversationId);
//           },
//         ),
//         GoRoute(
//           path: '/call/:id',
//           builder: (ctx, st) {
//             final conversationId = st.pathParameters['id']!;
//             print('📹 DEBUG: [ROUTER] - Navigating to Call: $conversationId');
//             return CallScreen(conversationId: conversationId);
//           },
//         ),
//         GoRoute(
//           path: '/profile',
//           builder: (_, __) {
//             print('👤 DEBUG: [ROUTER] - Navigating to Profile screen');
//             return const ProfileScreen();
//           },
//         ),
//       ],
//     );

//     // DEBUG: [THEME] - Applying modern Material Design 3 theme
//     print('🎨 DEBUG: [THEME] - Building app with enhanced Material 3 theme');

//     return MaterialApp.router(
//       title: 'SyncTalk',
//       debugShowCheckedModeBanner: false,

//       // Modern light theme with gradient accents
//       theme: AppTheme.lightTheme,

//       // Modern dark theme with deep colors
//       darkTheme: AppTheme.darkTheme,

//       // Respect system theme setting
//       themeMode: ThemeMode.system,

//       routerConfig: router,

//       // DEBUG: [THEME] - Custom theme configuration complete
//       builder: (context, child) {
//         print('✅ DEBUG: [UI] - Material app built successfully');
//         return child ?? const SizedBox();
//       },
//     );
//   }
// }

// Fixed Main Application Entry Point
// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_talk_mobile/core/services/api.dart';
import 'package:sync_talk_mobile/core/services/session.dart';
import 'package:sync_talk_mobile/core/theme/app_theme.dart';
import 'package:sync_talk_mobile/features/auth/presentation/login_screen.dart';
import 'package:sync_talk_mobile/features/auth/presentation/register_screen.dart';
import 'package:sync_talk_mobile/features/auth/view/login_screen.dart';
import 'package:sync_talk_mobile/features/auth/view/register_screen.dart';
import 'package:sync_talk_mobile/features/call/view/call_screen.dart';
import 'package:sync_talk_mobile/features/chat/presentation/chat_screen.dart';
import 'package:sync_talk_mobile/features/chat/presentation/home_screen.dart';
import 'package:sync_talk_mobile/features/home/presentation/home_screen.dart';
import 'package:sync_talk_mobile/features/profile/presentation/profile_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize core services
  print('🚀 Initializing SyncTalk...');

  await initSession();
  print('✅ Session initialized');

  initApi();
  print('✅ API client initialized');

  // Run the app
  runApp(const ProviderScope(child: SyncTalkApp()));
}

class SyncTalkApp extends ConsumerWidget {
  const SyncTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/chat/:id',
          builder: (ctx, st) {
            final conversationId = st.pathParameters['id']!;
            return ChatScreen(conversationId: conversationId);
          },
        ),
        GoRoute(
          path: '/call/:id',
          builder: (ctx, st) {
            final conversationId = st.pathParameters['id']!;
            return CallScreen(conversationId: conversationId);
          },
        ),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
      // Optional: Add navigation guard for authentication
      redirect: (context, state) async {
        final isLoggedIn = await session.isLoggedIn();
        final isAuthRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // If not logged in and trying to access protected route
        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }

        // If logged in and trying to access auth route
        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }

        return null; // No redirect needed
      },
    );

    return MaterialApp.router(
      title: 'SyncTalk',
      debugShowCheckedModeBanner: false,

      // Modern theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router configuration
      routerConfig: router,
    );
  }
}
