class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final DateTime? createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}