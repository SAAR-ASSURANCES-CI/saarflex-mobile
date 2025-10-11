import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saarflex_app/data/services/auth_service.dart';
import 'package:saarflex_app/data/services/user_service.dart';
import 'package:saarflex_app/data/services/file_upload_service.dart';
import 'package:saarflex_app/data/models/user_model.dart';
import 'package:saarflex_app/core/utils/error_handler.dart';
import 'package:saarflex_app/core/utils/logger.dart';

class AuthViewModel extends ChangeNotifier {
  // Services - Logique métier déléguée
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final FileUploadService _fileUploadService = FileUploadService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _currentUser;
  String? _errorMessage;
  String? _authToken;

  bool _isUploadingDocument = false;
  String? _uploadErrorMessage;
  double _uploadProgress = 0.0;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get authToken => _authToken;
  bool get isUploadingDocument => _isUploadingDocument;
  String? get uploadErrorMessage => _uploadErrorMessage;
  double get uploadProgress => _uploadProgress;

  String get userName => _currentUser?.displayName ?? 'Utilisateur';
  String get userEmail => _currentUser?.email ?? '';
  bool get isClient => _currentUser?.isClient ?? true;
  bool get isAgent => _currentUser?.isAgent ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isProfileComplete => _currentUser?.isProfileComplete ?? false;

  /// Initialisation de l'authentification
  /// Vérifie le statut de connexion au démarrage
  /// RÈGLE: Reload → Déconnexion immédiate
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      // RÈGLE 2: Reload détecté → Déconnexion immédiate
      await _handleReloadLogout();

      final isLoggedIn = await _authService.initializeAuth();
      _isLoggedIn = isLoggedIn;

      if (isLoggedIn) {
        await loadUserProfile();
      }
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
      _setError(ErrorHandler.handleAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Gestion de la déconnexion au reload
  /// RÈGLE 2: Reload → Déconnexion immédiate
  Future<void> _handleReloadLogout() async {
    try {
      // Vérifier si c'est un reload (app redémarrée)
      // Si l'app démarre et qu'il y a des données de session, c'est un reload
      final hasStoredToken = await _authService.checkTokenValidity();

      if (hasStoredToken) {
        // RÈGLE 2: Reload détecté → Déconnexion immédiate
        AppLogger.error('🔄 Reload détecté - Déconnexion immédiate');
        await _authService.logout();
      }
    } catch (e) {
      AppLogger.error('❌ Erreur gestion reload: $e');
    }
  }

  /// Inscription utilisateur
  /// Crée un nouveau compte utilisateur
  Future<bool> signup({
    required String nom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authService.signup(
        nom: nom,
        email: email,
        telephone: telephone,
        password: password,
      );

      _currentUser = authResponse.user;
      _authToken = authResponse.token;
      _isLoggedIn = true;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Connexion utilisateur
  /// Authentifie l'utilisateur avec email et mot de passe
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      _authToken = authResponse.token;
      _isLoggedIn = true;

      try {
        final completeUser = await _userService.getUserProfile();
        _currentUser = completeUser;
      } catch (profileError) {
        _currentUser = authResponse.user;
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Demande de réinitialisation de mot de passe
  /// Envoie un email avec un code de réinitialisation
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.forgotPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Déconnexion utilisateur
  /// Nettoie les données locales et notifie le serveur
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
    } catch (e) {
      _setError(ErrorHandler.handleAuthError(e));
    }

    _isLoggedIn = false;
    _currentUser = null;
    _authToken = null;
    _clearError();
    _setLoading(false);
    notifyListeners();
  }

  /// Chargement du profil utilisateur
  /// Récupère les informations complètes de l'utilisateur
  Future<void> loadUserProfile() async {
    if (!_isLoggedIn) return;

    _setLoading(true);
    _clearError();

    try {
      final user = await _userService.getUserProfile();
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
      _setLoading(false);
    }
  }

  /// Mise à jour du profil utilisateur
  /// Met à jour les informations utilisateur
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (!_isLoggedIn) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _userService.updateProfile(updates);
      _currentUser = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Vérification du code OTP
  /// Valide le code reçu par email
  Future<bool> verifyOtp({required String email, required String code}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.verifyOtp(email: email, code: code);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Réinitialisation du mot de passe avec code
  /// Change le mot de passe après vérification du code
  Future<bool> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPasswordWithCode(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Upload d'un document d'identité
  /// Upload un fichier image (recto ou verso) pour l'identité
  Future<bool> uploadIdentityDocument(File imageFile, String type) async {
    _setUploading(true);
    _clearUploadError();

    try {
      if (_authToken == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final imageUrl = await _fileUploadService.uploadIdentityDocument(
        imageFile: imageFile,
        type: type,
        authToken: _authToken!,
      );

      final fieldName = type == 'recto'
          ? 'front_document_path'
          : 'back_document_path';
      final success = await updateProfile({fieldName: imageUrl});

      _setUploading(false);
      return success;
    } catch (e) {
      _setUploadError(ErrorHandler.handleUploadError(e));
      _setUploading(false);
      return false;
    }
  }

  /// Suppression d'un document d'identité
  /// Supprime un document d'identité du profil
  Future<bool> deleteIdentityDocument(String type) async {
    _setLoading(true);
    _clearError();

    try {
      final fieldName = type == 'recto'
          ? 'front_document_path'
          : 'back_document_path';
      final success = await updateProfile({fieldName: null});

      _setLoading(false);
      return success;
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
      _setLoading(false);
      return false;
    }
  }

  /// Vérification de la complétion des documents d'identité
  /// Retourne true si tous les documents sont présents
  bool hasCompleteIdentityDocuments() {
    if (_currentUser == null) return false;
    return _userService.hasCompleteIdentityDocuments(_currentUser!);
  }

  void clearError() {
    _clearError();
  }

  void clearUploadError() {
    _clearUploadError();
  }

  void clearAllErrors() {
    _clearError();
    _clearUploadError();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUploading(bool uploading) {
    _isUploadingDocument = uploading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();

    Future.delayed(const Duration(seconds: 5), () {
      if (_errorMessage == error) {
        _clearError();
      }
    });
  }

  void _setUploadError(String error) {
    _uploadErrorMessage = error;
    notifyListeners();

    Future.delayed(const Duration(seconds: 5), () {
      if (_uploadErrorMessage == error) {
        _clearUploadError();
      }
    });
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearUploadError() {
    _uploadErrorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  /// Vérification des rôles utilisateur
  /// Retourne true si l'utilisateur a le rôle spécifié
  bool hasRole(TypeUtilisateur role) {
    if (_currentUser == null) return false;
    return _userService.hasRole(_currentUser!, role);
  }

  /// Vérification des permissions d'accès
  /// Retourne true si l'utilisateur peut accéder aux rôles spécifiés
  bool canAccess(List<TypeUtilisateur> allowedRoles) {
    if (_currentUser == null) return false;
    return _userService.canAccess(_currentUser!, allowedRoles);
  }

  /// Actualisation des données utilisateur
  /// Recharge les données utilisateur depuis le serveur
  Future<void> refreshUserData() async {
    if (_isLoggedIn) {
      await loadUserProfile();
    }
  }

  /// Vérification de la validité du token
  /// Retourne true si le token est valide
  Future<bool> checkTokenValidity() async {
    if (_authToken == null) return false;
    return await _authService.checkTokenValidity();
  }

  void forceLogout() {
    _isLoggedIn = false;
    _currentUser = null;
    _authToken = null;
    _clearError();
    _clearUploadError();
    notifyListeners();
  }

  /// Mise à jour d'un champ spécifique du profil
  /// Met à jour un seul champ du profil utilisateur
  Future<void> updateUserField(String fieldName, dynamic value) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = await _userService.updateUserField(fieldName, value);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
    }
  }
}
