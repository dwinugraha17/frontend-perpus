class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userId: user['id']?.toString() ?? 'unknown',
      userName: user['name'] ?? 'Anonymous',
      userPhoto: user['profile_photo'],
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}