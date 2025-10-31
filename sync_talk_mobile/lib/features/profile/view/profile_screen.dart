import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final displayName = TextEditingController();
  final avatarUrl = TextEditingController();
  final bio = TextEditingController();
  final status = TextEditingController();

  final currentPw = TextEditingController();
  final newPw = TextEditingController();
  final confirmPw = TextEditingController();

  bool loading = false;
  String? msg;
  String? err;

  Future<void> _saveProfile() async {
    setState(() {
      loading = true;
      msg = null;
      err = null;
    });
    try {
      final payload = <String, dynamic>{};
      if (displayName.text.trim().isNotEmpty)
        payload['displayName'] = displayName.text.trim();
      payload['avatarUrl'] = avatarUrl.text.trim();
      await dio.post('/api/users/me', data: payload);
      setState(() {
        msg = 'Profile updated';
      });
    } catch (e) {
      setState(() {
        err = 'Update failed';
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _changePassword() async {
    if (newPw.text != confirmPw.text) {
      setState(() => err = 'New passwords do not match');
      return;
    }
    setState(() {
      loading = true;
      msg = null;
      err = null;
    });
    try {
      await dio.post(
        '/api/auth/change-password',
        data: {'currentPassword': currentPw.text, 'newPassword': newPw.text},
      );
      setState(() {
        msg = 'Password changed';
      });
      currentPw.clear();
      newPw.clear();
      confirmPw.clear();
    } catch (e) {
      setState(() {
        err = 'Change password failed (enable API if missing)';
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: loading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(msg!, style: const TextStyle(color: Colors.green)),
              ),
            if (err != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(err!, style: const TextStyle(color: Colors.red)),
              ),
            const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: displayName,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: avatarUrl,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
            ),
            TextField(
              controller: bio,
              decoration: const InputDecoration(labelText: 'Bio (optional)'),
            ),
            TextField(
              controller: status,
              decoration: const InputDecoration(labelText: 'Status (optional)'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: loading ? null : _saveProfile,
              icon: const Icon(Icons.save),
              label: Text(loading ? 'Saving...' : 'Save profile'),
            ),
            const Divider(height: 32),
            const Text(
              'Security',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: currentPw,
              decoration: const InputDecoration(labelText: 'Current password'),
              obscureText: true,
            ),
            TextField(
              controller: newPw,
              decoration: const InputDecoration(labelText: 'New password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPw,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: loading ? null : _changePassword,
              icon: const Icon(Icons.lock_reset),
              label: Text(loading ? 'Updating...' : 'Change password'),
            ),
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
