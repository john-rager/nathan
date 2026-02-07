// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:nathan/models.dart';
import 'package:nathan/services/api_service.dart';
import 'package:nathan/widgets/executions_list.dart';
import 'package:nathan/widgets/published_chip.dart';

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
  bool _showErrorOnly = false;
  bool _showTriggeredOnly = false;

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
    final tbTextStyle = TextStyle(fontSize: 14);
    var filteredExecutions = _showErrorOnly ? executions.where((e) => e.status == 'error').toList() : executions;
    filteredExecutions =
        _showTriggeredOnly ? filteredExecutions.where((e) => e.mode == 'trigger').toList() : filteredExecutions;

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
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
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
                          const Text('Executions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FilterChip(
                            label: Text(
                              _showTriggeredOnly
                                  ? 'Triggered (${filteredExecutions.where((e) => e.mode == 'trigger').length})'
                                  : 'All (${filteredExecutions.length})',
                            ),
                            labelStyle: tbTextStyle,
                            selected: _showTriggeredOnly,
                            onSelected: (value) => setState(() => _showTriggeredOnly = value),
                          ),
                          SizedBox(width: 6),
                          FilterChip(
                            label: Text(
                              _showErrorOnly
                                  ? 'Error (${filteredExecutions.where((e) => e.status == 'error').length})'
                                  : 'All (${filteredExecutions.length})',
                            ),
                            labelStyle: tbTextStyle,
                            selected: _showErrorOnly,
                            onSelected: (value) => setState(() => _showErrorOnly = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ExecutionsList(executions: filteredExecutions)
                ]),
              ),
            ),
    );
  }
}
