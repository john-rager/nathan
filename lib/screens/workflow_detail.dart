// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nathan/helpers.dart';
import 'package:nathan/models.dart';
import 'package:nathan/services/api_service.dart';
import 'package:nathan/widgets/published_chip.dart';
import 'package:nathan/widgets/status_chip.dart';

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
      final api = ApiService(InstanceConfig(name: 'temp', url: widget.instanceUrl, apiKey: widget.apiKey));
      final ex = await api.fetchExecutions(workflowId: widget.workflow.id);
      setState(() => executions = ex);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.workflow.name)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: loading
            ? SafeArea(child: const Center(child: CircularProgressIndicator()))
            : RefreshIndicator(
                onRefresh: _refresh,
                child: SafeArea(
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
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                              if (widget.workflow.active) PublishedChip(context: context)
                            ]),
                            const SizedBox(height: 4),
                            Text(
                              'Updated ${_fmtRelativeDate(widget.workflow.updatedAt)}',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            const Text('Executions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final e = executions[i];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              dense: true,
                              title: Row(children: [
                                Expanded(
                                    child: Row(
                                  children: [
                                    Text('${Helpers.formatDate(e.startedAt)} • ID ${e.id}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                    if (e.mode == 'manual') ...[
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Icon(Symbols.experiment, size: 12)
                                    ]
                                  ],
                                )),
                                StatusChip(status: e.status)
                              ]),
                              subtitle: Text(Helpers.formatDuration(e.stoppedAt, e.startedAt)),
                              trailing: IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            title: const Text('Execution'),
                                            content: SingleChildScrollView(child: Text(e.raw.toString())),
                                            actions: [
                                              TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
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
              ));
  }
}
