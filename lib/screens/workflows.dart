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
  bool _showPublishedOnly = false;
  String _sortBy = 'updated';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          dense: true,
          title: Row(children: [
            Expanded(child: Text(w.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            if (w.active) PublishedChip(context: context)
          ]),
          subtitle: Text('Updated ${_fmtRelativeDate(w.updatedAt)}', style: TextStyle(color: Colors.grey.shade400)),
          onTap: () => _selectWorkflow(w),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tbTextStyle = TextStyle(fontSize: 14);
    var filteredWorkflows = _showPublishedOnly ? workflows.where((w) => w.active).toList() : workflows;

    filteredWorkflows.sort((a, b) {
      if (_sortBy == 'name') {
        return a.name.compareTo(b.name);
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refresh,
            child: SafeArea(
              child: CustomScrollView(slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilterChip(
                          label: Text(
                            _showPublishedOnly
                                ? 'Published (${workflows.where((w) => w.active).length})'
                                : 'All (${workflows.length})',
                          ),
                          labelStyle: tbTextStyle,
                          selected: _showPublishedOnly,
                          onSelected: (value) => setState(() => _showPublishedOnly = value),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SizedBox(
                            height: 32,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                items: [
                                  DropdownMenuItem(value: 'updated', child: Text('Updated', style: tbTextStyle)),
                                  DropdownMenuItem(value: 'name', child: Text('Name', style: tbTextStyle)),
                                ],
                                onChanged: (value) => setState(() => _sortBy = value!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _workflowCard(filteredWorkflows[i]),
                    childCount: filteredWorkflows.length,
                  ),
                ),
              ]),
            ),
          );
  }
}
