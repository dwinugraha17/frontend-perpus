import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilam_library/providers/auth_provider.dart';
import 'package:unilam_library/views/auth/login_screen.dart';
import 'package:unilam_library/views/profile/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    // Define colors
    final primaryColor = const Color(0xFF2563EB); // Blue 600
    final backgroundColor = const Color(0xFFF8FAFC); // Slate 50
    final textPrimary = const Color(0xFF1E293B); // Slate 800
    final textSecondary = const Color(0xFF64748B); // Slate 500

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
            // --- HEADER SECTION (CARD) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with Border
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 2),
                    ),
                    child: ClipOval(
                      child: user?.profilePhoto != null
                          ? CachedNetworkImage(
                              key: ValueKey(user!.profilePhoto!),
                              imageUrl: user.profilePhoto!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[100],
                                child: Icon(Icons.person, size: 48, color: Colors.grey[400]),
                              ),
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: Icon(Icons.person, size: 48, color: Colors.grey[400]),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Guest',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.email ?? 'No Email',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // --- SECTION INFO PRIBADI ---
            _buildSectionHeader("Informasi Pribadi"),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- SECTION PENGATURAN ---
            _buildSectionHeader("Akun & Keamanan"),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
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
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(height: 1, color: Colors.grey[100]),
                  ),
                  _buildProfileTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Keluar dari akun aplikasi',
                    textColor: const Color(0xFFDC2626), // Red 600
                    iconColor: const Color(0xFFDC2626),
                    isLast: true,
                    onTap: () => _showLogoutDialog(context, auth),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Versi Aplikasi 1.0.0",
                style: TextStyle(color: textSecondary.withValues(alpha: 0.5), fontSize: 12),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title, 
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: Color(0xFF64748B), // Slate 500
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color textColor = const Color(0xFF1E293B), // Slate 800
    Color iconColor = const Color(0xFF2563EB), // Blue 600
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
                  color: iconColor.withValues(alpha: 0.1),
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
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)) // Slate 400
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

  // --- LOGOUT DIALOG ---
  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?', style: TextStyle(color: Color(0xFF64748B))),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
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
}