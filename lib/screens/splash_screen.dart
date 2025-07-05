import 'dart:async';
import 'package:chefspeaks/utils/shared_prefs_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showLogin = true;
        });
      }
    });
  }

  void _onAuthError(Object error) {
    // Handle authentication error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Authentication failed: ${error}')),
    );
  }

  void _onAuthSuccess(Session session) async {
    final user = session.user;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(SharedPrefsKeys.isLoggedIn, true);
    await prefs.setString(SharedPrefsKeys.userId, user.id);
    await prefs.setString(SharedPrefsKeys.email, user.email ?? 'N/A');
    await prefs.setString(SharedPrefsKeys.name, user.userMetadata?['full_name'] ?? 'N/A');
    await prefs.setString(SharedPrefsKeys.contact, user.phone ?? 'N/A');

    Navigator.pushReplacementNamed(context, '/home');
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
