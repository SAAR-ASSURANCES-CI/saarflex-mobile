import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:saarflex_app/data/services/api_service.dart';
import 'package:saarflex_app/data/models/user_model.dart';
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/logger.dart';

class AuthViewModel extends ChangeNotifier {
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
      _validateAuthToken();
      final request = await _createUploadRequest(imageFile, type);
      final response = await _sendUploadRequest(request);
      final imageUrl = await _extractImageUrl(response);
      final success = await _updateProfileWithImageUrl(imageUrl, type);

      _setUploading(false);
      return success;
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

  void _validateAuthToken() {
    if (_authToken == null) {
      throw Exception('Utilisateur non authentifié');
    }
  }

  Future<http.MultipartRequest> _createUploadRequest(
    File imageFile,
    String type,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadDocument}'),
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

    return request;
  }

  Future<http.StreamedResponse> _sendUploadRequest(
    http.MultipartRequest request,
  ) async {
    return await request.send();
  }

  Future<String> _extractImageUrl(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(responseBody);
      final imageUrl = responseData['data']?['url'] ?? responseData['url'];

      if (imageUrl == null) {
        throw Exception('URL de l\'image non reçue du serveur');
      }

      return imageUrl;
    } else {
      AppLogger.error(
        'Erreur upload document: ${response.statusCode} - $responseBody',
      );
      final errorData = json.decode(responseBody);
      final errorMessage = errorData['message'] ?? 'Erreur lors de l\'upload';
      throw Exception('$errorMessage (${response.statusCode})');
    }
  }

  Future<bool> _updateProfileWithImageUrl(String imageUrl, String type) async {
    final fieldName = type == 'recto'
        ? 'front_document_path'
        : 'back_document_path';
    return await updateProfile({fieldName: imageUrl});
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
      _setError('Erreur lors de la suppression du document');
      _setLoading(false);
      return false;
    }
  }

  bool hasCompleteIdentityDocuments() {
    return _currentUser?.frontDocumentPath != null &&
        _currentUser?.frontDocumentPath!.isNotEmpty == true &&
        _currentUser?.backDocumentPath != null &&
        _currentUser?.backDocumentPath!.isNotEmpty == true;
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

  void updateUserField(String fieldName, dynamic value) {
    if (_currentUser == null) return;

    // Créer une nouvelle instance de User avec le champ mis à jour
    final updatedUser = User(
      id: _currentUser!.id,
      nom: fieldName == 'nom' ? value : _currentUser!.nom,
      email: fieldName == 'email' ? value : _currentUser!.email,
      telephone: fieldName == 'telephone' ? value : _currentUser!.telephone,
      typeUtilisateur: _currentUser!.typeUtilisateur,
      statut: _currentUser!.statut,
      dateCreation: _currentUser!.dateCreation,
      updatedAt: _currentUser!.updatedAt,
      birthPlace: fieldName == 'lieu_naissance'
          ? value
          : _currentUser!.birthPlace,
      gender: fieldName == 'sexe' ? value : _currentUser!.gender,
      nationality: fieldName == 'nationalite'
          ? value
          : _currentUser!.nationality,
      profession: fieldName == 'profession' ? value : _currentUser!.profession,
      address: fieldName == 'adresse' ? value : _currentUser!.address,
      birthDate: fieldName == 'date_naissance'
          ? value
          : _currentUser!.birthDate,
      identityNumber: fieldName == 'numero_piece_identite'
          ? value
          : _currentUser!.identityNumber,
      identityType: fieldName == 'type_piece_identite'
          ? value
          : _currentUser!.identityType,
      identityExpirationDate: fieldName == 'date_expiration_piece_identite'
          ? value
          : _currentUser!.identityExpirationDate,
      frontDocumentPath: fieldName == 'frontDocumentPath'
          ? value
          : _currentUser!.frontDocumentPath,
      backDocumentPath: fieldName == 'backDocumentPath'
          ? value
          : _currentUser!.backDocumentPath,
    );

    _currentUser = updatedUser;

    // Vérifier et mettre à jour le statut du profil
    _updateProfileCompletionStatus();

    notifyListeners();
  }

  void _updateProfileCompletionStatus() {
    if (_currentUser == null) return;

    // Vérifier si le profil est maintenant complet
    final isComplete = _currentUser!.isProfileCompleteValue;

    // Si le profil est complet mais que le statut n'est pas à jour, le mettre à jour
    if (isComplete && _currentUser!.isProfileComplete != true) {
      _currentUser = _currentUser!.copyWith(isProfileComplete: true);
    }
  }
}
