import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// GANTI IMPORT DI BAWAH INI DENGAN PUNYA KAMU
import 'package:unilam_library/views/auth/login_screen.dart';
import 'package:unilam_library/views/main_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Ini efek membesar yang smooth
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Widget nextScreen = (token != null) ? const MainWrapper() : const LoginScreen();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Center(
        child: ScaleTransition( // Animasi membesar
          scale: _animation,
          child: FadeTransition( // Animasi muncul perlahan
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_library_rounded, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'UNILAM Library',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}