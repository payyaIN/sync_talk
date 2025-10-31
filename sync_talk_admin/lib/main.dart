
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'src/screens/login.dart';
import 'src/screens/dashboard.dart';
import 'src/screens/messages_moderation.dart';
import 'src/screens/audit_logs.dart';

void main() {
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/moderation', builder: (_, __) => const MessagesModerationScreen()),
        GoRoute(path: '/audit', builder: (_, __) => const AuditLogsScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      ],
    );
    return MaterialApp.router(
      title: 'SyncTalk Admin',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      darkTheme: ThemeData.dark(useMaterial3: true),
      routerConfig: router,
    );
  }
}
