class BookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImage;
  final String? pdfUrl;
  final String status;
  final String category;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImage,
    this.pdfUrl,
    required this.status,
    required this.category,
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
    );
  }
}
