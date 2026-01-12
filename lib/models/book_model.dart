import 'package:unilam_library/models/review_model.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImage;
  final String? pdfUrl;
  final String status;
  final String category;
  final double averageRating;
  final List<ReviewModel> reviews;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImage,
    this.pdfUrl,
    required this.status,
    required this.category,
    this.averageRating = 0.0,
    this.reviews = const [],
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      coverImage: json['cover_image'],
      pdfUrl: json['pdf_url'],
      status: json['status'],
      category: json['category'] ?? 'Umum',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List?)
          ?.map((e) => ReviewModel.fromJson(e))
          .toList() ?? [],
    );
  }
}
