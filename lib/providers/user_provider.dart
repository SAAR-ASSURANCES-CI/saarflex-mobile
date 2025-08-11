// providers/user_provider.dart - VERSION SIMPLIFIÉE
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<User?> refreshUserProfile() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _apiService.getUserProfile();
      _setLoading(false);
      return user;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return null;
    } catch (e) {
      _setError('Erreur lors du chargement du profil');
      _setLoading(false);
      return null;
    }
  }

  // Mettre à jour des informations spécifiques du profil
  Future<bool> updateSpecificField(String field, dynamic value) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.updateProfile({field: value});
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Erreur lors de la mise à jour');
      _setLoading(false);
      return false;
    }
  }

  // Upload d'avatar (si nécessaire plus tard)
  Future<bool> uploadAvatar(String imagePath) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implémenter l'upload d'image quand l'API sera prête
      // await _apiService.uploadAvatar(imagePath);
      
      // Pour l'instant, simuler
      await Future.delayed(Duration(seconds: 2));
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'upload de l\'image');
      _setLoading(false);
      return false;
    }
  }

  // Effacer les données utilisateur (appelé lors de la déconnexion)
  void clearUserData() {
    _clearError();
    notifyListeners();
  }

  // Méthodes utilitaires privées
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
}