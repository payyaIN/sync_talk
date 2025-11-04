import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import '../api.dart';

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
    await api.post('/api/users/${id}/${banned ? 'ban' : 'unban'}');
    await load();
  }

  Future<void> setRole(String id, String role) async {
    await api.post('/api/users/${id}/role', data: {'role': role});
    await load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/moderation'),
            child: const Text(
              'Moderation',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/audit'),
            child: const Text('Audit', style: TextStyle(color: Colors.white)),
          ),
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
                  const Text(
                    'Users',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: DataTable2(
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
                  const Text(
                    'Conversations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: convos.length,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
