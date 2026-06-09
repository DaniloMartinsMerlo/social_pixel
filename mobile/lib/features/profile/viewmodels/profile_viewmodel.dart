import 'package:flutter/foundation.dart';

import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/profile/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({ProfileRepository? profileRepository, LocalStorage? localStorage})
      : _profileRepository = profileRepository ?? const ProfileRepository(),
        _localStorage = localStorage ?? const LocalStorage();

  final ProfileRepository _profileRepository;
  final LocalStorage _localStorage;

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = await _requireUserId();
      user = await _profileRepository.getProfile(userId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? username, String? avatarUrl}) async {
    final userId = await _requireUserId();
    user = await _profileRepository.updateProfile(
      userId: userId,
      username: username,
      avatarUrl: avatarUrl,
    );
    notifyListeners();
  }

  Future<String> _requireUserId() async {
    final userId = await _localStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('No user session found');
    }
    return userId;
  }
}