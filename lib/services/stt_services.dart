import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef SpeechResultCallback = void Function(String recognizedWords);
typedef SpeechStatusCallback = void Function(String status);
typedef SpeechErrorCallback = void Function(dynamic error);

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _initialized = false;

  bool get isListening => _isListening;

  Future<bool> initialize({
    SpeechStatusCallback? onStatus,
    SpeechErrorCallback? onError,
  }) async {
    if (_initialized) return true;

    final result = await _speech.initialize(
      onStatus: (status) {
        onStatus?.call(status);
        if (status == 'notListening') _isListening = false;
      },
      onError: (error) {
        onError?.call(error);
        _isListening = false;
      },
    );

    _initialized = result;
    return result;
  }

  void listen({
    required SpeechResultCallback onResult,
    Duration listenFor = const Duration(minutes: 1),
    Duration pauseFor = const Duration(seconds: 3),
  }) {
    if (_speech.isAvailable) {
      _isListening = true;
      _speech.listen(
        onResult: (val) => onResult(val.recognizedWords),
        listenFor: listenFor,
        pauseFor: pauseFor,
      );
    }
  }

  void stop() {
    _isListening = false;
    _speech.stop();
  }
}
