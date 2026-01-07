// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilam_library/providers/auth_provider.dart';
import 'package:unilam_library/providers/library_provider.dart';
import 'package:unilam_library/views/detail/book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentCarousel = 0;
  final ScrollController _scrollController = ScrollController();

  // 1. STATE KATEGORI
  final List<String> _categories = [
    "Semua",
    "Teknologi",
    "Novel",
    "Bisnis",
    "Sains",
    "Sejarah",
    "Desain"
  ];
  String _selectedCategory = "Semua";

  // DEFINISI WARNA TEMA
  final Color primaryColor = const Color(0xFF2563EB); // Modern Blue
  final Color backgroundColor = const Color(0xFFF8FAFC); // Very Light Blue-Grey
  final Color textPrimary = const Color(0xFF1E293B); // Slate 800
  final Color textSecondary = const Color(0xFF64748B); // Slate 500

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

    // 2. LOGIKA FILTER BUKU
    final filteredBooks = _selectedCategory == "Semua"
        ? library.books
        : library.books
            .where((book) => book.category == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Mencegah perubahan warna saat scroll
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.menu_book_rounded, color: primaryColor, size: 20),
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
                    ? CachedNetworkImageProvider(auth.user!.profilePhoto!)
                    : null,
                child: auth.user?.profilePhoto == null
                    ? Icon(Icons.person, color: Colors.grey[400], size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            _buildHeader(auth),

            const SizedBox(height: 20),

            // --- CAROUSEL (REKOMENDASI) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Rekomendasi',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: textSecondary)
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCarousel(library),

            const SizedBox(height: 24),

            // --- 3. CATEGORY SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("Kategori Pilihan",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary)),
            ),
            const SizedBox(height: 16),
            _buildCategoryList(),

            const SizedBox(height: 24),

            // --- LIST BUKU SECTION ---
            Container(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 20,
                      offset: Offset(0, -5))
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jelajahi Buku',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${filteredBooks.length} Buku',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  library.isLoading
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: primaryColor),
                        ))
                      : filteredBooks.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off_rounded,
                                        size: 60, color: Colors.grey[200]),
                                    const SizedBox(height: 16),
                                    Text("Buku tidak ditemukan",
                                        style: TextStyle(color: textSecondary)),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredBooks.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final book = filteredBooks[index];
                                return _buildBookCard(context, book);
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER (Improved) ---
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
                    style: TextStyle(fontSize: 24, color: textSecondary)),
                TextSpan(
                    text: (auth.user?.name ?? "User").split(' ')[0],
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary)),
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
                  child: Icon(Icons.tune_rounded, color: textSecondary, size: 20),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET CATEGORY LIST (Pill Style) ---
  Widget _buildCategoryList() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color:
                      isSelected ? primaryColor : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET CAROUSEL (Improved Visuals) ---
  Widget _buildCarousel(LibraryProvider library) {
    if (library.books.isEmpty) {
      return const SizedBox(
          height: 180, child: Center(child: Text("Belum ada rekomendasi")));
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
                  // Background Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          const Color(0xFF1E40AF)
                        ], // Blue gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5))
                      ],
                    ),
                  ),
                  // Background Decoration
                  Positioned(
                      right: -30,
                      top: -30,
                      child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white.withOpacity(0.08))),
                  Positioned(
                      bottom: -20,
                      left: -10,
                      child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.08))),

                  // Content
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
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6)),
                                child: const Text("Editor's Choice",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 12),
                              Text(book.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2)),
                              const SizedBox(height: 6),
                              Text(book.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13)),
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
                                      offset: const Offset(4, 6))
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                    imageUrl: book.coverImage,
                                    fit: BoxFit.cover,
                                    height: 110,
                                    placeholder: (context, url) => Container(
                                        color: Colors.white.withOpacity(0.2)),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                            color: Colors.grey,
                                            child: const Icon(Icons.book))),
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
                  setState(() => _currentCarousel = index)),
        ),
        const SizedBox(height: 12),
        // Indicator
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
                      : Colors.grey.shade300),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- WIDGET KARTU BUKU (Improved Layout) ---
  Widget _buildBookCard(BuildContext context, dynamic book) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BookDetailScreen(book: book))),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                Hero(
                  tag: 'book-cover-${book.id ?? book.title}',
                  child: Container(
                    width: 75,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: book.coverImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[100]),
                        errorWidget: (context, url, error) => Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              book.category.toUpperCase() ?? "UMUM",
                              style: TextStyle(
                                  fontSize: 9,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Icon(Icons.more_horiz,
                              color: Colors.grey[300], size: 20)
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 16, color: Colors.amber[400]),
                          const SizedBox(width: 4),
                          Text("4.8",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary)),
                          const SizedBox(width: 12),
                          _buildStatusBadge(book.status),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isAvailable = status == 'Available';
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAvailable ? Colors.green : Colors.orange),
        ),
        const SizedBox(width: 6),
        Text(
          isAvailable ? "Tersedia" : "Dipinjam",
          style: TextStyle(
              color: isAvailable ? Colors.green[700] : Colors.orange[800],
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}