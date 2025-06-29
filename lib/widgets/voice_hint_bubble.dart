import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceHintBubble extends StatefulWidget {
  final String message;
  final Duration showDuration;
  final double triangleLeftOffset; // how far the triangle is from the left

  const VoiceHintBubble({
    super.key,
    required this.message,
    this.showDuration = const Duration(seconds: 3),
    this.triangleLeftOffset = 24,
  });

  @override
  State<VoiceHintBubble> createState() => _VoiceHintBubbleState();
}

class _VoiceHintBubbleState extends State<VoiceHintBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
    Future.delayed(widget.showDuration, () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<InlineSpan> _buildMessageSpans(String message) {
    final regex = RegExp(r'"(.*?)"');
    final matches = regex.allMatches(message);

    if (matches.isEmpty) {
      return [
        TextSpan(
          text: message,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ];
    }

    List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before the match
      if (match.start > lastEnd) {
        String before = message.substring(lastEnd, match.start);
        // Remove trailing comma if it's right before the highlight
        if (before.isNotEmpty && before.endsWith(',')) {
          before = before.substring(0, before.length - 1);
        }
        spans.add(TextSpan(
          text: before,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 14,
          ),
        ));
      }
      // Add the highlighted word (without quotes and without trailing comma)
      final highlighted = match.group(1)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Colors.blue, Colors.green],
              ).createShader(bounds);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white.withOpacity(0.15),
              ),
              child: Text(
                highlighted,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // This will be masked by the gradient
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
      lastEnd = match.end;
      // Remove comma right after the highlighted word
      if (lastEnd < message.length && message[lastEnd] == ',') {
        lastEnd++;
      }
    }
    // Add any remaining text after the last match
    if (lastEnd < message.length) {
      spans.add(TextSpan(
        text: message.substring(lastEnd),
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 14,
        ),
      ));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 0.7),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: _buildMessageSpans(widget.message),
              ),
            ),
          ),
          // Triangle pointer
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: widget.triangleLeftOffset),
              child: CustomPaint(
                size: const Size(16, 8),
                painter: _TrianglePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}