import 'package:flutter/material.dart';
import '../theme.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final double radius;

  const UserAvatar({
    super.key,
    required this.avatarUrl,
    required this.username,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        username.isNotEmpty ? username[0].toUpperCase() : '?';
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl),
        backgroundColor: AppColors.primary,
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
