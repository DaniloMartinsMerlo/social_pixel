import 'package:flutter/foundation.dart';

import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthRepository? authRepository}) : _authRepository = authRepository ?? const AuthRepository();

  final AuthRepository _authRepository;

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    return _run(() async {
      user = await _authRepository.login(email: email, password: password);
    });
  }

  Future<bool> register(String username, String email, String password) async {
    return _run(() async {
      user = await _authRepository.register(username: username, email: email, password: password);
    });
  }

  Future<void> loadStoredProfile() async {
    final storedUser = await _authRepository.getStoredProfile();
    user = storedUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    user = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}