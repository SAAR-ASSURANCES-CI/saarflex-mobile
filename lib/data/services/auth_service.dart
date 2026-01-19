import 'package:saarciflex_app/data/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _apiService.login(
        email: email,
        password: password,
      );
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signup({
    required String nom,
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _apiService.signup(
        nom: nom,
        email: email,
        password: password,
      );
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await _apiService.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp({required String email, required String code}) async {
    try {
      await _apiService.verifyOtp(email: email, code: code);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _apiService.resetPasswordWithCode(
        email: email,
        code: code,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkTokenValidity() async {
    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      return isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  Future<bool> initializeAuth() async {
    try {
      final isLoggedIn = await _apiService.isLoggedInWithTimeout();
      return isLoggedIn;
    } catch (e) {
      return false;
    }
  }
}
