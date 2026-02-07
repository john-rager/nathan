// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nathan/models.dart';

class ExecutionDialog extends StatelessWidget {
  const ExecutionDialog({
    super.key,
    required this.execution,
  });

  final Execution execution;

  @override
  Widget build(BuildContext context) {
    final json = JsonEncoder.withIndent('  ').convert(execution.raw);
    return AlertDialog(
      title: const Text('Execution'),
      content: SingleChildScrollView(child: Text(json)),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    );
  }
}
