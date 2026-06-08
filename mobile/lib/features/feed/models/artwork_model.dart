import 'package:mobile/features/auth/models/user_model.dart';

class ArtworkModel {
  const ArtworkModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.width,
    required this.height,
    required this.pixels,
    required this.likeCount,
    required this.liked,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  final String id;
  final String userId;
  final String title;
  final int width;
  final int height;
  final Map<String, String> pixels;
  final int likeCount;
  final bool liked;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserModel? author;

  factory ArtworkModel.fromJson(Map<String, dynamic> json) {
    final rawPixels = json['pixels'];
    final pixelMap = <String, String>{};

    if (rawPixels is Map) {
      rawPixels.forEach((key, value) {
        pixelMap[key.toString()] = value.toString();
      });
    }

    return ArtworkModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      width: _asInt(json['width']),
      height: _asInt(json['height']),
      pixels: pixelMap,
      likeCount: _asInt(json['like_count']),
      liked: json['liked'] == true,
      createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null ? null : DateTime.tryParse(json['updated_at'].toString()),
      author: json['author'] is Map<String, dynamic> ? UserModel.fromJson(json['author'] as Map<String, dynamic>) : null,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}