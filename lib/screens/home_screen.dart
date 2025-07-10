import 'dart:developer';
import 'dart:ui';

import 'package:chefspeaks/main.dart';
import 'package:chefspeaks/providers/voice_handler_provider.dart';
import 'package:chefspeaks/providers/wakeup_service_provider.dart';
import 'package:chefspeaks/screens/favorites_screen.dart';
import 'package:chefspeaks/screens/profile_sreen.dart';
import 'package:chefspeaks/screens/recipe_screen.dart';
import 'package:chefspeaks/utils/shared_prefs_keys.dart';
import 'package:chefspeaks/widgets/custom_text.dart';
import 'package:chefspeaks/widgets/voice_button.dart';
import 'package:chefspeaks/widgets/voice_hint_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  final TextEditingController _textController = TextEditingController();
  String recognizedText = '';
  String name = '';
  bool isTyping = false;
  VoidCallback? _cancelWakeListener;

  @override
  void initState() {
    super.initState();

    _initName();

    _textController.addListener(() {
      setState(() {
        isTyping = _textController.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _initName() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString(SharedPrefsKeys.name) ?? 'User';
    final firstName = fullName.trim().split(' ').first;
    setState(() {
      name = firstName;
    });
    final tts = ref.read(ttsServiceProvider);
    tts.speak("Hey $name, I'm your personal chef. How can I assist you today?");
  }


  void _setupWakeupServiceAndCallback() async {
    await ref.read(wakeupServiceProvider).dispose();
    ref.read(wakeupServiceProvider).initialize(
      onWakeWordDetected: () {
        ref.read(voiceHandlerProvider).handleWakeAndListen();
      },
    );

    ref.read(screenCallbackProvider.notifier).state = (String text) async {
      if (mounted) {
        setState(() {
          recognizedText = text;
        });

        await ref.read(wakeupServiceProvider).dispose();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeScreen(prompt: text),
          ),
        );
      }
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    Future.microtask(() {
      if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
      ref.read(activeScreenProvider.notifier).state = 'home';
      _cancelWakeListener?.call();
      _setupWakeupServiceAndCallback();
    });
  }

  @override
  void didPopNext() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    ref.read(wakeupServiceProvider).dispose().then((_) async {
      if (!mounted) return;
      ref.read(activeScreenProvider.notifier).state = 'home';
      if (!mounted) return;
      ref.read(wakeupServiceProvider).initialize(
        onWakeWordDetected: () {
          if (!mounted) return;
          ref.read(voiceHandlerProvider).handleWakeAndListen();
        },
      );
      if (!mounted) return;
      ref.read(screenCallbackProvider.notifier).state = (String text) async {
        if (!mounted) return;
        await ref.read(wakeupServiceProvider).dispose();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeScreen(prompt: text),
          ),
        );
      };
    });
    recognizedText = '';
    isTyping = false;
  }


  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _cancelWakeListener?.call();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final isListening = ref.watch(isListeningProvider);

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
          ),
          
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/bg.png',
                fit: BoxFit.cover,
                
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: w/3,
                    height: w/3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3EDFCF).withValues(alpha: 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF3EDFCF).withValues(alpha: 0.5),
                          blurRadius: 100,
                          spreadRadius: 50,
                        ),
                      ],
                    ),
                  ),
                  CustomText(
                    text: recognizedText.isEmpty
                        ? isListening
                            ? "Listening..."
                            : 'Hi $name,\nWhich recipe are we whipping up today?'
                        : recognizedText,
                    size: w / 9,
                    bold: true,
                    alignCenter: true,
                  ),
                ],
              ),
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
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ));
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
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ));
                },
              ),
            ),
          ),
          
        ],
      ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: w/1.5,
            bottom: w/6*1.3,
            child: VoiceHintBubble(
              message: 'Say "Hey chef"',
              showDuration: Duration(seconds: 5),
              triangleLeftOffset: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(w / 10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(w / 10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: w * 0.65,
                        height: w / 7,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFADD5CE), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
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
                        height: w / 6 * 1.2,
                        width: w / 6 * 1.2,
                        child: isTyping
                            ? Padding(
                                padding: EdgeInsets.all(0.17 * w / 6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.8), width: 1),
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
                                        final prompt = _textController.text.trim();
                                        if (prompt.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipeScreen(prompt: prompt),
                                            ),
                                          );
                                          _textController.clear();
                                          setState(() {
                                            isTyping = false;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              )
                            : VoiceButton(
                                isListening: isListening,
                                onTap: () {
                                  ref.read(voiceHandlerProvider).handleWakeAndListen();
                                },
                                size: w / 6,
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}
