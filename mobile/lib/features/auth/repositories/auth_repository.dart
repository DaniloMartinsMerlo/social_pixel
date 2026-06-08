import 'package:mobile/core/services/api_service.dart';
import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/features/auth/models/user_model.dart';

class AuthRepository {
  const AuthRepository({this.apiService = const ApiService(), this.localStorage = const LocalStorage()});

  final ApiService apiService;
  final LocalStorage localStorage;

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await apiService.postJson(
      '/users/register',
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    final user = _extractUser(response);
    await localStorage.saveUserId(user.id);
    return user;
  }

  Future<UserModel> login({required String email, required String password}) async {
    final response = await apiService.postJson(
      '/users/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    final user = _extractUser(response);
    await localStorage.saveUserId(user.id);
    return user;
  }

  Future<UserModel?> getStoredProfile() async {
    final userId = await localStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return fetchProfile(userId);
  }

  Future<UserModel> fetchProfile(String userId) async {
    final response = await apiService.getJson('/users/$userId');
    return _extractUser(response);
  }

  Future<UserModel> updateProfile({
    required String userId,
    String? username,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) {
      body['username'] = username;
    }
    if (avatarUrl != null) {
      body['avatar_url'] = avatarUrl;
    }

    final response = await apiService.patchJson(
      '/users/$userId',
      body: body,
    );
    return _extractUser(response);
  }

  Future<void> logout() async {
    await localStorage.clearUserId();
  }

  UserModel _extractUser(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    if (response['id'] != null) {
      return UserModel.fromJson(response);
    }
    throw const FormatException('Unexpected user response');
  }
}