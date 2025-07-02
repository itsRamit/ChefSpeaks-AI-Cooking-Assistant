import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chefspeaks/services/stt_services.dart';
import 'package:chefspeaks/services/wakeup_service.dart';

final speechServiceProvider = Provider<SpeechService>((ref) {
  final stt = SpeechService(); // or whatever your class is
  ref.onDispose(() => stt.stop()); // good practice
  return stt;
});


final wakeupServiceProvider = Provider<WakeupService>((ref) {
  return WakeupService();
});

final isListeningProvider = StateProvider<bool>((ref) => false);
