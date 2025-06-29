import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:chefspeaks/providers/voice_handler_provider.dart';
import 'package:chefspeaks/services/chat_service.dart';
import 'package:chefspeaks/widgets/voice_button.dart';
import 'package:chefspeaks/widgets/voice_hint_bubble.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/recipe_model.dart';
import '../widgets/custom_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chefspeaks/providers/wakeup_service_provider.dart';

class RecipeStepsScreen extends ConsumerStatefulWidget {
  final Recipe recipe;
  const RecipeStepsScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeStepsScreen> createState() => _RecipeStepsScreenState();
}

class _RecipeStepsScreenState extends ConsumerState<RecipeStepsScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  int? _activeTimerIndex;
  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  Timer? _timer;
  bool _isPaused = false;
  List<bool> spoken = [];

  @override
  void initState() {
    super.initState();
    spoken = List<bool>.filled(widget.recipe.steps.length, false);
    spoken[0] = true;
    final tts = ref.read(ttsServiceProvider);
    final firstStep = widget.recipe.steps[0];
    tts.speak(' ${firstStep.description}');
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      log("Here in didChangeDependencies");
      ref.read(activeScreenProvider.notifier).state = 'recipeSteps';
      ref.read(wakeupServiceProvider).initialize(
        onWakeWordDetected: () {
          log("Wake word detected, handling wake and listen");
          ref.read(voiceHandlerProvider).handleWakeAndListen();
        },
      );
      log("Here in didChangeDependencies after initialization");
      ref.read(screenCallbackProvider.notifier).state = (String text) async {
        final userInput = text.trim();
        if (userInput.isEmpty) return;

        if (userInput.contains('next')) {
          _goToNextPage();
          return;
        }
        if (userInput.contains('previous') || userInput.contains('back')) {
          _goToPrevPage();
          return;
        }

        final stepIndex = _currentPage.clamp(0, widget.recipe.steps.length - 1);
        final step = widget.recipe.steps[stepIndex];
        if (userInput.contains('start timer') ||
          userInput.contains('pause timer') ||
          userInput.contains('resume timer') ||
          userInput.contains('reset timer')) {
          final tts = ref.read(ttsServiceProvider);
          if (step.time > 0) {
            if (userInput.contains('start timer')) {
              _startTimer(stepIndex, step.time);
              tts.speak("Timer started");
              return;
            }
            if (userInput.contains('pause timer')) {
              _pauseTimer();
              tts.speak("Timer paused");
              return;
            }
            if (userInput.contains('resume timer')) {
              _resumeTimer();
              tts.speak("Timer resumed");
              return;
            }
            if (userInput.contains('reset timer')) {
              _resetTimer(stepIndex, step.time);
              tts.speak("Timer reset");
              return;
            }
          } else {
            tts.speak("No timer is available for this step.");
            return;
          }
      }
        final referenceText =
            '${widget.recipe.dishName}\nStep: ${step.step}\nDescription: ${step.description}';

        try {
          final msg = await ChatService().chat(userInput, referenceText);
          if (mounted) {
            final tts = ref.read(ttsServiceProvider);
            tts.speak(msg.response);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
        }
      };
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer(int index, int minutes) {
    _timer?.cancel();
    setState(() {
      _activeTimerIndex = index;
      _remainingSeconds = minutes * 60;
      _initialSeconds = minutes * 60;
      _isPaused = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _activeTimerIndex = null;
          _isPaused = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timer finished!')),
        );
        final tts = ref.read(ttsServiceProvider);
        tts.speak("Timer finished for step ${index + 1}");
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _activeTimerIndex = null;
          _isPaused = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timer finished!')),
        );
      }
    });
  }

  void _resetTimer(int index, int minutes) {
    _timer?.cancel();
    setState(() {
      _activeTimerIndex = index;
      _remainingSeconds = minutes * 60;
      _initialSeconds = minutes * 60;
      _isPaused = false;
    });
  }

  void _goToNextPage() {
    final tts = ref.read(ttsServiceProvider);
    if (_currentPage < widget.recipe.steps.length) {
       tts.stop();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    };
    final nextIndex = (_currentPage + 1).clamp(0, widget.recipe.steps.length - 1);
    final step = widget.recipe.steps[nextIndex];
    if(!spoken[nextIndex]){
      tts.speak(' ${step.description}');
      setState(() {
        spoken[nextIndex] = true;
      });
    }
  }

  void _goToPrevPage() {
    if (_currentPage > 0) {
      final tts = ref.read(ttsServiceProvider);
      tts.stop();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final steps = widget.recipe.steps;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const CustomText(
          text: "Recipe Steps",
          color: Colors.white,
          size: 20,
          bold: true,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.blue, Colors.green],
              ),
            ),
          ),
          // Background image with opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/bg.png', // Make sure this path is correct and bg.png is in your assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: steps.length + 1,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == steps.length) {
                return _buildFinalCard(h, w);
              }
              return _buildStepCard(h, w, index);
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: w/7,
            bottom: w/6*1.3,
            child: VoiceHintBubble(
              message: 'Say "Hey chef" then \n "Next" or "Previous" \n to navigate',
              showDuration: Duration(seconds: 5),
              triangleLeftOffset: 0,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(w / 10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(w / 10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavButton(Icons.arrow_back, _goToPrevPage, _currentPage > 0, w),
                    SizedBox(
                      height: w / 6 * 1.2,
                      width: w / 6 * 1.2,
                      child: VoiceButton(
                        isListening: ref.watch(isListeningProvider),
                        onTap: () {
                          ref.read(voiceHandlerProvider).handleWakeAndListen();
                        },
                        size: w / 6,
                      ),
                    ),
                    _buildNavButton(Icons.arrow_forward, _goToNextPage, _currentPage < steps.length, w),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap, bool enabled, double w) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: w / 7,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withAlpha(204)),
          borderRadius: BorderRadius.circular(w / 10),
          color: enabled ? Colors.black : Colors.black.withAlpha(51),
        ),
        alignment: Alignment.center,
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blue, Colors.green],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFinalCard(double h, double w) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 12),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: h * 0.8,
        borderRadius: 25,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withAlpha(51),
            Colors.white38.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white24, Colors.white10],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_food_beverage, color: Colors.white, size: 60),
              const SizedBox(height: 24),
              const CustomText(
                text: "Your dish is ready!",
                color: Colors.white,
                size: 28,
                bold: true,
                alignCenter: true,
              ),
              const SizedBox(height: 32),
              Row(
                spacing: w/10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: Add to favourite logic
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(46),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withAlpha(127)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.favorite_border, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(46),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withAlpha(127)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        spacing: 6,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restart_alt, color: Colors.white),
                          CustomText(
                            text: "Cook Again",
                            color: Colors.white,
                            size: w/30,
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(double h, double w, int index) {
    final step = widget.recipe.steps[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 12),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: h * 0.8,
        borderRadius: 25,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withAlpha(51),
            Colors.white38.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white24, Colors.white10],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: "Step ${index + 1}",
                color: Colors.white,
                size: 24,
                bold: true,
              ),
              const SizedBox(height: 16),
              CustomText(
                text: step.step,
                color: Colors.white,
                size: 18,
                alignCenter: true,
              ),
              const SizedBox(height: 12),
              CustomText(
                text: step.description,
                color: Colors.white70,
                size: 16,
                alignCenter: true,
              ),
              if (step.time > 0) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    if (_activeTimerIndex == index) {
                      if (_isPaused) {
                        _resumeTimer();
                      } else {
                        _pauseTimer();
                      }
                    } else {
                      _startTimer(index, step.time);
                    }
                  },
                  onLongPress: () {
                    _resetTimer(index, step.time);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(46),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withAlpha(127)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _activeTimerIndex == index
                              ? (_remainingSeconds == _initialSeconds
                                  ? Icons.timer_outlined
                                  : (_remainingSeconds == 0
                                      ? Icons.replay
                                      : (_isPaused ? Icons.play_arrow : Icons.pause)))
                              : Icons.timer_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        CustomText(
                          text: _activeTimerIndex == index
                              ? (_remainingSeconds > 0
                                  ? "${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}"
                                  : "Done!")
                              : "${step.time} min",
                          color: Colors.white,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
