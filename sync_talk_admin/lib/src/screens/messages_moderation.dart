
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../api.dart';
import '../theme.dart';

class MessagesModerationScreen extends StatefulWidget {
  const MessagesModerationScreen({super.key});
  @override
  State<MessagesModerationScreen> createState() => _MessagesModerationScreenState();
}

class _MessagesModerationScreenState extends State<MessagesModerationScreen> {
  final convCtrl = TextEditingController();
  List items = [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    final id = convCtrl.text.trim();
    if (id.isEmpty) return;
    setState(() { loading=true; error=null; });
    try {
      final resp = await api.get('/api/messages/$id');
      final data = resp.data['items'] ?? [];
      setState(()=> items = data);
    } catch (e) {
      setState(()=> error = 'Failed to load messages');
    }
    setState(()=> loading = false);
  }

  Future<void> deleteMessage(String id) async {
    try {
      await api.dio.delete('/api/messages/$id');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message deleted')));
      await load();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.security, color: AdminTheme.primaryPurple),
            const SizedBox(width: 12),
            Text('Messages Moderation', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: convCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Conversation ID',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: loading ? null : load,
                icon: const Icon(Icons.download),
                label: Text(loading ? 'Loading...' : 'Load Messages'),
              ),
            ]),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: AdminTheme.glassDecoration,
                child: DataTable2(
                  headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                columns: const [
                  DataColumn2(label: Text('ID'), size: ColumnSize.L),
                  DataColumn2(label: Text('Sender')),
                  DataColumn2(label: Text('Content'), size: ColumnSize.L),
                  DataColumn2(label: Text('Created')),
                  DataColumn2(label: Text('Actions')),
                ],
                rows: items.map<DataRow>((m) => DataRow(cells: [
                  DataCell(Text(m['id'] ?? '')),
                  DataCell(Text(m['sender']?.toString() ?? '')),
                  DataCell(Text((m['content'] ?? '').toString())),
                  DataCell(Text(m['createdAt'] ?? '')),
                  DataCell(Row(children: [
                    IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                      final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                        title: const Text('Delete message?'),
                        content: Text('Message ID: ${m['id']}'),
                        actions: [ TextButton(onPressed: ()=> Navigator.pop(context,false), child: const Text('Cancel')), FilledButton(onPressed: ()=> Navigator.pop(context,true), child: const Text('Delete')) ],
                      )) ?? false;
                      if (ok) await deleteMessage(m['id']);
                    }),
                  ])),
                ])).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
