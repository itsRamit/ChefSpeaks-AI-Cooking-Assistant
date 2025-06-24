import 'dart:async';
import 'package:chefspeaks/services/chat_service.dart';
import 'package:chefspeaks/services/stt_services.dart';
import 'package:chefspeaks/widgets/voice_button.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/recipe_model.dart';
import '../widgets/custom_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chefspeaks/providers/wakeup_service_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  late final SpeechService _speechService;
  Timer? _debounceTimer;
  String recognizedText = '';

  @override
  void initState() {
    super.initState();

    _speechService = ref.read(speechServiceProvider);

    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });

    final wakeupService = ref.read(wakeupServiceProvider);
    wakeupService.initialize(onWakeWordDetected: _onWakeDetected);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onWakeDetected() async {
    final wakeupService = ref.read(wakeupServiceProvider);
    await wakeupService.pause();
    await _listen();
  }

  Future<void> _listen() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
      }
      return;
    }

    if (!ref.read(isListeningProvider)) {
      final wakeupService = ref.read(wakeupServiceProvider);

      bool available = await _speechService.initialize(
        onStatus: (status) async {
          if (status == 'notListening') {
            ref.read(isListeningProvider.notifier).state = false;
            await wakeupService.resume();
          }
        },
        onError: (error) {
          ref.read(isListeningProvider.notifier).state = false;
        },
      );

      if (available) {
        ref.read(isListeningProvider.notifier).state = true;
        setState(() {
          recognizedText = '';
        });

        _speechService.listen(
          onResult: (words) async {
            setState(() {
              recognizedText = words;
            });
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(seconds: 1), () async {
              if (words.trim().isNotEmpty) {
                var userInput = words.trim();
                final chatService = ChatService();
                try {
                  final stepIndex = _currentPage.clamp(0, widget.recipe.steps.length - 1);
                  final step = widget.recipe.steps[stepIndex];
                  final referenceText =
                      '${widget.recipe.dishName}\nStep: ${step.step}\nDescription: ${step.description}';

                  final chatMessage = await chatService.chat(
                    userInput,
                    referenceText,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(chatMessage.response)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: \$e')),
                    );
                  }
                }
              }
            });
          },
        );
      }
    } else {
      ref.read(isListeningProvider.notifier).state = false;
      _speechService.stop();
    }
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
    if (_currentPage < widget.recipe.steps.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrevPage() {
    if (_currentPage > 0) {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue, Colors.green],
          ),
        ),
        child: PageView.builder(
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
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavButton(Icons.arrow_back, _goToPrevPage, _currentPage > 0, w),
          SizedBox(
            height: w / 6 * 1.2,
            width: w / 6 * 1.2,
            child: VoiceButton(
              isListening: ref.watch(isListeningProvider),
              onTap: _listen,
              size: w / 6,
            ),
          ),
          _buildNavButton(Icons.arrow_forward, _goToNextPage, _currentPage < steps.length, w),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.white.withAlpha(127)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.restart_alt, color: Colors.white),
                    label: const CustomText(
                      text: "Cook Again",
                      color: Colors.white,
                      size: 14,
                      bold: true,
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
