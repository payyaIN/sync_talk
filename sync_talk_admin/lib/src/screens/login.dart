
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api.dart';

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('SyncTalk Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 8),
                TextField(controller: password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: loading ? null : () async {
                    setState(()=>{loading=true,error=null});
                    try {
                      final resp = await api.post('/api/auth/login', data: {'email': email.text.trim(), 'password': password.text.trim()});
                      api.setToken(resp.data['accessToken']);
                      if (mounted) context.go('/dashboard');
                    } catch (e) {
                      setState(()=> error = 'Login failed');
                    }
                    setState(()=>loading=false);
                  },
                  child: Text(loading ? '...' : 'Login'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
