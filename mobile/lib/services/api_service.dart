import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/artwork.dart';
import '../models/notification.dart';

class ApiService {
  static const String baseUrl = 'http://10.254.20.74:8080';

  final String? userId;

  ApiService({this.userId});

  Map<String, String> get _headers {
    final h = {'Content-Type': 'application/json'};
    if (userId != null && userId!.isNotEmpty) {
      h['X-User-Id'] = userId!;
    }
    return h;
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    _checkStatus(res);
    return User.fromJson(jsonDecode(res.body)['data']);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    _checkStatus(res);
    return User.fromJson(jsonDecode(res.body)['data']);
  }

  Future<User> getProfile(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/$id'),
      headers: _headers,
    );
    _checkStatus(res);
    return User.fromJson(jsonDecode(res.body)['data']);
  }

  Future<User> updateProfile(
    String id, {
    String? username,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final res = await http.patch(
      Uri.parse('$baseUrl/users/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return User.fromJson(jsonDecode(res.body)['data']);
  }

  Future<List<Artwork>> getFeed({int limit = 20, int offset = 0}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/artworks/feed?limit=$limit&offset=$offset'),
      headers: _headers,
    );
    _checkStatus(res);
    final list = jsonDecode(res.body)['data'] as List? ?? [];
    return list.map((e) => Artwork.fromJson(e)).toList();
  }

  Future<List<Artwork>> getUserArtworks(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await http.get(
      Uri.parse(
          '$baseUrl/users/$userId/artworks?limit=$limit&offset=$offset'),
      headers: _headers,
    );
    _checkStatus(res);
    final list = jsonDecode(res.body)['data'] as List? ?? [];
    return list.map((e) => Artwork.fromJson(e)).toList();
  }

  Future<Artwork> createArtwork({
    required String title,
    required int width,
    required int height,
    required Map<String, String> pixels,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/artworks'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'width': width,
        'height': height,
        'pixels': pixels,
      }),
    );
    _checkStatus(res);
    return Artwork.fromJson(jsonDecode(res.body)['data']);
  }

  Future<void> likeArtwork(String artworkId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/artworks/$artworkId/like'),
      headers: _headers,
    );
    _checkStatus(res);
  }

  Future<void> unlikeArtwork(String artworkId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/artworks/$artworkId/like'),
      headers: _headers,
    );
    _checkStatus(res);
  }

  Future<List<AppNotification>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    final res = await http.get(
      Uri.parse(
          '$baseUrl/notifications?limit=$limit&offset=$offset'),
      headers: _headers,
    );
    _checkStatus(res);
    final list = jsonDecode(res.body)['data'] as List;
    return list.map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final res = await http.get(
      Uri.parse('$baseUrl/notifications/unread'),
      headers: _headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body)['data']['unread'] as int;
  }

  Future<void> markAllNotificationsRead() async {
    final res = await http.patch(
      Uri.parse('$baseUrl/notifications/read'),
      headers: _headers,
    );
    _checkStatus(res);
  }

  void _checkStatus(http.Response res) {
    if (res.statusCode >= 400) {
      String message = 'Request failed (${res.statusCode})';
      try {
        final body = jsonDecode(res.body);
        message = body['error'] ?? message;
      } catch (_) {}
      throw ApiException(message, res.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
