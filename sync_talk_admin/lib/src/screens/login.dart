
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  String? error;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(24),
              decoration: AdminTheme.glassDecoration,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.admin_panel_settings, size: 64, color: AdminTheme.primaryBlue),
                const SizedBox(height: 16),
                Text('SyncTalk Admin', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Sign in to continue', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminTheme.textSecondary)),
                const SizedBox(height: 32),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 8),
                TextField(controller: password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: loading ? null : () async {
                    setState(() { loading=true; error=null; });
                    try {
                      final resp = await api.post('/api/auth/login', data: {'email': email.text.trim(), 'password': password.text.trim()});
                      api.setToken(resp.data['accessToken']);
                      if (!context.mounted) return;
                      context.go('/dashboard');
                    } catch (e) {
                      setState(() => error = 'Login failed');
                    }
                    setState(() => loading=false);
                  },
                  child: SizedBox(width: double.infinity, child: Text(loading ? 'Please wait...' : 'Login', textAlign: TextAlign.center)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
