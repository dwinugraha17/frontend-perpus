import 'package:flutter/material.dart';
import 'package:unilam_library/views/home/home_screen.dart';
import 'package:unilam_library/views/home/books_screen.dart';
import 'package:unilam_library/views/history/history_screen.dart';
import 'package:unilam_library/views/profile/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Daftar Halaman
  final List<Widget> _pages = [
    const HomeScreen(),
    const BooksScreen(), // Pastikan screen ini ada const constructor-nya jika memungkinkan
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Penting! Agar konten bisa muncul di belakang navbar yang melayang
      backgroundColor: Colors.grey[100], 
      
      // --- BODY DENGAN ANIMASI ---
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        // Animasi transisi: Fade + Sedikit Zoom
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex), // Key penting agar animasi jalan saat index berubah
          child: _pages[_currentIndex],
        ),
      ),

      // --- FLOATING NAVIGATION BAR ---
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Margin agar melayang
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25), // Sudut membulat
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1), // Bayangan lembut
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue.shade700, // Warna aktif
            unselectedItemColor: Colors.grey.shade400, // Warna tidak aktif
            showSelectedLabels: true,
            showUnselectedLabels: false, // Label hilang saat tidak aktif (lebih bersih)
            type: BottomNavigationBarType.fixed,
            elevation: 0, // Hilangkan elevation bawaan karena sudah pakai Container shadow
            items: [
              _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(Icons.menu_book_rounded, Icons.menu_book_outlined, 'Books'),
              _buildNavItem(Icons.history_rounded, Icons.history_outlined, 'History'),
              _buildNavItem(Icons.person_rounded, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk membuat item navbar lebih rapi
  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(inactiveIcon),
      activeIcon: Icon(activeIcon), // Icon berubah jadi solid saat aktif
      label: label,
    );
  }
}