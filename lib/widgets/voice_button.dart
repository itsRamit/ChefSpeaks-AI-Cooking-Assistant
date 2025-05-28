import 'package:flutter/material.dart';

class VoiceButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isListening ? Colors.green[800] : Colors.black,
            boxShadow: isListening
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: isListening
              ? Image.asset(
                  'assets/listening-button-animation.gif',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Icon(
                  Icons.mic_none,
                  color: Colors.green,
                  size: 40,
                ),
        ),
      ),
    );
  }
}