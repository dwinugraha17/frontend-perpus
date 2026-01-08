import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool pushNotification = true;
  bool emailNotification = true;
  bool smsNotification = false;
  bool darkMode = false;
  bool biometric = true;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool('darkMode') ?? false;
    biometric = prefs.getBool('biometric') ?? true;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> toggleBiometric(bool value) async {
    biometric = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric', value);
    notifyListeners();
  }

  void togglePush(bool v) { pushNotification = v; notifyListeners(); }
  void toggleEmail(bool v) { emailNotification = v; notifyListeners(); }
  void toggleSms(bool v) { smsNotification = v; notifyListeners(); }
}
