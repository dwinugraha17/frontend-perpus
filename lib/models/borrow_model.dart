import 'package:unilam_library/models/book_model.dart';

class BorrowModel {
  final String id;
  final BookModel book;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String status;

  BorrowModel({
    required this.id,
    required this.book,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
  });

  factory BorrowModel.fromJson(Map<String, dynamic> json) {
    return BorrowModel(
      id: json['id'],
      book: BookModel.fromJson(json['book']),
      borrowDate: DateTime.parse(json['borrow_date']),
      returnDate: DateTime.parse(json['return_date']),
      status: json['status'],
    );
  }
}
