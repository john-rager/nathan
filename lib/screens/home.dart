// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:nathan/constants.dart';
import 'package:nathan/models.dart';
import 'package:nathan/screens/executions.dart';
import 'package:nathan/screens/settings.dart';
import 'package:nathan/screens/workflow_detail.dart';
import 'package:nathan/services/api_service.dart';
import 'package:nathan/state.dart';
import 'package:nathan/widgets/published_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Workflow> workflows = [];
  bool loading = false;
  int currentTabIndex = 0;

  InstanceConfig? get currentInstance {
    final idx = appState.selectedIndex.value;
    if (idx == null) return null;
    if (idx < 0 || idx >= appState.instances.value.length) return null;
    return appState.instances.value[idx];
  }

  Future<void> _refreshWorkflows() async {
    final inst = currentInstance;
    if (inst == null) return;
    setState(() => loading = true);
    try {
      final api = ApiService(inst);
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

  @override
  void initState() {
    super.initState();
    appState.selectedIndex.addListener(() {
      _refreshWorkflows();
    });
    appState.instances.addListener(() {
      if (appState.selectedIndex.value == null && appState.instances.value.isNotEmpty) appState.selectedIndex.value = 0;
      setState(() {});
    });
    _refreshWorkflows();
  }

  void _openSettings() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    if (appState.selectedIndex.value != null) _refreshWorkflows();
  }

  void _selectWorkflow(Workflow w) {
    final inst = currentInstance;
    if (inst == null) return;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WorkflowDetailScreen(workflow: w, instanceUrl: inst.url, apiKey: inst.apiKey)));
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appTitle),
            if (currentInstance != null)
              Text(
                currentInstance!.name,
                style: Theme.of(context).textTheme.labelMedium,
              )
          ],
        ),
        actions: [IconButton(onPressed: _openSettings, icon: const Icon(Icons.settings))],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: currentTabIndex == 0 ? _buildWorkflowsTab() : _buildExecutionsTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Workflows'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Executions')
        ],
        onTap: (idx) => setState(() => currentTabIndex = idx),
      ),
    );
  }

  Widget _buildWorkflowsTab() {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refreshWorkflows,
            child: SafeArea(
              child: CustomScrollView(slivers: [
                SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, i) => _workflowCard(workflows[i]),
                        childCount: workflows.length))
              ]),
            ),
          );
  }

  Widget _buildExecutionsTab() {
    final inst = currentInstance;
    if (inst == null) {
      return Center(child: Text('Select an instance', style: Theme.of(context).textTheme.titleMedium));
    }
    return ExecutionsScreen(instance: inst);
  }
}
