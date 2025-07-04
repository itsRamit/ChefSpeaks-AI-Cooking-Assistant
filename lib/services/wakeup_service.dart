import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';

typedef WakeWordCallback = void Function();

class WakeupService {
  static final WakeupService _instance = WakeupService._internal();
  final accessKey = dotenv.env['PORCUPINE_ACCESS_KEY'] ?? '';
  final path = "assets/Hey-chef_en_android_v3_0_0.ppn";
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
        accessKey,
        [path],
        (int keywordIndex) => onWakeWordDetected(),
      );
      await _porcupineManager?.start();
      _isInitialized = true;
      _isRunning = true;
      print("[WakeupService] Wake word detection started.");
    } on PlatformException catch (e) {
      print("[WakeupService] Initialization error: ${e.message}");
    }
  }

  Future<void> pause() async {
    if (_porcupineManager != null && _isRunning) {
      await _porcupineManager?.stop();
      _isRunning = false;
      print("[WakeupService] Detection paused.");
    }
  }

  Future<void> resume() async {
    if (_porcupineManager != null && !_isRunning) {
      await _porcupineManager?.start();
      _isRunning = true;
      print("[WakeupService] Detection resumed.");
    }
  }

  Future<void> stop() async {
    if (_porcupineManager != null && _isRunning) {
      await _porcupineManager?.stop();
      _isRunning = false;
      print("[WakeupService] Detection stopped.");
    }
  }

  Future<void> dispose() async {
    await stop();
    await _porcupineManager?.delete();
    _porcupineManager = null;
    _isInitialized = false;
    print("[WakeupService] Detection disposed.");
  }
}
