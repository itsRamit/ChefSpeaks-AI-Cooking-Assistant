import 'package:chefspeaks/widgets/text_card.dart';
import 'package:flutter/material.dart';

class RecipeScreen extends StatelessWidget {
  final String prompt;
  const RecipeScreen({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: h,
        width: w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blueAccent,
              Colors.green,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextCard(text: prompt)
          ),
        ),
      ),
    );
  }
}