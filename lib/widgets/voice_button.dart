import 'package:flutter/material.dart';
import 'dart:math';

class VoiceButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;
  final double size;

  const VoiceButton({
    super.key,
    required this.isListening,
    required this.onTap,
    this.size = 64,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double animatedSize = widget.isListening ? widget.size * 1.2 : widget.size;

    return SizedBox(
      width: animatedSize,
      height: animatedSize,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isListening)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(animatedSize, animatedSize),
                    painter: _GradientBorderPainter(
                      progress: _controller.value,
                      strokeWidth: 4,
                    ),
                  );
                },
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: animatedSize - 8,
              height: animatedSize - 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: widget.isListening
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1,
                      ),
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.isListening ? ShaderMask(
                  shaderCallback: (Rect bounds) {
                    final sweepGradient = SweepGradient(
                      startAngle: 0.0,
                      endAngle: 2 * pi,
                      colors: [
                        Colors.tealAccent,
                        Colors.cyan,
                        Colors.tealAccent,
                      ],
                      stops: [0.0, 0.5, 1.0],
                      transform: GradientRotation(2 * pi * _controller.value),
                    );
                    return sweepGradient.createShader(bounds);
                  },
                  child: Icon(
                    Icons.mic_sharp,
                    color: widget.isListening ? Colors.white : const Color(0xFFADD5CE),
                    size: 30,
                  ),
                ): Icon(
                Icons.mic_none_rounded,
                color: const Color(0xFFADD5CE),
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _GradientBorderPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweepGradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * pi,
      colors: [
        Colors.tealAccent,
        Colors.cyan,
        Colors.tealAccent,
      ],
      stops: [0.0, 0.5, 1.0],
      transform: GradientRotation(2 * pi * progress),
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final radius = (size.width / 2) - strokeWidth / 2;
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}