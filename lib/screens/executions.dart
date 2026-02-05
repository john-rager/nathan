import 'package:flutter/material.dart';
import '../models.dart';
import '../services/api_service.dart';

class ExecutionsScreen extends StatefulWidget {
  final InstanceConfig instance;

  const ExecutionsScreen({Key? key, required this.instance}) : super(key: key);

  @override
  State<ExecutionsScreen> createState() => _ExecutionsScreenState();
}

class _ExecutionsScreenState extends State<ExecutionsScreen> {
  List<Execution> executions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    try {
      final api = ApiService(widget.instance);
      final ex = await api.fetchExecutions();
      setState(() => executions = ex);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  String _fmtDate(DateTime dt) {
    final d = dt.toLocal();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$mm/$dd $hh:$mi';
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase();
    Color c = Colors.grey;
    IconData icon = Icons.help_outline;
    if (s.contains('success') || s.contains('finished') || s.contains('ok')) {
      c = Colors.green.shade400;
      icon = Icons.check_circle;
    } else if (s.contains('error') || s.contains('failed')) {
      c = Colors.red.shade400;
      icon = Icons.error;
    } else if (s.contains('running')) {
      c = Colors.orange.shade400;
      icon = Icons.play_circle;
    }
    final int rr = (c.r * 255.0).round();
    final int gg = (c.g * 255.0).round();
    final int bb = (c.b * 255.0).round();
    final bg = Color.fromARGB((0.12 * 255).round(), rr, gg, bb);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 6),
        Text(status, style: TextStyle(color: c))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: executions.length,
              itemBuilder: (ctx, i) {
                final e = executions[i];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    dense: true,
                    title: Row(children: [
                      Expanded(
                          child: Text(
                              e.raw['workflowName'] ?? e.workflowId ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600))),
                      _statusChip(e.status)
                    ]),
                    subtitle: Row(children: [
                      Text(_fmtDate(e.createdAt)),
                      const SizedBox(width: 8),
                      Text(' • ID ${e.id}')
                    ]),
                    trailing: IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  title: const Text('Execution'),
                                  content: SingleChildScrollView(
                                      child: Text(e.raw.toString())),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Close'))
                                  ],
                                ))),
                  ),
                );
              },
            ),
          );
  }
}
