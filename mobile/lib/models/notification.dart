import 'user.dart';

class AppNotification {
  final String id;
  final String userId;
  final String actorId;
  final User? actor;
  final String type;
  final String? artworkId;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.actorId,
    this.actor,
    required this.type,
    this.artworkId,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      actorId: json['actor_id'] ?? '',
      actor: json['actor'] != null ? User.fromJson(json['actor']) : null,
      type: json['type'] ?? '',
      artworkId: json['artwork_id'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
