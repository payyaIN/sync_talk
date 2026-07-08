import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_talk_mobile/core/services/sockets.dart';
import 'package:sync_talk_mobile/main.dart';
import '../../../core/services/api.dart';
import '../../../core/services/session.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? user;
  bool loading = true;
  String? error;

  // Privacy preferences
  bool _readReceipts = true;
  String _lastSeenOption = 'Everyone';

  // Notification preferences
  bool _msgNotifications = true;
  bool _groupNotifications = true;
  bool _inAppSounds = true;

  // Storage preferences
  bool _autoDownloadData = false;
  bool _autoDownloadWifi = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await dio.get('/users/me');
      if (mounted) {
        setState(() {
          user = res.data;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          loading = false;
        });
      }
    }
  }

  Future<void> _updateProfile(String name, String? avatar) async {
    setState(() => loading = true);
    try {
      await dio.post(
        '/users/me',
        data: {
          'displayName': name,
          if (avatar != null) 'avatarUrl': avatar,
        },
      );
      await _loadProfile();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to update profile: $e';
          loading = false;
        });
      }
    }
  }

  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: user?['displayName']);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != user?['displayName']) {
      await _updateProfile(newName, null);
    }
  }

  Future<void> _showAccountSettings() async {
    final emailController = TextEditingController(text: user?['email']);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Change Email Address', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Danger Zone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text('Warning! This will permanently delete your account. This action cannot be undone. Proceed?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      setState(() => loading = true);
                      await dio.post('/users/me/delete');
                    } catch (_) {}
                    await session.clear();
                    sockets.disconnect();
                    if (mounted) context.go('/login');
                  }
                },
                child: const Text('Delete Account'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              if (newEmail.isNotEmpty && newEmail.contains('@') && newEmail != user?['email']) {
                Navigator.pop(context);
                setState(() => loading = true);
                try {
                  await dio.post('/users/me', data: {'email': newEmail});
                  await _loadProfile();
                } catch (e) {
                  setState(() => error = 'Failed to update email: $e');
                }
              }
            },
            child: const Text('Save Email'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrivacySettings() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Privacy Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Read Receipts'),
                subtitle: const Text('If turned off, you won\'t send or receive Read Receipts.'),
                value: _readReceipts,
                activeColor: Colors.blue,
                onChanged: (val) {
                  setDialogState(() => _readReceipts = val);
                  setState(() => _readReceipts = val);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Last Seen status'),
                subtitle: Text(_lastSeenOption),
                trailing: PopupMenuButton<String>(
                  initialValue: _lastSeenOption,
                  onSelected: (val) {
                    setDialogState(() => _lastSeenOption = val);
                    setState(() => _lastSeenOption = val);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Everyone', child: Text('Everyone')),
                    const PopupMenuItem(value: 'My Contacts', child: Text('My Contacts')),
                    const PopupMenuItem(value: 'Nobody', child: Text('Nobody')),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  Future<void> _showChatsSettings() async {
    final currentThemeMode = ref.read(themeModeProvider);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System default'),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              activeColor: Colors.blue,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).state = val;
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              activeColor: Colors.blue,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).state = val;
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              activeColor: Colors.blue,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).state = val;
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotificationsSettings() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Notification Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Message Notifications'),
                subtitle: const Text('Show notifications for incoming messages'),
                value: _msgNotifications,
                activeColor: Colors.blue,
                onChanged: (val) {
                  setDialogState(() => _msgNotifications = val);
                  setState(() => _msgNotifications = val);
                },
              ),
              SwitchListTile(
                title: const Text('Group Notifications'),
                subtitle: const Text('Show notifications for group chats'),
                value: _groupNotifications,
                activeColor: Colors.blue,
                onChanged: (val) {
                  setDialogState(() => _groupNotifications = val);
                  setState(() => _groupNotifications = val);
                },
              ),
              SwitchListTile(
                title: const Text('In-App Sounds'),
                subtitle: const Text('Play sounds for incoming alerts'),
                value: _inAppSounds,
                activeColor: Colors.blue,
                onChanged: (val) {
                  setDialogState(() => _inAppSounds = val);
                  setState(() => _inAppSounds = val);
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  Future<void> _showStorageSettings() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Storage and Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Media auto-download over Mobile Data'),
                value: _autoDownloadData,
                activeColor: Colors.blue,
                onChanged: (val) {
                  setDialogState(() => _autoDownloadData = val);
                  setState(() => _autoDownloadData = val);
                },
              ),
              SwitchListTile(
                title: const Text('Media auto-download over Wi-Fi'),
                value: _autoDownloadWifi,
                activeColor: Colors.blue,
                onChanged: (val) {
                  setDialogState(() => _autoDownloadWifi = val);
                  setState(() => _autoDownloadWifi = val);
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  Future<void> _showHelpSettings() async {
    final contactController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('App Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('SyncTalk for Android/iOS\nVersion 1.2.1\nBuild 2026.07.08\n© 2026 SyncTalk Inc.'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text('Contact Us / Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: contactController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe your issue or feedback...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              final query = contactController.text.trim();
              if (query.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you! Our support team has received your ticket.'), backgroundColor: Colors.blue),
                );
              }
            },
            child: const Text('Submit Ticket'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await session.clear();
      sockets.disconnect(); // Disconnect presence socket
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(" ").where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    return parts.map((e) => e[0]).take(2).join().toUpperCase();
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.blue).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.blue, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.blue[300]! : Colors.blue[800]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Profile Card (WhatsApp Style)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: _showEditNameDialog,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: primaryColor,
                                    backgroundImage: user?['avatarUrl'] != null && user!['avatarUrl'].isNotEmpty
                                        ? NetworkImage(user!['avatarUrl'])
                                        : null,
                                    child: user?['avatarUrl'] == null || user!['avatarUrl'].isEmpty
                                        ? Text(
                                            _getInitials(user?['displayName'] ?? user?['email'] ?? 'U'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                user?['displayName'] ?? user?['email'] ?? 'User',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: primaryColor.withOpacity(0.8),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user?['email'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Status: Available",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Divider(),

                      // Settings Options List
                      _buildSettingsTile(
                        icon: Icons.key,
                        title: "Account",
                        subtitle: "Security notifications, change email, delete account",
                        iconColor: Colors.blue[700],
                        onTap: _showAccountSettings,
                      ),
                      _buildSettingsTile(
                        icon: Icons.lock_outline,
                        title: "Privacy",
                        subtitle: "Block list, last seen, read receipts status",
                        iconColor: Colors.blue[700],
                        onTap: _showPrivacySettings,
                      ),
                      _buildSettingsTile(
                        icon: Icons.chat_outlined,
                        title: "Chats",
                        subtitle: "Theme, chat wallpapers, messages history",
                        iconColor: Colors.blue[700],
                        onTap: _showChatsSettings,
                      ),
                      _buildSettingsTile(
                        icon: Icons.notifications_none,
                        title: "Notifications",
                        subtitle: "Message, groups & call rings, sound settings",
                        iconColor: Colors.blue[700],
                        onTap: _showNotificationsSettings,
                      ),
                      _buildSettingsTile(
                        icon: Icons.data_usage,
                        title: "Storage and Data",
                        subtitle: "Network usage, auto-download files & assets",
                        iconColor: Colors.blue[700],
                        onTap: _showStorageSettings,
                      ),
                      _buildSettingsTile(
                        icon: Icons.help_outline,
                        title: "Help",
                        subtitle: "Help center, contact us, privacy policy & terms",
                        iconColor: Colors.blue[700],
                        onTap: _showHelpSettings,
                      ),

                      const Divider(height: 24),

                      // Logout button
                      _buildSettingsTile(
                        icon: Icons.logout,
                        title: "Log Out",
                        subtitle: "Sign out of your account on this device",
                        iconColor: Colors.red[400],
                        textColor: Colors.red[400],
                        onTap: _handleLogout,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
