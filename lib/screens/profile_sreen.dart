import 'package:chefspeaks/utils/shared_prefs_keys.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, String>> _getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(SharedPrefsKeys.name) ?? 'Chef User',
      'email': prefs.getString(SharedPrefsKeys.email) ?? 'chef@example.com',
    };
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
    }

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            height: h,
            width: w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.blue,
                  Colors.green,
                ],
              ),
            ),
          ),
          Center(
            child: GlassmorphicContainer(
              width: w * 0.85,
              height: h * 0.45,
              borderRadius: 30,
              blur: 8,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                colors: [
                  Colors.white.withAlpha(60),
                  Colors.white38.withAlpha(30),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: const LinearGradient(
                colors: [Colors.white24, Colors.white10],
              ),
              child: FutureBuilder<Map<String, String>>(
                future: _getProfile(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  final name = snapshot.data!['name']!;
                  final email = snapshot.data!['email']!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile avatar
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Name
                        Text(
                          name,
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Email
                        Text(
                          email,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Logout button at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded),
                label: Text(
                  'Logout',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}