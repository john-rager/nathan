// Copyright 2026 MIKA Data Services, LLC. All rights reserved.

import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime dt) {
    final formatter = DateFormat('MMM d h:mm a');
    return formatter.format(dt.toLocal());
  }

  static String formatDuration(DateTime end, DateTime start) {
    final duration = end.difference(start);
    final ms = duration.inMilliseconds;

    if (ms < 1000) {
      return '${ms}ms';
    } else if (ms < 60000) {
      final seconds = ms / 1000;
      return '${seconds.toStringAsFixed(3)}s';
    } else {
      final minutes = ms ~/ 60000;
      final remainingMs = ms % 60000;
      final seconds = remainingMs / 1000;
      return '$minutes m ${seconds.toStringAsFixed(3)}s';
    }
  }
}
