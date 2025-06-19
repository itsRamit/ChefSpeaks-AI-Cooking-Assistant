import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SparkleLoader extends StatefulWidget {
  const SparkleLoader({super.key});

  @override
  State<SparkleLoader> createState() => _SparkleLoaderState();
}

class _SparkleLoaderState extends State<SparkleLoader>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.6, end: 1.2).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();

    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        await _controllers[i].forward();
        await _controllers[i].reverse();
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  Widget _buildSparkle(Animation<double> animation, Offset offset, Color color) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: ScaleTransition(
        scale: animation,
        child: Opacity(
          opacity: 0.9,
          child: Icon(
            LucideIcons.sparkle,
            color: color,
            size: 30,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 50,
      child: Stack(
        children: [
          _buildSparkle(_animations[0], const Offset(5, 20), Colors.white),   // bottom-left
          _buildSparkle(_animations[1], const Offset(15, 0), Colors.white),  // top-center
          _buildSparkle(_animations[2], const Offset(25, 15), Colors.white), // bottom-right
        ],
      ),
    );
  }
}
