import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilam_library/models/book_model.dart';
import 'package:unilam_library/models/review_model.dart';
import 'package:unilam_library/providers/library_provider.dart';
import 'package:unilam_library/views/detail/pdf_viewer_screen.dart';
import 'package:unilam_library/views/widgets/custom_network_image.dart';

class BookDetailScreen extends StatefulWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late BookModel _book;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _fetchBookDetail();
  }

  Future<void> _fetchBookDetail() async {
    setState(() => _isLoading = true);
    final updatedBook = await Provider.of<LibraryProvider>(context, listen: false)
        .getBookDetail(widget.book.id);
    
    if (mounted) {
      if (updatedBook != null) {
        setState(() {
          _book = updatedBook;
        });
      } else {
        // Optional: Show error if fetch fails (e.g. connectivity)
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Gagal memuat ulasan terbaru."))
        // );
      }
      setState(() => _isLoading = false);
    }
  }

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
                    .borrowBook(_book.id, borrowDate, returnDate);
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

  void _showReviewDialog() {
    int rating = 5;
    final commentController = TextEditingController();
    final primaryColor = Colors.blue.shade700;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Tulis Ulasan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar Anda (opsional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await Provider.of<LibraryProvider>(context, listen: false)
                    .addReview(_book.id, rating, commentController.text);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (success) {
                  _fetchBookDetail(); // Refresh details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ulasan berhasil dikirim!'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal mengirim ulasan (mungkin sudah pernah?)'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Kirim', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

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
                      CustomNetworkImage(
                        imageUrl: _book.coverImage,
                        fit: BoxFit.cover,
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        // ignore: deprecated_member_use
                        child: Container(color: Colors.black.withOpacity(0.4)),
                      ),
                      Center(
                        child: Hero(
                          tag: 'book-cover-${_book.id}',
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
                              child: CustomNetworkImage(
                                imageUrl: _book.coverImage,
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

              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  transform: Matrix4.translationValues(0, -20, 0),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 40, height: 4,
                              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                              margin: EdgeInsets.only(bottom: 20),
                            ),
                            Text(
                              _book.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _book.author,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoChip(
                            Icons.star, 
                            "${_book.averageRating.toStringAsFixed(1)} Rating", 
                            Colors.amber
                          ),
                          SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.check_circle,
                            _book.status,
                            _book.status == 'Available' ? Colors.green : Colors.orange
                          ),
                        ],
                      ),

                      SizedBox(height: 32),
                      Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Text(
                        _book.description,
                        style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                      ),
                      
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Ulasan Pembaca", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: _showReviewDialog,
                            child: Text("Tulis Ulasan"),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _isLoading && _book.reviews.isEmpty 
                          ? Center(child: CircularProgressIndicator())
                          : _buildReviewsList(),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

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
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _book.pdfUrl != null
                          ? () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => PdfViewerScreen(url: _book.pdfUrl!, title: _book.title)))
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
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _book.status == 'Available' ? () => _showBorrowDialog(context) : null,
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

  Widget _buildReviewsList() {
    if (_book.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Belum ada ulasan.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return Column(
      children: _book.reviews.map((review) => _buildReviewItem(review)).toList(),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: review.userPhoto != null 
                    ? NetworkImage(review.userPhoto!) 
                    : null,
                child: review.userPhoto == null 
                    ? Icon(Icons.person, size: 20) 
                    : null,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                    )
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(review.comment!, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
          ]
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
