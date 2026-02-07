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
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(isNew ? 'Add Instance' : 'Edit Instance'),
            content: SizedBox(
              width: screenWidth * 0.9,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(children: [
                    TextFormField(
                      controller: nameCtl,
                      decoration: const InputDecoration(labelText: 'Name'),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: urlCtl,
                      decoration: const InputDecoration(labelText: 'URL'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'URL is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: keyCtl,
                      decoration: const InputDecoration(labelText: 'API Key'),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'API Key is required';
                        }
                        return null;
                      },
                    ),
                  ]),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final cfg = InstanceConfig(
                        name: nameCtl.text.trim(),
                        url: urlCtl.text.trim(),
                        apiKey: keyCtl.text.trim(),
                      );
                      if (isNew)
                        appState.addInstance(cfg);
                      else
                        appState.updateInstance(idx, cfg);
                      Navigator.of(ctx).pop();
                      setState(() {});
                    }
                  },
                  child: const Text('Save'))
            ],
          );
        });
  }

  void _showDeleteConfirmation(int index) {
    final instanceName = appState.instances.value[index].name;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Instance?'),
        content: Text('Are you sure you want to delete "$instanceName"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () {
              appState.removeInstance(index);
              setState(() {});
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
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
                          onPressed: () => _showDeleteConfirmation(i),
                        ),
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
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showEditor(),
        ));
  }
}
