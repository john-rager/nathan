// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:nathan/models.dart';
import 'package:nathan/services/api_service.dart';
import 'package:nathan/widgets/executions_list.dart';

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
    final tbTextStyle = TextStyle(fontSize: 14);
    var filteredExecutions = _showErrorOnly ? executions.where((e) => e.status == 'error').toList() : executions;
    filteredExecutions =
        _showTriggeredOnly ? filteredExecutions.where((e) => e.mode == 'trigger').toList() : filteredExecutions;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SafeArea(
                child: CustomScrollView(slivers: [
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
                  ExecutionsList(executions: filteredExecutions, workflows: workflows),
                ]),
              ),
            ),
    );
  }
}
