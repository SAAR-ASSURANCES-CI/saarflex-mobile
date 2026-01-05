import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saarciflex_app/data/repositories/auth_repository.dart';
import 'package:saarciflex_app/data/repositories/profile_repository.dart';
import 'package:saarciflex_app/data/services/file_upload_service.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/core/utils/error_handler.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final FileUploadService _fileUploadService = FileUploadService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _currentUser;
  String? _errorMessage;
  String? _authToken;

  bool _isUploadingDocument = false;
  String? _uploadErrorMessage;
  double _uploadProgress = 0.0;
  int? _avatarTimestamp;

  static bool _hasInitialized = false;
  static const String _initTimestampKey = 'auth_init_timestamp';

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get authToken => _authToken;
  bool get isUploadingDocument => _isUploadingDocument;
  String? get uploadErrorMessage => _uploadErrorMessage;
  double get uploadProgress => _uploadProgress;
  int? get avatarTimestamp => _avatarTimestamp;

  String get userName => _currentUser?.displayName ?? 'Utilisateur';
  String get userEmail => _currentUser?.email ?? '';
  bool get isClient => _currentUser?.isClient ?? true;
  bool get isAgent => _currentUser?.isAgent ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isProfileComplete => _currentUser?.isProfileComplete ?? false;

  Future<void> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final existingTimestamp = prefs.getString(_initTimestampKey);
    final currentTimestamp = DateTime.now().toIso8601String();
    
    // Ne pas forcer la déconnexion en mode debug (hot reload)
    if (_hasInitialized && existingTimestamp != null) {
      if (!kDebugMode) {
        await _forceLogoutForReload();
        return;
      }
      // En mode debug, on continue normalement sans déconnecter
    }
    
    await prefs.setString(_initTimestampKey, currentTimestamp);
    _hasInitialized = true;

    _setLoading(true);
    try {
      final isLoggedIn = await _authRepository.initializeAuth();
      _isLoggedIn = isLoggedIn;

      if (isLoggedIn) {
        await loadUserProfile();
      } else {
        _currentUser = null;
        _authToken = null;
      }
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
      _authToken = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _forceLogoutForReload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_timestamp');
      await prefs.remove(_initTimestampKey);
      
      _hasInitialized = false;
      
      _isLoggedIn = false;
      _currentUser = null;
      _authToken = null;
      _clearError();
      
      notifyListeners();
      
      _authRepository.logout().catchError((e) {
      });
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
      _authToken = null;
      notifyListeners();
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
      final authResponse = await _authRepository.signup(
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

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authRepository.login(
        email: email,
        password: password,
      );

      _authToken = authResponse.token;
      _isLoggedIn = true;

      try {
        final completeUser = await _profileRepository.getUserProfile();
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

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.forgotPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authRepository.logout();
    } catch (e) {
      _setError(ErrorHandler.handleAuthError(e));
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_initTimestampKey);
    } catch (e) {
    }
    
    _hasInitialized = false;

    _isLoggedIn = false;
    _currentUser = null;
    _authToken = null;
    _clearError();
    _setLoading(false);
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    if (!_isLoggedIn) return;

    _setLoading(true);
    _clearError();

    final previousUser = _currentUser;

    try {
      final user = await _profileRepository.getUserProfile();
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      final errorMessage = ErrorHandler.handleProfileError(e);
      
      final isAuthError = errorMessage.toLowerCase().contains('401') ||
          errorMessage.toLowerCase().contains('authentification') ||
          errorMessage.toLowerCase().contains('non authentifié') ||
          errorMessage.toLowerCase().contains('token') ||
          errorMessage.toLowerCase().contains('unauthorized');
      
      if (isAuthError) {
        _isLoggedIn = false;
        _currentUser = null;
        _authToken = null;
      } else {
        _currentUser = previousUser;
      }
      
      _setError(errorMessage);
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (!_isLoggedIn) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _profileRepository.updateProfile(updates);
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

  Future<bool> verifyOtp({required String email, required String code}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.verifyOtp(email: email, code: code);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(ErrorHandler.handleAuthError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.resetPasswordWithCode(
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

  bool hasCompleteIdentityDocuments() {
    if (_currentUser == null) return false;
    return _currentUser!.frontDocumentPath != null &&
        _currentUser!.backDocumentPath != null;
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

  bool hasRole(TypeUtilisateur role) {
    if (_currentUser == null) return false;
    return _currentUser!.typeUtilisateur == role;
  }

  bool canAccess(List<TypeUtilisateur> allowedRoles) {
    if (_currentUser == null) return false;
    return allowedRoles.contains(_currentUser!.typeUtilisateur);
  }

  Future<void> refreshUserData() async {
    if (_isLoggedIn) {
      await loadUserProfile();
    }
  }

  Future<void> ensureUserProfileLoaded() async {
    if (_isLoggedIn && _currentUser == null) {
      await loadUserProfile();
    }
  }

  Future<bool> checkTokenValidity() async {
    if (_authToken == null) return false;
    return await _authRepository.checkTokenValidity();
  }

  void forceLogout() {
    _isLoggedIn = false;
    _currentUser = null;
    _authToken = null;
    _clearError();
    _clearUploadError();
    notifyListeners();
  }

  Future<void> updateUserField(String fieldName, dynamic value) async {
    if (_currentUser == null) return;

    try {
      final updatedUser =
          await _profileRepository.updateProfileField(fieldName, value);
      _currentUser = updatedUser;
      
      // Si c'est l'avatar qui est mis à jour, générer un nouveau timestamp
      if (fieldName == 'avatar_path') {
        _avatarTimestamp = DateTime.now().millisecondsSinceEpoch;
      }
      
      notifyListeners();
    } catch (e) {
      _setError(ErrorHandler.handleProfileError(e));
    }
  }
}
