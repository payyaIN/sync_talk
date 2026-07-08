
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../api.dart';
import '../theme.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});
  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  List items = [];
  bool loading = true;
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    try {
      final resp = await api.get('/api/audit');
      setState(()=> items = resp.data as List);
    } catch (_) {}
    setState(()=> loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.history, color: AdminTheme.primaryBlue),
            const SizedBox(width: 12),
            Text('Audit Logs', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      body: loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: AdminTheme.glassDecoration,
          child: DataTable2(
            headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
            columnSpacing: 12,
            horizontalMargin: 12,
          columns: const [
            DataColumn2(label: Text('Time')),
            DataColumn2(label: Text('Actor')),
            DataColumn2(label: Text('Action')),
            DataColumn2(label: Text('Target'), size: ColumnSize.L),
          ],
          rows: items.map<DataRow>((a) => DataRow(cells: [
            DataCell(Text(a['createdAt']?.toString().replaceFirst('T',' ').split('.').first ?? '')),
            DataCell(Text(a['actor'] ?? '')),
            DataCell(Text(a['action'] ?? '')),
            DataCell(Text(a['target'] ?? '')),
          ])).toList(),
          ),
        ),
      ),
    );
  }
}
