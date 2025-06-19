import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final bool bold;
  final bool alignCenter;

  const CustomText({
    Key? key,
    required this.text,
    this.size = 16,
    this.color = Colors.black,
    this.bold = false,
    this.alignCenter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: size,
        color: color,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        shadows: [
          Shadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(1, 1),
          ),
        ],
      ),
      textAlign: alignCenter ? TextAlign.center : TextAlign.start,
    );
  }
}