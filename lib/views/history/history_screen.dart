import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:unilam_library/providers/library_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      Provider.of<LibraryProvider>(context, listen: false).fetchHistory();
    });
  }

  void _showReturnDialog(BuildContext context, String borrowingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kembalikan Buku?'),
        content: const Text('Apakah Anda yakin ingin mengembalikan buku ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              final success = await Provider.of<LibraryProvider>(context, listen: false)
                  .returnBook(borrowingId);
              
              if (mounted) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Buku berhasil dikembalikan' : 'Gagal mengembalikan buku'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Kembalikan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Riwayat Peminjaman',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: library.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : library.history.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: library.history.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = library.history[index];
                    return _buildHistoryCard(item);
                  },
                ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    final bool isBorrowed = item.status.toLowerCase() == 'borrowed';

    return Container(
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.book_rounded, color: Color(0xFF2563EB), size: 24),
              ),
              const SizedBox(width: 16),
              // Title & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(item.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          // Dates Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateColumn('Dipinjam', item.borrowDate),
              _buildDateColumn('Dikembalikan', item.returnDate),
            ],
          ),
          // Return Button
          if (isBorrowed) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showReturnDialog(context, item.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Kembalikan Buku'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    String label;
    IconData icon;
    String statusLower = status.toLowerCase();

    if (statusLower == 'borrowed') {
        color = const Color(0xFF2563EB); // Blue
        bgColor = const Color(0xFFEFF6FF); // Blue 50
        label = 'Sedang Dipinjam';
        icon = Icons.timer_outlined;
    } else if (statusLower == 'returned') {
        color = const Color(0xFF16A34A); // Green
        bgColor = const Color(0xFFF0FDF4); // Green 50
        label = 'Dikembalikan';
        icon = Icons.check_circle_outline;
    } else if (statusLower == 'late') {
        color = const Color(0xFFDC2626); // Red
        bgColor = const Color(0xFFFEF2F2); // Red 50
        label = 'Terlambat';
        icon = Icons.warning_amber_rounded;
    } else {
        color = const Color(0xFF64748B); // Slate
        bgColor = const Color(0xFFF1F5F9); // Slate 100
        label = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: const Icon(Icons.history_edu_rounded, size: 64, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada riwayat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Buku yang Anda pinjam akan muncul di sini',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}