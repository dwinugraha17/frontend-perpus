import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilam_library/providers/auth_provider.dart';
import 'package:unilam_library/providers/library_provider.dart';
import 'package:unilam_library/providers/settings_provider.dart';
import 'package:unilam_library/views/onboarding/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Kita tidak perlu await SharedPreferences di sini lagi
  // Biarkan SplashScreen yang menanganinya agar UI langsung muncul.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api');
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'UNILAM Library',
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          themeAnimationDuration: const Duration(milliseconds: 500),
          themeAnimationCurve: Curves.easeInOut,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              primary: const Color(0xFF2563EB),
              surface: const Color(0xFFF8FAFC),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            fontFamily: 'Roboto', 
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Color(0xFF1E293B),
              surfaceTintColor: Colors.transparent,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              primary: const Color(0xFF60A5FA), // Blue 400 for dark mode
              surface: const Color(0xFF0F172A), // Slate 900
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Color(0xFFF8FAFC),
              surfaceTintColor: Colors.transparent,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          // HOME LANGSUNG KE SPLASH SCREEN
          home: const SplashScreen(),
        );
      },
    );
  }
}
