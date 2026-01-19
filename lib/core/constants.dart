import 'package:flutter/foundation.dart';

class AppConstants {
  // 1. UBAH KE 'false' jika ingin pakai Localhost, 'true' jika ingin pakai Railway

  // 2. JIKA PAKAI HP FISIK: Isi dengan IP Laptop (misal '192.168.1.10').
  //    JIKA PAKAI EMULATOR / WEB / WINDOWS APP: Biarkan kosong ''.
  static const String _physicalDeviceIp = ''; 

  

  static String get baseUrl {
    // FORCE RELATIVE PATH FOR WEB TO BYPASS CORS
    return '/api';
  }

  static const String appName = 'UNILAM Library';
}