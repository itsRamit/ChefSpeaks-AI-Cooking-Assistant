import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  bool isListening = false;

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
        child: Column(
          children: [
          ],
        ),
      ),
      floatingActionButton: SizedBox(
  width: w / 5,
  height: w / 5,
  child: GestureDetector(
    onTap: () {
      setState(() {
        isListening = !isListening;
      });
    },
    child: isListening
        ? Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/listening-button-animation.gif',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          )
        : AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Icon(
              Icons.mic_none,
              color: Colors.green,
              size: 40,
            ),
          ),
  ),
),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}