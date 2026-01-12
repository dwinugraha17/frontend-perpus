import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilam_library/providers/library_provider.dart';
import 'package:unilam_library/views/detail/book_detail_screen.dart';
import 'package:unilam_library/views/widgets/custom_network_image.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "Semua";
  final List<String> _categories = [
    "Semua",
    "Teknologi",
    "Fiksi",
    "Sains",
    "Bisnis",
    "Sejarah",
    "Seni",
    "Hukum"
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);
    
    // Filter logic
    final filteredBooks = library.books.where((book) {
      final matchesSearch = book.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            book.author.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == "Semua" || book.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Koleksi Perpustakaan',
              style: TextStyle(
                color: Color(0xFF1E293B), // Slate 800
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Slate 100
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari judul, penulis, atau ISBN...',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13.5),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                              onPressed: () => setState(() => _searchController.clear()),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. CATEGORY CHIPS
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.1), // Blue 600 with opacity
                      checkmarkColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade200,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. BOOK GRID
          library.isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : filteredBooks.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada buku ditemukan',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62, // Taller cards
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final book = filteredBooks[index];
                            return _buildBookCard(context, book);
                          },
                          childCount: filteredBooks.length,
                        ),
                      ),
                    ),
                    
          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, dynamic book) {
    final isAvailable = book.status == 'Available';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Hero(
                      tag: 'book-cover-${book.id ?? book.title}',
                      child: CustomNetworkImage(
                        imageUrl: book.coverImage,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          color: Colors.grey[100],
                          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                        ),
                        errorWidget: Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay for text readability (optional, mostly for style)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green.withValues(alpha: 0.9) : Colors.orange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        isAvailable ? 'Tersedia' : 'Dipinjam',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // INFO SECTION
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.category ?? 'Umum',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2563EB), // Primary Blue
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B), // Slate 800
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B), // Slate 500
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}