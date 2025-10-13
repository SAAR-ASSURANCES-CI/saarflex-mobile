import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/user_model.dart';
import 'package:saarflex_app/data/services/profile_service.dart';
import 'package:saarflex_app/data/services/image_upload_service.dart';
import 'package:saarflex_app/core/utils/error_handler.dart';

/// ViewModel de profil - États UI uniquement
/// Responsabilité : Gestion des états UI et orchestration des services
class ProfileViewModel with ChangeNotifier {
  // Services - Logique métier déléguée
  final ProfileService _profileService = ProfileService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupération du profil utilisateur
  /// Délégation au service
  Future<User?> refreshUserProfile() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _profileService.getUserProfile();
      _setLoading(false);
      return user;
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
      _setLoading(false);
      return null;
    }
  }

  /// Mise à jour d'un champ spécifique
  /// Délégation au service
  Future<bool> updateSpecificField(String field, dynamic value) async {
    _setLoading(true);
    _clearError();

    try {
      await _profileService.updateProfileField(field, value);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Upload d'un avatar
  /// Délégation au service
  Future<bool> uploadAvatar(String imagePath) async {
    _setLoading(true);
    _clearError();

    try {
      await _imageUploadService.uploadAvatar(imagePath);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleUploadError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Mise à jour complète du profil
  /// Délégation au service
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    _clearError();

    try {
      await _profileService.updateProfile(profileData);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Upload d'un document d'identité
  /// Délégation au service
  Future<bool> uploadIdentityDocument(
    String imagePath,
    String documentType,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _imageUploadService.uploadIdentityDocument(imagePath, documentType);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleUploadError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Validation des données du profil
  /// Délégation au service
  Map<String, String> validateProfileData(Map<String, dynamic> data) {
    return _profileService.validateProfileData(data);
  }

  /// Vérification de la complétude du profil
  /// Délégation au service
  bool isProfileComplete(User user) {
    return _profileService.isProfileComplete(user);
  }

  /// Nettoyage des données utilisateur
  /// Logique UI uniquement
  void clearUserData() {
    _clearError();
    notifyListeners();
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
}
