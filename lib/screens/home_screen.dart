import 'package:chefspeaks/screens/recipe_screen.dart';
import 'package:chefspeaks/services/speech_services.dart';
import 'package:chefspeaks/widgets/custom_text.dart';
import 'package:chefspeaks/widgets/voice_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speechService = SpeechService();
  final TextEditingController _textController = TextEditingController();
  bool isListening = false;
  String recognizedText = '';
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        isTyping = _textController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          Container(
            height: h,
            width: w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.blue,
                  Colors.green,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: CustomText(
                    text: recognizedText.isEmpty
                        ? isListening
                            ? "Listening..."
                            : 'Hi Ramit,\n Which recipe are we whipping up today?'
                        : recognizedText,
                    size: w/9,
                    bold: true,
                    alignCenter: true,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.black,
              child: IconButton(
                icon: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.blue,
                        Colors.green,     
                      ],
                    ).createShader(bounds);
                  },
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
                onPressed: () {
                  // TODO: Add your favourite action
                },
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.black,
              child: IconButton(
                icon: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.blue,
                        Colors.green,
                      ],
                    ).createShader(bounds);
                  },
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                onPressed: () {
                  // TODO: Add your profile action
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left:16.0,right: 16.0, top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: w * 0.7,
              height: w/7,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFADD5CE), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                cursorWidth: 1,
                cursorColor: Colors.white,
                style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Type your recipe...",
                hintStyle: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              ),
            ),
            SizedBox(
              height: w/6*1.2,
              width: w/6*1.2,
              child: isTyping
              ? Padding(
                  padding: EdgeInsets.all(0.17*w/6),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1), // White border
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: IconButton(
                        icon: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Colors.blue,
                                Colors.green,
                              ],
                            ).createShader(bounds);
                          },
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                        onPressed: () {
                          // TODO: Add your send action
                        },
                      ),
                    ),
                  ),
                )
              : VoiceButton(
                  isListening: isListening,
                  onTap: _listen,
                  size: w / 6,
                ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}