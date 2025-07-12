import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SparkleLoader extends StatelessWidget {
  const SparkleLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loader GIF
          SizedBox(
            width: 70,
            height: 70,
            child: Image.asset('assets/loader.gif'),
          ),
          const SizedBox(height: 20),
          // Message Text
          Text(
            "Generating recipe...",
            style: GoogleFonts.manrope(
              textStyle: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
