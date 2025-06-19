import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chefspeaks/services/wakeup_service.dart';

final wakeupServiceProvider = Provider<WakeupService>((ref) {
  return WakeupService();
});

final isListeningProvider = StateProvider<bool>((ref) => false);