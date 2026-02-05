// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'dart:convert';
import 'package:nathan/models.dart';
import 'package:nathan/signals_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  final ListSignal<InstanceConfig> instances = ListSignal<InstanceConfig>([]);
  final Signal<int?> _selectedIndex = Signal<int?>(null);

  Signal<int?> get selectedIndex => _selectedIndex;

  AppState() {
    _selectedIndex.addListener(() => save());
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('nathan_instances');
    if (raw != null) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      instances.value = list.map((j) => InstanceConfig.fromJson(j)).toList();
    }
    final sel = sp.getInt('nathan_selected');
    _selectedIndex.value = sel;
  }

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();
    final raw = instances.value.map((i) => i.toJson()).toList();
    await sp.setString('nathan_instances', json.encode(raw));
    if (_selectedIndex.value != null) await sp.setInt('nathan_selected', _selectedIndex.value!);
  }

  void addInstance(InstanceConfig c) {
    instances.value = [...instances.value, c];
    save();
  }

  void updateInstance(int idx, InstanceConfig c) {
    final copy = [...instances.value];
    copy[idx] = c;
    instances.value = copy;
    save();
  }

  void removeInstance(int idx) {
    final copy = [...instances.value]..removeAt(idx);
    instances.value = copy;
    if (_selectedIndex.value != null && _selectedIndex.value! >= copy.length) _selectedIndex.value = null;
    save();
  }
}

final appState = AppState();
