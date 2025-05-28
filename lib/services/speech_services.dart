import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef SpeechResultCallback = void Function(String recognizedWords);
typedef SpeechStatusCallback = void Function(String status);
typedef SpeechErrorCallback = void Function(dynamic error);

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize({
    SpeechStatusCallback? onStatus,
    SpeechErrorCallback? onError,
  }) async {
    return await _speech.initialize(
      onStatus: (status) {
        if (onStatus != null) onStatus(status);
        if (status == 'notListening') _isListening = false;
      },
      onError: (error) {
        if (onError != null) onError(error);
        _isListening = false;
      },
    );
  }

  void listen({
    required SpeechResultCallback onResult,
    Duration listenFor = const Duration(minutes: 1),
    Duration pauseFor = const Duration(seconds: 3),
  }) {
    _isListening = true;
    _speech.listen(
      onResult: (val) => onResult(val.recognizedWords),
      listenFor: listenFor,
      pauseFor: pauseFor,
    );
  }

  void stop() {
    _isListening = false;
    _speech.stop();
  }
}