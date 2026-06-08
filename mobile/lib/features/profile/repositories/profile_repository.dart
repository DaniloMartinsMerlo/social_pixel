import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/repositories/auth_repository.dart';

class ProfileRepository {
  const ProfileRepository({this.authRepository = const AuthRepository()});

  final AuthRepository authRepository;

  Future<UserModel> getProfile(String userId) {
    return authRepository.fetchProfile(userId);
  }

  Future<UserModel> updateProfile({
    required String userId,
    String? username,
    String? avatarUrl,
  }) {
    return authRepository.updateProfile(userId: userId, username: username, avatarUrl: avatarUrl);
  }
}