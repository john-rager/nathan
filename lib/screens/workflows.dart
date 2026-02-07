// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:nathan/models.dart';
import 'package:nathan/screens/workflow_detail.dart';
import 'package:nathan/services/api_service.dart';
import 'package:nathan/widgets/published_chip.dart';

class WorkflowsScreen extends StatefulWidget {
  final InstanceConfig instance;

  const WorkflowsScreen({super.key, required this.instance});

  @override
  State<WorkflowsScreen> createState() => _WorkflowsScreenState();
}

class _WorkflowsScreenState extends State<WorkflowsScreen> {
  List<Workflow> workflows = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    try {
      final api = ApiService(widget.instance);
      final wf = await api.fetchWorkflows();
      setState(() {
        workflows = wf;
        workflows.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      print('API Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  void _selectWorkflow(Workflow w) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WorkflowDetailScreen(
              workflow: w,
              instanceUrl: widget.instance.url,
              apiKey: widget.instance.apiKey,
            )));
  }

  String _fmtRelativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    final d = dt.toLocal();
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$month/$day';
  }

  Widget _workflowCard(Workflow w) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        dense: true,
        title: Row(children: [
          Expanded(child: Text(w.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          if (w.active) PublishedChip(context: context)
        ]),
        subtitle: Text('Updated ${_fmtRelativeDate(w.updatedAt)}', style: TextStyle(color: Colors.grey.shade400)),
        onTap: () => _selectWorkflow(w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refresh,
            child: SafeArea(
              child: CustomScrollView(slivers: [
                SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, i) => _workflowCard(workflows[i]),
                        childCount: workflows.length))
              ]),
            ),
          );
  }
}
