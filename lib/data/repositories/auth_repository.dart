import 'package:saarciflex_app/data/services/auth_service.dart';
import 'package:saarciflex_app/data/services/api_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.login(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signup({
    required String nom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    try {
      return await _authService.signup(
        nom: nom,
        email: email,
        telephone: telephone,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await _authService.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      await _authService.verifyOtp(email: email, code: code);
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
      await _authService.resetPasswordWithCode(
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
      return await _authService.checkTokenValidity();
    } catch (e) {
      return false;
    }
  }

  Future<bool> initializeAuth() async {
    try {
      return await _authService.initializeAuth();
    } catch (e) {
      return false;
    }
  }
}

