import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';
  static const _keyEmail = 'email';
  static const _keyAvatarUrl = 'avatar_url';

  static Future<void> saveUser({
    required String userId,
    required String username,
    required String email,
    String avatarUrl = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyAvatarUrl, avatarUrl);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<Map<String, String>> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_keyUserId) ?? '',
      'username': prefs.getString(_keyUsername) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'avatar_url': prefs.getString(_keyAvatarUrl) ?? '',
    };
  }

  static Future<void> updateLocalUser({
    String? username,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (username != null) await prefs.setString(_keyUsername, username);
    if (avatarUrl != null) await prefs.setString(_keyAvatarUrl, avatarUrl);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyAvatarUrl);
  }

  static Future<bool> isLoggedIn() async {
    final id = await getUserId();
    return id != null && id.isNotEmpty;
  }
}
