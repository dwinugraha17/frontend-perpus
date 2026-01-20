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

  Future<void> fetchBooks({String search = '', String category = 'Semua'}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final queryParams = <String, String>{};
      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != 'Semua') {
        queryParams['category'] = category;
      }

      final response = await _apiService.get('/books', queryParams: queryParams);
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

  Future<BookModel?> getBookDetail(String bookId) async {
    try {
      final response = await _apiService.get('/books/$bookId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Book Details Fetched: ${data['title']}');
        if (data['reviews'] != null) {
           debugPrint('Reviews count: ${(data['reviews'] as List).length}');
           // debugPrint('First review: ${data['reviews'][0]}');
        } else {
           debugPrint('Reviews key is null/missing');
        }
        return BookModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching book detail: $e');
    }
    return null;
  }

  Future<bool> addReview(String bookId, int rating, String comment) async {
    try {
      final response = await _apiService.post('/books/$bookId/reviews', {
        'rating': rating,
        'comment': comment,
      });
      return response.statusCode == 201;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> returnBook(String borrowingId) async {
    try {
      final response = await _apiService.post('/return/$borrowingId', {});
      if (response.statusCode == 200) {
        await fetchHistory(); // Refresh history list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
