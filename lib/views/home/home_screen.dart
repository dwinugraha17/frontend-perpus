// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilam_library/providers/auth_provider.dart';
import 'package:unilam_library/providers/library_provider.dart';
import 'package:unilam_library/views/detail/book_detail_screen.dart';
import 'package:unilam_library/views/widgets/custom_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentCarousel = 0;
  final ScrollController _scrollController = ScrollController();

  // DAFTAR KATEGORI (Tanpa "Semua" karena akan ditampilkan per section)
  final List<String> _categories = [
    "Teknologi",
    "Novel",
    "Bisnis",
    "Sains",
    "Sejarah",
    "Desain",
  ];

  // DEFINISI WARNA TEMA
  final Color primaryColor = const Color(0xFF2563EB);
  final Color backgroundColor = const Color(0xFFF8FAFC);
  final Color textPrimary = const Color(0xFF1E293B);
  final Color textSecondary = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      Provider.of<LibraryProvider>(context, listen: false).fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final library = Provider.of<LibraryProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Unilam Library',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage: auth.user?.profilePhoto != null
                    ? (kIsWeb
                        ? NetworkImage(auth.user!.profilePhoto!)
                        : CachedNetworkImageProvider(auth.user!.profilePhoto!)) as ImageProvider
                    : null,
                child: auth.user?.profilePhoto == null
                    ? Icon(Icons.person, color: Colors.grey[400], size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: library.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  _buildHeader(auth),

                  const SizedBox(height: 20),

                  // --- CAROUSEL (REKOMENDASI) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Rekomendasi untukmu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCarousel(library),

                  const SizedBox(height: 10),

                  // --- DAFTAR BUKU PER KATEGORI (LOOPING) ---
                  // Kita melakukan looping untuk setiap kategori di daftar _categories
                  ..._categories.map((category) {
                    // Ambil buku sesuai kategori saat ini
                    final booksByCategory = library.books
                        .where((book) => book.category == category)
                        .toList();

                    // Jika tidak ada buku di kategori ini, jangan tampilkan section-nya
                    if (booksByCategory.isEmpty) return const SizedBox.shrink();

                    return _buildCategorySection(category, booksByCategory);
                  }),
                ],
              ),
            ),
    );
  }

  // --- WIDGET SECTION PER KATEGORI ---
  Widget _buildCategorySection(String title, List<dynamic> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Judul Kategori
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  // Aksi Lihat Semua (Opsional)
                },
                child: Text(
                  "Lihat Semua",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // List Horizontal
        SizedBox(
          height: 260, // Tinggi area scroll horizontal
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal, // Scroll Samping
            physics: const BouncingScrollPhysics(),
            itemCount: books.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final book = books[index];
              return SizedBox(
                width: 150, // Lebar tetap untuk setiap kartu buku
                child: _buildBookCard(context, book),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- WIDGET KARTU BUKU (Vertical Card) ---
  Widget _buildBookCard(BuildContext context, dynamic book) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cover Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    CustomNetworkImage(
                      imageUrl: book.coverImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        color: Colors.grey[200],
                        child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: primaryColor)),
                      ),
                      errorWidget: Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                    // Status Badge (Available/Borrowed)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(
                          book.status == 'Available'
                              ? Icons.check_circle
                              : Icons.access_time_filled,
                          size: 14,
                          color: book.status == 'Available'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 2. Info Buku
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
           const SizedBox(height: 4),
           Row(
             children: [
                const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  "4.8", 
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textPrimary),
                ),
             ],
           )
        ],
      ),
    );
  }

  // --- WIDGET HEADER ---
  Widget _buildHeader(AuthProvider auth) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Halo, ',
                  style: TextStyle(fontSize: 24, color: textSecondary),
                ),
                TextSpan(
                  text: (auth.user?.name ?? "User").split(' ')[0],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const TextSpan(text: ' 👋'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Apa yang ingin kamu baca hari ini?',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari judul, penulis, atau ISBN...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
                icon: Icon(Icons.search_rounded, color: primaryColor),
                suffixIcon: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.tune_rounded,
                    color: textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CAROUSEL ---
  Widget _buildCarousel(LibraryProvider library) {
    if (library.books.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text("Belum ada rekomendasi")),
      );
    }
    return Column(
      children: [
        CarouselSlider(
          items: library.books.take(5).map((book) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, const Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: -30,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -10,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "Pilihan Terpopuler",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                book.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                book.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Hero(
                            tag: 'carousel-${book.id}',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(4, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CustomNetworkImage(
                                  imageUrl: book.coverImage,
                                  fit: BoxFit.cover,
                                  height: 110,
                                  placeholder: Container(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  errorWidget: Container(
                                        color: Colors.grey,
                                        child: const Icon(Icons.book),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.2,
            enlargeCenterPage: true,
            viewportFraction: 0.88,
            onPageChanged: (index, reason) =>
                setState(() => _currentCarousel = index),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: library.books.take(5).toList().asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentCarousel == entry.key ? 24 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentCarousel == entry.key
                    ? primaryColor
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
