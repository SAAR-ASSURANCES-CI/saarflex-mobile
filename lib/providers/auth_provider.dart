import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _currentUser;
  String? _errorMessage;
  String? _authToken;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get authToken => _authToken;

  String get userName => _currentUser?.displayName ?? 'Utilisateur';
  String get userEmail => _currentUser?.email ?? '';
  bool get isClient => _currentUser?.isClient ?? true;
  bool get isAgent => _currentUser?.isAgent ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      if (isLoggedIn) {
        await loadUserProfile();
      }
    } catch (e) {
      debugPrint('Erreur d\'initialisation auth: $e');
      _isLoggedIn = false;
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup({
    required String nom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _apiService.signup(
        nom: nom,
        email: email,
        telephone: telephone,
        password: password,
      );

      _currentUser = authResponse.user;
      _authToken = authResponse.token;
      _isLoggedIn = true;

      _setLoading(false);
      return true;

    } on ApiException catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Erreur lors de la création du compte');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _apiService.login(
        email: email,
        password: password,
      );

      _currentUser = authResponse.user;
      _authToken = authResponse.token;
      _isLoggedIn = true;

      _setLoading(false);
      return true;

    } on ApiException catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Erreur de connexion');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiService.logout();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }

    _isLoggedIn = false;
    _currentUser = null;
    _authToken = null;
    _clearError();
    _setLoading(false);
  }

  Future<void> loadUserProfile() async {
    if (!_isLoggedIn) return;

    try {
      final user = await _apiService.getUserProfile();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur de chargement du profil: $e');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (!_isLoggedIn) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _apiService.updateProfile(updates);
      _currentUser = updatedUser;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du profil');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.resetPassword(email);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Erreur lors de la réinitialisation');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(ApiException e) {
    if (e.statusCode == 401) {
      return 'Email ou mot de passe incorrect';
    } else if (e.statusCode == 422) {
      return e.message;
    } else if (e.message.contains('connexion internet')) {
      return 'Vérifiez votre connexion internet';
    }
    return e.message;
  }

  bool hasRole(TypeUtilisateur role) {
    return _currentUser?.typeUtilisateur == role;
  }

  bool canAccess(List<TypeUtilisateur> allowedRoles) {
    if (_currentUser == null) return false;
    return allowedRoles.contains(_currentUser!.typeUtilisateur);
  }
}