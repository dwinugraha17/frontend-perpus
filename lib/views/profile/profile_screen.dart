// ignore_for_file: deprecated_member_use

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilam_library/providers/auth_provider.dart';
import 'package:unilam_library/providers/settings_provider.dart';
import 'package:unilam_library/views/auth/login_screen.dart';
import 'package:unilam_library/views/profile/edit_profile_screen.dart';
import 'package:unilam_library/views/widgets/custom_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final user = auth.user;

    // Define colors based on Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final hasValidPhoto = user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Profil Saya',
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // --- MEMBER CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'UNILAM LIBRARY CARD',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Photo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: ClipOval(
                          child: hasValidPhoto
                              ? CustomNetworkImage(
                                  imageUrl: user.profilePhoto!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.white.withOpacity(0.2),
                                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Guest',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'No Email',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Barcode
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                'MEMBER ID',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                               Text(
                                user?.id.toString() ?? 'N/A',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              )
                             ],
                           ),
                         ),
                        Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(4),
                           decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: BarcodeWidget(
                            barcode: Barcode.qrCode(),
                            data: user?.id.toString() ?? 'unilam-library-user',
                            color: const Color(0xFF1E293B),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // --- SECTION INFO PRIBADI ---
            _buildSectionHeader("Informasi Pribadi", textSecondary),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.phone_android_rounded,
                    title: 'No. WhatsApp',
                    subtitle: user?.phoneNumber ?? '-',
                    isLast: true,
                    iconColor: primaryColor,
                    textColor: textPrimary,
                    subtitleColor: textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- SECTION TAMPILAN ---
            _buildSectionHeader("Tampilan", textSecondary),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: settings.darkMode,
                    onChanged: (val) => settings.toggleDarkMode(val),
                    iconColor: primaryColor,
                    textColor: textPrimary,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- SECTION PENGATURAN AKUN ---
            _buildSectionHeader("Akun & Keamanan", textSecondary),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profil',
                    subtitle: 'Ubah nama, foto, dan info lainnya',
                    iconColor: primaryColor,
                    textColor: textPrimary,
                    subtitleColor: textSecondary,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                  ),
                  _buildProfileTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Keluar dari akun aplikasi',
                    textColor: const Color(0xFFDC2626), // Red 600
                    iconColor: const Color(0xFFDC2626),
                    subtitleColor: textSecondary,
                    onTap: () => _showLogoutDialog(context, auth, isDark),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                  ),
                  _buildProfileTile(
                    icon: Icons.delete_forever_rounded,
                    title: 'Hapus Akun',
                    subtitle: 'Hapus akun dan data secara permanen',
                    textColor: const Color(0xFFDC2626), // Red 600
                    iconColor: const Color(0xFFDC2626),
                    subtitleColor: textSecondary,
                    isLast: true,
                    onTap: () => _showDeleteAccountDialog(context, auth, isDark),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Versi Aplikasi 1.0.0",
                style: TextStyle(color: textSecondary.withOpacity(0.5), fontSize: 12),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title, 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    required Color textColor,
    required Color iconColor,
    required Color subtitleColor,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast 
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : onTap != null ? BorderRadius.zero : const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: TextStyle(
                        fontWeight: FontWeight.w600, 
                        fontSize: 15, 
                        color: textColor
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle, 
                      style: TextStyle(fontSize: 12, color: subtitleColor) 
                    ),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconColor,
    required Color textColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
         borderRadius: isLast 
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title, 
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: 15, 
                color: textColor
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?', style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B))),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text('Hapus Akun?', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        content: Text(
          'Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus secara permanen.',
          style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await auth.deleteAccount();
              if (success && context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } else if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(auth.errorMessage ?? 'Gagal menghapus akun'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }
}
