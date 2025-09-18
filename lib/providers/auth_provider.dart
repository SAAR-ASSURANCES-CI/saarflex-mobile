import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

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

  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      if (isLoggedIn) {
        await loadUserProfile();
      }
    } catch (e) {
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
      notifyListeners();
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

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _apiService.login(
        email: email,
        password: password,
      );

      _authToken = authResponse.token;
      _isLoggedIn = true;

      try {
        final completeUser = await _apiService.getUserProfile();
        _currentUser = completeUser;
      } catch (profileError) {
        _currentUser = authResponse.user;
      }

      _setLoading(false);
      notifyListeners();
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

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.forgotPassword(email);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Erreur lors de l\'envoi');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _apiService.logout();
    } catch (e) {
      _setError('Erreur lors de la déconnexion');
    }

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

    try {
      final user = await _apiService.getUserProfile();
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
    } on ApiException catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    } catch (e) {
      _setError('Erreur de chargement du profil');
      _setLoading(false);
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
      notifyListeners();
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

  Future<bool> verifyOtp({required String email, required String code}) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.verifyOtp(email: email, code: code);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Code invalide');
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
      await _apiService.resetPasswordWithCode(
        email: email,
        code: code,
        newPassword: newPassword,
      );
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

  Future<bool> uploadIdentityDocument(File imageFile, String type) async {
    _setUploading(true);
    _clearUploadError();

    try {
      if (_authToken == null) {
        throw Exception('Utilisateur non authentifié');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/users/upload-piece-identite'),
      );

      request.headers['Authorization'] = 'Bearer $_authToken';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: path.basename(imageFile.path),
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      request.fields['type'] = type;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(responseBody);
        final imageUrl = responseData['data']?['url'] ?? responseData['url'];

        if (imageUrl == null) {
          throw Exception('URL de l\'image non reçue du serveur');
        }

        final fieldName = type == 'recto'
            ? 'chemin_recto_piece'
            : 'chemin_verso_piece';
        final success = await updateProfile({fieldName: imageUrl});

        _setUploading(false);
        return success;
      } else {
        AppLogger.error(
          'Erreur upload document: ${response.statusCode} - $responseBody',
        );
        final errorData = json.decode(responseBody);
        final errorMessage = errorData['message'] ?? 'Erreur lors de l\'upload';
        throw Exception('$errorMessage (${response.statusCode})');
      }
    } on ApiException catch (e) {
      _setUploadError(_getErrorMessage(e));
      _setUploading(false);
      return false;
    } catch (e) {
      _setUploadError('Erreur lors de l\'upload du document: ${e.toString()}');
      _setUploading(false);
      return false;
    }
  }

  Future<bool> deleteIdentityDocument(String type) async {
    _setLoading(true);
    _clearError();

    try {
      final fieldName = type == 'recto'
          ? 'chemin_recto_piece'
          : 'chemin_verso_piece';
      final success = await updateProfile({fieldName: null});

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Erreur lors de la suppression du document');
      _setLoading(false);
      return false;
    }
  }

  bool hasCompleteIdentityDocuments() {
    return _currentUser?.cheminRectoPiece != null &&
        _currentUser?.cheminRectoPiece!.isNotEmpty == true &&
        _currentUser?.cheminVersoPiece != null &&
        _currentUser?.cheminVersoPiece!.isNotEmpty == true;
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

  String _getErrorMessage(ApiException e) {
    return e.message;
  }

  bool hasRole(TypeUtilisateur role) {
    return _currentUser?.typeUtilisateur == role;
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

  Future<bool> checkTokenValidity() async {
    if (_authToken == null) return false;

    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  void forceLogout() {
    _isLoggedIn = false;
    _currentUser = null;
    _authToken = null;
    _clearError();
    _clearUploadError();
    notifyListeners();
  }
}
