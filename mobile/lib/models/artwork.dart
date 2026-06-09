import 'user.dart';

class Artwork {
  final String id;
  final String userId;
  final User? author;
  final String title;
  final int width;
  final int height;
  final Map<String, String> pixels;
  int likeCount;
  bool liked;
  final DateTime createdAt;
  final DateTime updatedAt;

  Artwork({
    required this.id,
    required this.userId,
    this.author,
    required this.title,
    required this.width,
    required this.height,
    required this.pixels,
    required this.likeCount,
    required this.liked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    Map<String, String> pixelMap = {};
    if (json['pixels'] != null) {
      (json['pixels'] as Map<String, dynamic>).forEach((k, v) {
        pixelMap[k] = v.toString();
      });
    }
    return Artwork(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      title: json['title'] ?? '',
      width: json['width'] ?? 16,
      height: json['height'] ?? 16,
      pixels: pixelMap,
      likeCount: json['like_count'] ?? 0,
      liked: json['liked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}
