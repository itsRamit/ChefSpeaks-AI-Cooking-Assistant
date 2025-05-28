import 'package:chefspeaks/screens/recipe_screen.dart';
import 'package:chefspeaks/services/speech_services.dart';
import 'package:chefspeaks/widgets/voice_button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speechService = SpeechService();
  bool isListening = false;
  String recognizedText = '';

  Future<void> _listen() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
      return;
    }

    if (!isListening) {
      bool available = await _speechService.initialize(
        onStatus: (status) async {
          if (status == 'notListening') {
            setState(() => isListening = false);
            if (recognizedText.trim().isNotEmpty) {
              final prompt = recognizedText.trim();
              setState(() => recognizedText = '');
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeScreen(prompt: prompt),
                  ),
                );
              }
            }
          }
        },
        onError: (error) {
          setState(() => isListening = false);
        },
      );
      if (available) {
        setState(() {
          isListening = true;
          recognizedText = '';
        });
        _speechService.listen(
          onResult: (words) {
            setState(() {
              recognizedText = words;
            });
          },
        );
      }
    } else {
      setState(() => isListening = false);
      _speechService.stop();
    }
  }


  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: h,
        width: w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blueAccent,
              Colors.green,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                recognizedText.isEmpty
                    ? isListening
                        ? "Listening..."
                        : 'Tap the mic and start speaking...'
                    : recognizedText,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: VoiceButton(
        isListening: isListening,
        onTap: _listen,
        size: w / 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}