import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List users = [];
  List convos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final u = await api.get('/api/users');
      final c = await api.get('/api/conversations');
      setState(() {
        users = u.data;
        convos = c.data;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> banUser(String id, bool banned) async {
    await api.post('/api/users/$id/${banned ? 'ban' : 'unban'}');
    await load();
  }

  Future<void> setRole(String id, String role) async {
    await api.post('/api/users/$id/role', data: {'role': role});
    await load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: AdminTheme.primaryBlue),
            const SizedBox(width: 12),
            Text('SyncTalk Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/moderation'),
            icon: const Icon(Icons.security, size: 20),
            label: const Text('Moderation'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/audit'),
            icon: const Icon(Icons.history, size: 20),
            label: const Text('Audit Logs'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Users Management', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: AdminTheme.glassDecoration,
                      child: DataTable2(
                        headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        columns: const [
                        DataColumn2(label: Text('ID')),
                        DataColumn2(label: Text('Name')),
                        DataColumn2(label: Text('Email')),
                        DataColumn2(label: Text('Role')),
                        DataColumn2(label: Text('Banned')),
                        DataColumn2(label: Text('Actions')),
                      ],
                      rows: users
                          .map<DataRow>(
                            (u) => DataRow(
                              cells: [
                                DataCell(Text(u['id'] ?? '')),
                                DataCell(Text(u['displayName'] ?? '')),
                                DataCell(Text(u['email'] ?? '')),
                                DataCell(Text(u['role'] ?? 'user')),
                                DataCell(
                                  Text((u['banned'] ?? false).toString()),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => setRole(
                                          u['id'],
                                          (u['role'] ?? 'user') == 'admin'
                                              ? 'user'
                                              : 'admin',
                                        ),
                                        child: const Text('Toggle Role'),
                                      ),
                                      TextButton(
                                        onPressed: () => banUser(
                                          u['id'],
                                          !(u['banned'] ?? false),
                                        ),
                                        child: Text(
                                          (u['banned'] ?? false)
                                              ? 'Unban'
                                              : 'Ban',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey.shade400),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Conversations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: AdminTheme.glassDecoration,
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        itemCount: convos.length,
                        separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      itemBuilder: (_, i) {
                        final c = convos[i];
                        return ListTile(
                          title: Text(c['title']?.toString() ?? 'Conversation'),
                          subtitle: Text(
                            'Members: ${c['participants']?.length ?? 0}',
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}
