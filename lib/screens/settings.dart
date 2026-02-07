// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:nathan/models.dart';
import 'package:nathan/signals_adapter.dart';
import 'package:nathan/state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showEditor([int? idx]) {
    final isNew = idx == null;
    final nameCtl = TextEditingController(text: idx != null ? appState.instances.value[idx].name : '');
    final urlCtl = TextEditingController(text: idx != null ? appState.instances.value[idx].url : '');
    final keyCtl = TextEditingController(text: idx != null ? appState.instances.value[idx].apiKey : '');
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(isNew ? 'Add Instance' : 'Edit Instance'),
            content: SizedBox(
              width: screenWidth * 0.9,
              child: SingleChildScrollView(
                child: Column(children: [
                  TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name'), autofocus: true),
                  TextField(controller: urlCtl, decoration: const InputDecoration(labelText: 'URL')),
                  TextField(
                    controller: keyCtl,
                    decoration: const InputDecoration(labelText: 'API Key'),
                    maxLines: 5,
                  ),
                ]),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    final cfg =
                        InstanceConfig(name: nameCtl.text.trim(), url: urlCtl.text.trim(), apiKey: keyCtl.text.trim());
                    if (isNew)
                      appState.addInstance(cfg);
                    else
                      appState.updateInstance(idx, cfg);
                    Navigator.of(ctx).pop();
                    setState(() {});
                  },
                  child: const Text('Save'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Expanded(
              child: SignalBuilder<List<InstanceConfig>>(
                signal: appState.instances,
                builder: (ctx, list, child) {
                  if (list.isEmpty) return const Center(child: Text('No instances configured.'));
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final it = list[i];
                      return ListTile(
                        title: Text(it.name),
                        subtitle: Text(it.url),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditor(i)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                appState.removeInstance(i);
                                setState(() {});
                              }),
                        ]),
                        onTap: () {
                          appState.selectedIndex.value = i;
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showEditor(),
        ));
  }
}
