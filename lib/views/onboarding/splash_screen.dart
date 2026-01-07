import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilam_library/views/auth/login_screen.dart';
import 'package:unilam_library/views/main_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    // Navigate based on auth state and onboarding status
    Widget nextScreen;
    if (token != null) {
      // User is logged in, go directly to main wrapper
      nextScreen = const MainWrapper();
    } else if (hasSeenOnboarding) {
      // User has seen onboarding, go to login
      nextScreen = const LoginScreen();
    } else {
      // Show onboarding first
      nextScreen = const LoginScreen();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB), // Primary blue color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.local_library_rounded,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            // App Name
            Text(
              'UNILAM Library',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 5,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}