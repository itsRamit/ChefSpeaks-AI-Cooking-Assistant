import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chefspeaks/widgets/custom_text.dart';

class TextCard extends StatelessWidget {
  final String text;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;

  const TextCard({
    super.key,
    required this.text,
    this.borderRadius = 24,
    this.blur = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F1F2F).withOpacity(0.6), Color(0xFF23242A).withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomText(
                    text: text,
                    color: Colors.white.withOpacity(0.9),
                    size: 16,
                    bold: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
