import 'package:flutter/material.dart';

class CommandHandler {
  static Future<void> handle({
    required String command,
    required Map<String, VoidCallback> callbacks,
  }) async {
    final cmd = command.toLowerCase();

    if (cmd.contains('continue')) {
      callbacks['continue']?.call();
    } else if (cmd.contains('next')) {
      callbacks['next']?.call();
    } else if (cmd.contains('prev') || cmd.contains('previous')) {
      callbacks['prev']?.call();
    } else if (cmd.contains('start timer')) {
      callbacks['start_timer']?.call();
    } else if (cmd.contains('pause timer')) {
      callbacks['pause_timer']?.call();
    } else if (cmd.contains('reset timer')) {
      callbacks['reset_timer']?.call();
    } else {
      debugPrint('Unknown command: $command');
    }
  }
}
