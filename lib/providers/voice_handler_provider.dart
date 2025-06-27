import 'dart:async';
import 'dart:developer';

import 'package:chefspeaks/providers/wakeup_service_provider.dart';
import 'package:chefspeaks/services/tts_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final activeScreenProvider = StateProvider<String>((ref) => 'home');

typedef VoiceCallback = void Function(String text);
final screenCallbackProvider = StateProvider<VoiceCallback?>((ref) => null);

final voiceHandlerProvider = Provider<VoiceHandler>((ref) {
  return VoiceHandler(ref);
});

final ttsServiceProvider = Provider<TTSService>((ref) {
  final tts = TTSService();
  tts.init();
  ref.onDispose(() => tts.dispose());
  return tts;
});

class VoiceHandler {
  final Ref ref;
  Timer? _debounceTimer;

  VoiceHandler(this.ref);

  Future<void> handleWakeAndListen() async {
    final wakeupService = ref.read(wakeupServiceProvider);
    final sttService = ref.read(speechServiceProvider);

    await wakeupService.pause();

    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      return;
    }

    if (ref.read(isListeningProvider)) return;

    final success = await sttService.initialize(
      onStatus: (status) async {
        if (status == 'notListening') {
          ref.read(isListeningProvider.notifier).state = false;
          await wakeupService.resume();
        }
      },
      onError: (error) {
        log("STT Error: $error");
        ref.read(isListeningProvider.notifier).state = false;
      },
    );

    if (!success) return;

    ref.read(isListeningProvider.notifier).state = true;
    final tts = ref.read(ttsServiceProvider);
    tts.stop();
    sttService.listen(onResult: (words) async {
      final text = words.trim();
      if (text.isEmpty) return;

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 1), () {
        final callback = ref.read(screenCallbackProvider);
        if (callback != null) {
          callback(text);
        }
      });
    });
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
