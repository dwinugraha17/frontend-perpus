import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:unilam_library/models/book_model.dart';
import 'package:unilam_library/models/borrow_model.dart';
import 'package:unilam_library/services/api_service.dart';

class LibraryProvider with ChangeNotifier {
  List<BookModel> _books = [];
  List<BorrowModel> _history = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<BookModel> get books => _books;
  List<BorrowModel> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/books');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _books = data.map((json) => BookModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/history');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _history = data.map((json) => BorrowModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> borrowBook(String bookId, DateTime borrowDate, DateTime returnDate) async {
    try {
      final response = await _apiService.post('/borrow', {
        'book_id': bookId,
        'borrow_date': borrowDate.toIso8601String(),
        'return_date': returnDate.toIso8601String(),
      });
      return response.statusCode == 201;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
