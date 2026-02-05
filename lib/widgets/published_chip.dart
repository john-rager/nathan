// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:flutter/material.dart';

class PublishedChip extends StatelessWidget {
  const PublishedChip({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final fgColor = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(
            color: fgColor,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
          ),
          SizedBox(width: 6),
          Text('Published', style: TextStyle(fontSize: 12, color: fgColor)),
        ],
      ),
    );
  }
}
