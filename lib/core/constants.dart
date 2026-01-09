import 'package:flutter/foundation.dart';

class AppConstants {
  // GANTI URL INI dengan domain dari ngrok kamu
  // Contoh: 'https://1234-56-789-012-345.ngrok-free.app/api' (URL ngrok yang diberikan)
  // atau URL deployment backend kamu jika sudah di-deploy
  static const String? _backendUrl = 'https://preborn-unpiteous-neriah.ngrok-free.dev/api'; // Ganti null dengan URL ngrok kamu

  static String get baseUrl {
    if (_backendUrl != null && _backendUrl!.isNotEmpty) {
      return _backendUrl!;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      // MENGGUNAKAN IP LAPTOP AGAR BISA DIAKSES DARI HP FISIK DI JARINGAN WIFI YANG SAMA
      return 'http://10.122.125.138:8000/api';
    }
  }

  static const String appName = 'UNILAM Library';
}
