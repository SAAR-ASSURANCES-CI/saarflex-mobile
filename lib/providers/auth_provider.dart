import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  // États simples
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _errorMessage;

  // Getters (pour lire les états)
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get errorMessage => _errorMessage;

  // Méthode d'inscription
  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simuler l'appel API
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Remplacer par votre vrai appel API
      // final response = await _apiService.signup(...);

      // Simuler le succès
      _userName = name;
      _userEmail = email;
      _isLoggedIn = true;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la création du compte');
      _setLoading(false);
      return false;
    }
  }

  // Méthode de connexion
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      // Simuler l'appel API
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Remplacer par votre vrai appel API
      // final response = await _apiService.login(...);

      // Simuler le succès
      _userEmail = email;
      _userName = 'Jean KOUAME'; // Récupéré de l'API
      _isLoggedIn = true;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Email ou mot de passe incorrect');
      _setLoading(false);
      return false;
    }
  }

  // Méthode de déconnexion
  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _clearError();
    notifyListeners();
  }

  // Méthodes privées pour modifier les états
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Notifie tous les widgets qui écoutent
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
