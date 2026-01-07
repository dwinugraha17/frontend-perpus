import 'package:flutter/foundation.dart';

class AppConstants {
  // GANTI URL INI dengan domain dari Railway, contoh: 'https://unilam-backend.up.railway.app/api'
  // Jangan lupa tambahkan '/api' di belakangnya.
  static const String? _railwayUrl = null; 

  static String get baseUrl {
    if (_railwayUrl != null && _railwayUrl!.isNotEmpty) {
      return _railwayUrl!;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api'; // iOS / Windows / macOS
    }
  }

  static const String appName = 'UNILAM Library';
}
