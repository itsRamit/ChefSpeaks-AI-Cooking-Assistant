import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showLogin = false;

  @override
  void initState() {
    super.initState();

    // Show login button after splash delay
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showLogin = true;
        });
      }
    });
  }

  void _onAuthSuccess(Session session) {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _onAuthError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login failed: $error")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue, Colors.green],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Icon(Icons.restaurant_menu, size: 80, color: Colors.black),
              SizedBox(height: h / 40),

              // Title
              Text(
                'ChefSpeaks',
                style: GoogleFonts.manrope(
                  fontSize: w / 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              // Subtitle
              const SizedBox(height: 12),
              Text(
                'AI Cooking Assistant',
                style: GoogleFonts.manrope(
                  fontSize: w / 20,
                  color: Colors.grey[700],
                ),
              ),

              // Auth buttons (after delay)
              SizedBox(height: h / 20),
              AnimatedOpacity(
                opacity: showLogin ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: SupaSocialsAuth(
                    socialProviders: [
                      OAuthProvider.google,
                      OAuthProvider.twitter,
                    ],
                    colored: true,
                    redirectUrl: kIsWeb ? null : dotenv.env['SUPABASE_REDIRECT_URI'],
                    onSuccess: _onAuthSuccess,
                    onError: _onAuthError,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
