import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:flutter/services.dart';

typedef WakeWordCallback = void Function();

class WakeupService {
  static final WakeupService _instance = WakeupService._internal();
  factory WakeupService() => _instance;

  WakeupService._internal();

  PorcupineManager? _porcupineManager;
  bool _isInitialized = false;
  bool _isRunning = false;

  Future<void> initialize({
    required WakeWordCallback onWakeWordDetected,
  }) async {
    if (_isInitialized) return;

    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        "MHqBxYb0dSu2R8o5ETtEKYzfr7EZ+pneovbBLlg9GXeOySRgkTogFw==",
        ["assets/Hey-chef_en_android_v3_0_0.ppn"],
        (int keywordIndex) => onWakeWordDetected(),
      );
      await _porcupineManager?.start();
      _isInitialized = true;
      _isRunning = true;
      print("Wake word detection started.");
    } on PlatformException catch (e) {
      print("Error initializing Porcupine: ${e.message}");
    }
  }

  Future<void> pause() async {
    if (_porcupineManager != null && _isRunning) {
      await _porcupineManager?.stop();
      _isRunning = false;
      print("Wake word detection paused.");
    }
  }

  Future<void> resume() async {
    if (_porcupineManager != null && !_isRunning) {
      await _porcupineManager?.start();
      _isRunning = true;
      print("Wake word detection resumed.");
    }
  }

  Future<void> stop() async {
    if (_porcupineManager != null && _isRunning) {
      await _porcupineManager?.stop();
      _isRunning = false;
      print("Wake word detection stopped.");
    }
  }

  Future<void> dispose() async {
    await stop();
    await _porcupineManager?.delete();
    _isInitialized = false;
    print("Wake word detection disposed.");
  }
}