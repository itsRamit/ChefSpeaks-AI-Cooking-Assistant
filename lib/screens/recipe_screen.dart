import 'package:chefspeaks/models/recipe_model.dart';
import 'package:chefspeaks/screens/recipe_step_screen.dart';
import 'package:chefspeaks/services/recipe_service.dart';
import 'package:chefspeaks/widgets/custom_text.dart';
import 'package:chefspeaks/widgets/loader.dart';
import 'package:chefspeaks/widgets/text_card.dart';
import 'package:chefspeaks/widgets/voice_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chefspeaks/providers/wakeup_service_provider.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  final String prompt;
  const RecipeScreen({super.key, required this.prompt});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  late Future<Recipe> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = RecipeService().getRecipe(widget.prompt);
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
                      final steps = List.generate(
                        recipe.steps.length,
                        (i) => 'Step ${i + 1} : ${recipe.steps[i].step}',
                      );

                      return ListView.builder(
                        itemCount: steps.length,
                        itemBuilder: (context, index) {
                          return _AnimatedTextCard(
                            text: steps[index],
                            delay: Duration(milliseconds: 300 * index),
                          );
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
          final recipe = snapshot.data;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: w / 6 * 1.2,
                width: w / 6 * 1.2,
                child: VoiceButton(
                  isListening: isListening,
                  onTap: () {},
                  size: w / 6,
                ),
              ),
              GestureDetector(
                onTap: recipe == null
                    ? null
                    : () {
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