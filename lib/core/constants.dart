import 'package:flutter/foundation.dart';

class AppConstants {
  // GANTI URL INI dengan domain dari Railway deployment kamu
  static const String? _railwayUrl = 'https://library-backen-production.up.railway.app/api';

  static String get baseUrl {
    if (_railwayUrl != null && _railwayUrl!.isNotEmpty) {
      return _railwayUrl!;
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
