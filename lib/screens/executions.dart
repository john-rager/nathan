// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nathan/helpers.dart';
import 'package:nathan/models.dart';
import 'package:nathan/services/api_service.dart';
import 'package:nathan/widgets/execution_dialog.dart';
import 'package:nathan/widgets/status_chip.dart';

class ExecutionsScreen extends StatefulWidget {
  final InstanceConfig instance;

  const ExecutionsScreen({Key? key, required this.instance}) : super(key: key);

  @override
  State<ExecutionsScreen> createState() => _ExecutionsScreenState();
}

class _ExecutionsScreenState extends State<ExecutionsScreen> {
  late Map<String, Workflow> workflows;
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
      final List<Workflow> wf = await api.fetchWorkflows();
      workflows = Map.fromIterable(wf, key: (w) => w.id, value: (w) => w);
      final ex = await api.fetchExecutions();
      setState(() => executions = ex);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: SafeArea(
                child: ListView.builder(
                  itemCount: executions.length,
                  itemBuilder: (ctx, i) {
                    final e = executions[i];
                    return Container(
                      decoration:
                          BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                        title: Text(workflows[e.workflowId]?.name ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Row(children: [
                          Text(Helpers.formatDate(e.startedAt)),
                          Text(' • ID ${e.id} • ${Helpers.formatDuration(e.stoppedAt, e.startedAt)}'),
                          if (e.mode == 'manual') ...[
                            SizedBox(
                              width: 6,
                            ),
                            Icon(Symbols.experiment, size: 12)
                          ]
                        ]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Add this line
                          children: [
                            StatusChip(status: e.status),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => ExecutionDialog(execution: e),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
  }
}
