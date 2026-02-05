import 'package:flutter/material.dart';
import '../models.dart';
import '../services/api_service.dart';

class WorkflowDetailScreen extends StatefulWidget {
  final Workflow workflow;
  final String instanceUrl;
  final String apiKey;

  const WorkflowDetailScreen({
    Key? key,
    required this.workflow,
    required this.instanceUrl,
    required this.apiKey,
  }) : super(key: key);

  @override
  State<WorkflowDetailScreen> createState() => _WorkflowDetailScreenState();
}

class _WorkflowDetailScreenState extends State<WorkflowDetailScreen> {
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
      final api = ApiService(InstanceConfig(
          name: 'temp', url: widget.instanceUrl, apiKey: widget.apiKey));
      final ex = await api.fetchExecutions(workflowId: widget.workflow.id);
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

  String _fmtRelativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    final d = dt.toLocal();
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$month/$day';
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.workflow.name)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text(widget.workflow.name,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold))),
                          if (widget.workflow.active)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Text('Active',
                                  style: TextStyle(fontSize: 12, color: Colors.white)),
                            )
                        ]),
                        const SizedBox(height: 4),
                        Text(
                          'Updated ${_fmtRelativeDate(widget.workflow.updatedAt)}',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        const Text('Executions',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final e = executions[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          dense: true,
                          title: Row(children: [
                            Expanded(
                                child: Text('${_fmtDate(e.createdAt)} • ID ${e.id}',
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w500))),
                            _statusChip(e.status)
                          ]),
                          subtitle: Text('Duration: ${e.raw['executionTime'] ?? '--'}'),
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
                    childCount: executions.length,
                  ),
                )
              ]),
            ),
    );
  }
}
