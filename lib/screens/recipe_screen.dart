import 'dart:async';
import 'dart:developer';
import 'dart:ui' show ImageFilter;
import 'package:chefspeaks/models/recipe_model.dart';
import 'package:chefspeaks/providers/voice_handler_provider.dart';
import 'package:chefspeaks/providers/wakeup_service_provider.dart';
import 'package:chefspeaks/screens/recipe_step_screen.dart';
import 'package:chefspeaks/services/recipe_service.dart';
import 'package:chefspeaks/widgets/custom_text.dart';
import 'package:chefspeaks/widgets/loader.dart';
import 'package:chefspeaks/widgets/text_card.dart';
import 'package:chefspeaks/widgets/voice_button.dart';
import 'package:chefspeaks/widgets/voice_hint_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  final String prompt;
  const RecipeScreen({super.key, required this.prompt});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  late Future<Recipe> _recipeFuture;
  bool spoken = false;
  @override
  void initState() {
    super.initState();

    // Start wakeup service (triggers voiceHandler)
    ref.read(wakeupServiceProvider).initialize(
      onWakeWordDetected: () {
        ref.read(voiceHandlerProvider).handleWakeAndListen();
      },
    );

    _recipeFuture = RecipeService().getRecipe(widget.prompt);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.microtask(() {
      ref.read(activeScreenProvider.notifier).state = 'recipe';

      ref.read(screenCallbackProvider.notifier).state = (String text) {
        log("text: $text");
      };
    });
  }

  @override
  void dispose() {
    ref.read(wakeupServiceProvider).pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final isListening = ref.watch(isListeningProvider);

    return Scaffold(
      body: Container(
        height: h,
        width: w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blueAccent, Colors.green],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: CustomText(
                    text: "Prompt : ${widget.prompt}",
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: FutureBuilder<Recipe>(
                    future: _recipeFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: SparkleLoader());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.steps.isEmpty) {
                        return const Center(child: Text("No steps found."));
                      }

                      final recipe = snapshot.data!;
                      String completeSteps = "Here are the steps to cook your dish:\n";
                      for (int i = 0; i < recipe.steps.length; i++) {
                        completeSteps += "Step ${i + 1}: ${recipe.steps[i].step}\n";
                      }
                      if (!spoken) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final tts = ref.read(ttsServiceProvider);
                          tts.speak(completeSteps);
                          setState(() {
                            spoken = true;
                          });
                        });
                      }
                      final steps = List.generate(
                        recipe.steps.length,
                        (i) => 'Step ${i + 1} : ${recipe.steps[i].step}',
                      );

                      return ListView.builder(
                        itemCount: steps.length + 1,
                        itemBuilder: (context, index) {
                          if (index < steps.length) {
                            return _AnimatedTextCard(
                              text: steps[index],
                              delay: Duration(milliseconds: 300 * index),
                            );
                          } else {
                            return const SizedBox(height: 60); 
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          final recipe = snapshot.data;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: -25,
                bottom: w/6*1.3,
                child: VoiceHintBubble(
                  message: 'Say "Hey chef" then \n "Continue" to navigate',
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: w / 6 * 1.2,
                          width: w / 6 * 1.2,
                          child: VoiceButton(
                            isListening: isListening,
                            onTap: () {
                              ref.read(voiceHandlerProvider).handleWakeAndListen();
                            },
                            size: w / 6,
                          ),
                        ),
                        GestureDetector(
                          onTap: recipe == null
                              ? null
                              : () {
                                  final tts = ref.read(ttsServiceProvider);
                                  tts.stop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeStepsScreen(recipe: recipe),
                                    ),
                                  );
                                },
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
                                  colors: [Colors.blue, Colors.green],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: const CustomText(
                                text: "Continue",
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}

class _AnimatedTextCard extends StatefulWidget {
  final String text;
  final Duration delay;
  const _AnimatedTextCard({required this.text, required this.delay});

  @override
  State<_AnimatedTextCard> createState() => _AnimatedTextCardState();
}

class _AnimatedTextCardState extends State<_AnimatedTextCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: TextCard(text: widget.text),
      ),
    );
  }
}
