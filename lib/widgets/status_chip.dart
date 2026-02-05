// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final statuses = {
      'unknown': (color: Colors.grey, icon: Symbols.help_outline, label: 'Unknown'),
      'canceled': (color: Colors.red, icon: Symbols.cancel, label: 'Canceled'),
      'crashed': (color: Colors.red, icon: Symbols.cancel, label: 'Crashed'),
      'error': (color: Colors.red, icon: Symbols.cancel, label: 'Error'),
      'new': (color: Colors.amber, icon: Symbols.schedule, label: 'New'),
      'running': (color: Colors.amber, icon: Symbols.schedule, label: 'Running'),
      'waiting': (color: Colors.amber, icon: Symbols.schedule, label: 'Waiting'),
      'success': (color: Colors.green, icon: Symbols.check_circle, label: 'Success'),
    };
    final s = status.toLowerCase();
    final chipContent = statuses[s] ?? statuses['unknown']!;

    return Container(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          chipContent.icon,
          size: 14,
          color: chipContent.color,
          fill: 1,
        ),
        const SizedBox(width: 6),
        Text(chipContent.label)
      ]),
    );
  }
}
