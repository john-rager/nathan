// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nathan/helpers.dart';
import 'package:nathan/models.dart';
import 'package:nathan/widgets/execution_dialog.dart';
import 'package:nathan/widgets/status_chip.dart';

class ExecutionsList extends StatelessWidget {
  final List<Execution> executions;

  const ExecutionsList({super.key, required this.executions});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) {
          final e = executions[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                title: Row(
                  children: [
                    Text('${Helpers.formatDate(e.startedAt)} • ID ${e.id}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    if (e.mode == 'manual') ...[
                      SizedBox(
                        width: 6,
                      ),
                      Icon(Symbols.experiment, size: 12)
                    ]
                  ],
                ),
                subtitle: Text(Helpers.formatDuration(e.stoppedAt, e.startedAt)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusChip(status: e.status),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => ExecutionDialog(execution: e),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: executions.length,
      ),
    );
  }
}
