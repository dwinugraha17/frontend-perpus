import 'dart:ui'; // Diperlukan untuk ImageFilter (Blur)
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:unilam_library/models/book_model.dart';
import 'package:unilam_library/providers/library_provider.dart';
import 'package:unilam_library/views/detail/pdf_viewer_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  // Helper untuk format tanggal sederhana (dd/mm/yyyy)
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showBorrowDialog(BuildContext context) async {
    DateTime borrowDate = DateTime.now();
    DateTime returnDate = DateTime.now().add(Duration(days: 7));
    final primaryColor = Colors.blue.shade700;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Formulir Peminjaman', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tentukan durasi peminjaman buku ini.",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              SizedBox(height: 20),
              _buildDateSelector(
                context, 
                "Tanggal Pinjam", 
                borrowDate, 
                (date) => setState(() => borrowDate = date),
                minDate: DateTime.now(),
              ),
              SizedBox(height: 12),
              _buildDateSelector(
                context, 
                "Tanggal Kembali", 
                returnDate, 
                (date) => setState(() => returnDate = date),
                minDate: borrowDate.add(Duration(days: 1)),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await Provider.of<LibraryProvider>(context, listen: false)
                    .borrowBook(book.id, borrowDate, returnDate);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Berhasil meminjam!' : 'Gagal meminjam'),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Konfirmasi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Picker Tanggal
  Widget _buildDateSelector(BuildContext context, String label, DateTime selectedDate, Function(DateTime) onSelect, {required DateTime minDate}) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate.isBefore(minDate) ? minDate : selectedDate,
          firstDate: minDate,
          lastDate: DateTime.now().add(Duration(days: 60)),
        );
        if (date != null) onSelect(date);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
                SizedBox(height: 2),
                Text(_formatDate(selectedDate), style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Icon(Icons.calendar_today, size: 18, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- APP BAR & IMAGE SECTION ---
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: primaryColor,
                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    // ignore: deprecated_member_use
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                    child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Blurred Background Image
                      CachedNetworkImage(
                        imageUrl: book.coverImage,
                        fit: BoxFit.cover,
                      ),
                      // 2. Blur Effect Overlay
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        // ignore: deprecated_member_use
                        child: Container(color: Colors.black.withOpacity(0.4)),
                      ),
                      // 3. Main Book Cover (Centered)
                      Center(
                        child: Hero(
                          tag: 'book-cover-${book.id}', // Tag harus sama dengan BooksScreen
                          child: Container(
                            height: 220,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: book.coverImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- CONTENT SECTION ---
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  transform: Matrix4.translationValues(0, -20, 0), // Overlap sedikit ke atas
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul & Penulis
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 40, height: 4,
                              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                              margin: EdgeInsets.only(bottom: 20),
                            ),
                            Text(
                              book.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            SizedBox(height: 8),
                            Text(
                              book.author,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Status Badge & Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoChip(Icons.star, "4.5 Rating", Colors.amber),
                          SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.check_circle, 
                            book.status, 
                            book.status == 'Available' ? Colors.green : Colors.orange
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 32),
                      Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Text(
                        book.description,
                        style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                      ),
                      SizedBox(height: 100), // Space agar konten tidak tertutup tombol bawah
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- BOTTOM ACTION BAR ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
                ],
              ),
              child: Row(
                children: [
                  // Tombol Baca (Primary)
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: book.pdfUrl != null
                          ? () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => PdfViewerScreen(url: book.pdfUrl!, title: book.title)))
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Baca Buku'),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Tombol Pinjam (Accent)
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: book.status == 'Available' ? () => _showBorrowDialog(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text('Pinjam Sekarang'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}