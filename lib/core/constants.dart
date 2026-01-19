import 'package:flutter/foundation.dart';

class AppConstants {
  // 1. UBAH KE 'false' jika ingin pakai Localhost, 'true' jika ingin pakai Railway

  // 2. JIKA PAKAI HP FISIK: Isi dengan IP Laptop (misal '192.168.1.10').
  //    JIKA PAKAI EMULATOR / WEB / WINDOWS APP: Biarkan kosong ''.
  static const String _physicalDeviceIp = ''; 

  

  static String get baseUrl {
    
    // A. Mode Production (Railway)
    if (kReleaseMode) {
      return 'https://library-backend-production.up.railway.app/api';
    }

    // B. Mode Development (Localhost)
    
    
    // 1. Jika Web (Prioritas utama untuk development di browser)
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    // 2. Jika ada IP Fisik yang diset manual
    if (_physicalDeviceIp.isNotEmpty) {
      return 'http://$_physicalDeviceIp:8000/api';
    }

    // 3. Jika Android (Emulator standar)
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    // 4. iOS Simulator, Windows App, macOS App, Linux App
    return 'http://127.0.0.1:8000/api';
  }

  static const String appName = 'UNILAM Library';
}