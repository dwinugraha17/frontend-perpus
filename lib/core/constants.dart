
class AppConstants {
  // 1. UBAH KE 'false' jika ingin pakai Localhost, 'true' jika ingin pakai Railway

  // 2. JIKA PAKAI HP FISIK: Isi dengan IP Laptop (misal '192.168.1.10').
  //    JIKA PAKAI EMULATOR / WEB / WINDOWS APP: Biarkan kosong ''.

  

  static String get baseUrl {
    // FIX TYPO: backen (without d) to match your repository name
    return 'https://library-backen-production.up.railway.app/api';
  }

  static const String appName = 'UNILAM Library';
}