import 'dart:async';
import 'package:chefspeaks/widgets/voice_button.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/recipe_model.dart';
import '../widgets/custom_text.dart';

class RecipeStepsScreen extends StatefulWidget {
  final List<RecipeStep> steps;
  const RecipeStepsScreen({super.key, required this.steps});

  @override
  State<RecipeStepsScreen> createState() => _RecipeStepsScreenState();
}

class _RecipeStepsScreenState extends State<RecipeStepsScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  int? _activeTimerIndex;
  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
    super.initState();
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
    if (_currentPage < widget.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  void _goToPrevPage() {
    if (_currentPage >= 0) {
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
    final steps = widget.steps;
    return Scaffold(
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
      extendBodyBehindAppBar: true,
      body: Container(
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
        child: PageView.builder(
          controller: _pageController,
          itemCount: steps.length,
          physics: const NeverScrollableScrollPhysics(), // Non-scrollable
          itemBuilder: (context, index) {
            final step = steps[index];
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
                    Colors.white.withOpacity(0.2),
                    Colors.white38.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white24,
                    Colors.white10,
                  ],
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
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
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
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _goToPrevPage,
            child: Container(
              height: w / 7,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.8)),
                borderRadius: BorderRadius.circular(w / 10),
                color: Colors.black,
              ),
              alignment: Alignment.center,
              child: ShaderMask(
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
                blendMode: BlendMode.srcIn,
                child: const Icon(Icons.arrow_back, color: Colors.green),
              ),
            ),
          ),
          SizedBox(
            height: w / 6 * 1.2,
            width: w / 6 * 1.2,
            child: VoiceButton(
              isListening: false,
              onTap: () {},
              size: w / 6,
            ),
          ),
          GestureDetector(
            onTap: _goToNextPage,
            child: Container(
              height: w / 7,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.8)),
                borderRadius: BorderRadius.circular(w / 10),
                color: Colors.black,
              ),
              alignment: Alignment.center,
              child: ShaderMask(
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
                blendMode: BlendMode.srcIn,
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}