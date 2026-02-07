// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:nathan/constants.dart';
import 'package:nathan/models.dart';
import 'package:nathan/screens/executions.dart';
import 'package:nathan/screens/settings.dart';
import 'package:nathan/screens/workflows.dart';
import 'package:nathan/signals_adapter.dart';
import 'package:nathan/state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTabIndex = 0;

  InstanceConfig? get currentInstance {
    final idx = appState.selectedIndex.value;
    if (idx == null) return null;
    if (idx < 0 || idx >= appState.instances.value.length) return null;
    return appState.instances.value[idx];
  }

  @override
  void initState() {
    super.initState();
    appState.instances.addListener(() {
      if (appState.selectedIndex.value == null && appState.instances.value.isNotEmpty) appState.selectedIndex.value = 0;
      setState(() {});
    });
  }

  void _openSettings() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      signal: appState.selectedIndex,
      builder: (ctx, selectedIndex, child) {
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
      },
    );
  }

  Widget _buildWorkflowsTab() {
    final inst = currentInstance;
    if (inst == null) {
      return Center(child: Text('Select an instance in Settings', style: Theme.of(context).textTheme.titleMedium));
    }
    return WorkflowsScreen(instance: inst);
  }

  Widget _buildExecutionsTab() {
    final inst = currentInstance;
    if (inst == null) {
      return Center(child: Text('Select an instance in Settings', style: Theme.of(context).textTheme.titleMedium));
    }
    return ExecutionsScreen(instance: inst);
  }
}
