import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'src/screens/login.dart';
import 'src/screens/dashboard.dart';
import 'src/screens/messages_moderation.dart';
import 'src/screens/audit_logs.dart';
import 'src/theme.dart';

class StateLogger extends ProviderObserver {
  const StateLogger();
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print(
      '🔄 [STATE CHANGE] provider: ${provider.name ?? provider.runtimeType}, value: $newValue',
    );
  }
}

void main() {
  runApp(const ProviderScope(observers: [StateLogger()], child: AdminApp()));
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/moderation',
          builder: (_, __) => const MessagesModerationScreen(),
        ),
        GoRoute(path: '/audit', builder: (_, __) => const AuditLogsScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const DashboardScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'SyncTalk Admin',
      theme: AdminTheme.darkTheme,
      darkTheme: AdminTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
