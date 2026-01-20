import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static String get baseUrl => ApiConstants.baseUrl;

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    return {
      ..._defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_timestamp', DateTime.now().toIso8601String());
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_timestamp');
  }

  void _handleHttpError(http.Response response) {
    final responseBody = response.body;
    String userMessage;

    try {
      final errorData = json.decode(responseBody);
      final apiMessage = errorData['message'];
      userMessage = _getErrorMessageForStatusCode(
        response.statusCode,
        apiMessage,
      );
    } catch (e) {
      userMessage = _getDefaultErrorMessage(response.statusCode);
    }

    throw ApiException(userMessage, response.statusCode);
  }

  String _getErrorMessageForStatusCode(int statusCode, dynamic apiMessage) {
    switch (statusCode) {
      case 400:
        return _formatValidationError(apiMessage, 'Données invalides');
      case 401:
        return 'Email ou mot de passe incorrect';
      case 403:
        return 'Accès interdit';
      case 404:
        return 'Service non disponible';
      case 409:
        return 'Un compte avec cet email existe déjà';
      case 422:
        return _formatValidationError(apiMessage, 'Erreur de validation');
      case 429:
        return 'Trop de tentatives. Veuillez patienter quelques minutes';
      case 500:
        return 'Erreur serveur. Veuillez réessayer plus tard';
      case 503:
        return 'Service temporairement indisponible';
      default:
        return 'Une erreur est survenue. Veuillez réessayer';
    }
  }

  String _formatValidationError(dynamic apiMessage, String defaultMessage) {
    if (apiMessage is List) {
      return apiMessage.join('\n');
    } else {
      return apiMessage ?? defaultMessage;
    }
  }

  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Données invalides';
      case 401:
        return 'Email ou mot de passe incorrect';
      case 403:
        return 'Accès interdit';
      case 404:
        return 'Service non disponible';
      case 409:
        return 'Un compte avec cet email existe déjà';
      case 422:
        return 'Erreur de validation';
      case 429:
        return 'Trop de tentatives. Veuillez patienter';
      case 500:
        return 'Erreur serveur. Veuillez réessayer plus tard';
      case 503:
        return 'Service temporairement indisponible';
      default:
        return 'Une erreur est survenue. Veuillez réessayer';
    }
  }

  DateTime? _parseDate(dynamic dateValue, String fieldName) {
    if (dateValue == null) {
      return null;
    }

    try {
      String dateStr = dateValue.toString();

      if (dateStr.contains('-') && dateStr.length == 10) {
        List<String> parts = dateStr.split('-');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);

          DateTime parsedDate = DateTime(year, month, day);
          return parsedDate;
        }
      }

      if (dateStr.contains('/') && dateStr.length == 10) {
        List<String> parts = dateStr.split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);

          DateTime parsedDate = DateTime(year, month, day);
          return parsedDate;
        }
      }

      final parsedDate = DateTime.parse(dateStr);
      return parsedDate;
    } catch (e) {
      try {
        String dateStr = dateValue.toString();
        if (dateStr.contains('-')) {
          final DateFormat formatter = DateFormat('dd-MM-yyyy');
          DateTime parsedDate = formatter.parse(dateStr);
          return parsedDate;
        } else if (dateStr.contains('/')) {
          final DateFormat formatter = DateFormat('dd/MM/yyyy');
          DateTime parsedDate = formatter.parse(dateStr);
          return parsedDate;
        }
      } catch (e2) {
        return null;
      }

      return null;
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = '$baseUrl${ApiConstants.login}';
      final body = {'email': email, 'mot_de_passe': password};

      final response = await http.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: json.encode(body),
      ).timeout(
        ApiConstants.connectTimeout,
        onTimeout: () {
          throw ApiException('Délai d\'attente dépassé', 408);
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        final token = data['token'];

        final user = User(
          id: data['id'],
          nom: data['nom'],
          email: data['email'],
          telephone: data['telephone'],
          typeUtilisateur: TypeUtilisateur.values.firstWhere(
            (e) => e.toString().split('.').last == data['type_utilisateur'],
            orElse: () => TypeUtilisateur.client,
          ),
          statut: data['statut'] ?? true,
          dateCreation: data['date_creation'] != null
              ? DateTime.parse(data['date_creation'])
              : null,
          derniereConnexion: null,
          updatedAt: null,
        );

        await _saveToken(token);
        return AuthResponse(user: user, token: token);
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage =
            responseBody['message']?.toString().toLowerCase() ?? '';

        if (response.statusCode == 401) {
          if (errorMessage.contains('email') ||
              errorMessage.contains('utilisateur')) {
            throw ApiException(
              'Aucun compte associé à cet email',
              response.statusCode,
            );
          } else if (errorMessage.contains('mot de passe') ||
              errorMessage.contains('password')) {
            throw ApiException('Mot de passe incorrect', response.statusCode);
          }
        }

        _handleHttpError(response);
        throw ApiException('Erreur de connexion', response.statusCode);
      }
    } on SocketException catch (e) {
      throw ApiException('Pas de connexion internet: ${e.message}');
    } on FormatException catch (e) {
      throw ApiException('Erreur de format de réponse: ${e.message}');
    } on TimeoutException {
      throw ApiException('Délai d\'attente dépassé', 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: ${e.toString()}');
    }
  }

  Future<AuthResponse> signup({
    required String nom,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.register}'),
        headers: _defaultHeaders,
        body: json.encode({
          'nom': nom,
          'email': email,
          'mot_de_passe': password,
          'type_utilisateur': 'client',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];

        if (data['token'] == null) {
          throw ApiException('Token manquant dans la réponse');
        }

        final token = data['token'];

        final user = User(
          id: data['id'],
          nom: data['nom'],
          email: data['email'],
          telephone: data['telephone'],
          typeUtilisateur: TypeUtilisateur.values.firstWhere(
            (e) => e.toString().split('.').last == data['type_utilisateur'],
            orElse: () => TypeUtilisateur.client,
          ),
          statut: data['statut'] ?? true,
          dateCreation: data['date_creation'] != null
              ? DateTime.parse(data['date_creation'])
              : null,
          derniereConnexion: null,
          updatedAt: null,
        );

        await _saveToken(token);
        return AuthResponse(user: user, token: token);
      } else {
        _handleHttpError(response);
        throw ApiException(
          'Erreur lors de l\'inscription',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } on FormatException {
      throw ApiException('Erreur de format de réponse');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur d\'inscription: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl${ApiConstants.logout}'),
        headers: await _authHeaders,
      );
    } finally {
      await _clearToken();
    }
  }

  Future<User> getUserProfile() async {
    try {
      final url = '$baseUrl${ApiConstants.updateProfile}';

      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        final avatarUrlRaw = data['avatar_url'] ?? data['avatar_path'];
        String? avatarUrl;
        if (avatarUrlRaw != null && avatarUrlRaw.toString().contains('localhost')) {
          try {
            final uri = Uri.parse(avatarUrlRaw.toString());
            final path = uri.path;
            final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
            avatarUrl = normalizedPath;
          } catch (e) {
            avatarUrl = data['avatar_path'];
          }
        } else {
          avatarUrl = avatarUrlRaw;
        }
        return User(
          id: data['id'],
          nom: data['nom'],
          email: data['email'],
          telephone: data['telephone'],
          avatarUrl: avatarUrl,
          typeUtilisateur: TypeUtilisateur.values.firstWhere(
            (e) => e.toString().split('.').last == data['type_utilisateur'],
            orElse: () => TypeUtilisateur.client,
          ),
          statut: data['statut'] ?? true,
          dateCreation: data['date_creation'] != null
              ? DateTime.parse(data['date_creation'])
              : null,
          derniereConnexion: data['dernière_connexion'] != null
              ? DateTime.parse(data['dernière_connexion'])
              : null,
          updatedAt: data['date_modification'] != null
              ? DateTime.parse(data['date_modification'])
              : null,
          birthPlace: data['lieu_naissance'],
          gender: data['sexe'],
          nationality: data['nationalite'],
          profession: data['profession'],
          address: data['adresse'],
          identityNumber: data['numero_piece_identite'],
          identityType: data['type_piece_identite'],
          isProfileComplete: _checkIfProfilComplete(data),
          birthDate: _parseDate(data['date_naissance'], 'date_naissance'),
          identityExpirationDate: _parseDate(
            data['date_expiration_piece_identite'],
            'date_expiration_piece_identite',
          ),
          frontDocumentPath: data['front_document_path'],
          backDocumentPath: data['back_document_path'],
        );
      } else {
        _handleHttpError(response);
        throw ApiException(
          'Erreur lors du chargement du profil',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de chargement: ${e.toString()}');
    }
  }

  Future<User> updateProfile(Map<String, dynamic> userData) async {
    try {
      final url = '$baseUrl${ApiConstants.updateProfile}';

      final response = await http.patch(
        Uri.parse(url),
        headers: await _authHeaders,
        body: json.encode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
       final avatarUrlRaw = data['avatar_url'] ?? data['avatar_path'];
        String? avatarUrl;
        if (avatarUrlRaw != null && avatarUrlRaw.toString().contains('localhost')) {
          try {
            final uri = Uri.parse(avatarUrlRaw.toString());
            final path = uri.path;
            final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
            avatarUrl = normalizedPath; 
          } catch (e) {
            avatarUrl = data['avatar_path'];
          }
        } else {
          avatarUrl = avatarUrlRaw;
        }

        return User(
          id: data['id'],
          nom: data['nom'],
          email: data['email'],
          telephone: data['telephone'],
          avatarUrl: avatarUrl,
          typeUtilisateur: TypeUtilisateur.values.firstWhere(
            (e) => e.toString().split('.').last == data['type_utilisateur'],
            orElse: () => TypeUtilisateur.client,
          ),
          statut: data['statut'] ?? true,
          dateCreation: data['date_creation'] != null
              ? DateTime.parse(data['date_creation'])
              : null,
          derniereConnexion: null,
          updatedAt: data['date_modification'] != null
              ? DateTime.parse(data['date_modification'])
              : null,
          birthPlace: data['lieu_naissance'],
          gender: data['sexe'],
          nationality: data['nationalite'],
          profession: data['profession'],
          address: data['adresse'],
          identityNumber: data['numero_piece_identite'],
          identityType: data['type_piece_identite'],
          isProfileComplete: _checkIfProfilComplete(data),
          birthDate: _parseDate(data['date_naissance'], 'date_naissance'),
          identityExpirationDate: _parseDate(
            data['date_expiration_piece_identite'],
            'date_expiration_piece_identite',
          ),
          frontDocumentPath: data['front_document_path'],
          backDocumentPath: data['back_document_path'],
        );
      } else {
        _handleHttpError(response);
        throw ApiException(
          'Erreur lors de la mise à jour',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de mise à jour: ${e.toString()}');
    }
  }

  bool _checkIfProfilComplete(Map<String, dynamic> data) {
    List<String> champsRequis = [
      'lieu_naissance',
      'sexe',
      'nationalite',
      'profession',
      'adresse',
      'numero_piece_identite',
      'type_piece_identite',
      'date_naissance',
      'date_expiration_piece_identite',
      'front_document_path',
      'back_document_path',
    ];

    for (String champ in champsRequis) {
      if (data[champ] == null ||
          (data[champ] is String && (data[champ] as String).trim().isEmpty)) {
        return false;
      }
    }

    return true;
  }

  Future<bool> checkProfileStatus() async {
    try {
      User user = await getUserProfile();
      return user.isProfileComplete ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final url = '$baseUrl/users/forgot-password';
      final body = {'email': email};

      final response = await http.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: json.encode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _handleHttpError(response);
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de l\'envoi: ${e.toString()}');
    }
  }

  Future<void> verifyOtp({required String email, required String code}) async {
    try {
      final url = '$baseUrl/users/verify-otp';
      final body = {'email': email, 'code': code};

      final response = await http.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: json.encode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _handleHttpError(response);
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de vérification: ${e.toString()}');
    }
  }

  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final url = '$baseUrl/users/reset-password';
      final body = {
        'email': email,
        'code': code,
        'nouveau_mot_de_passe': newPassword,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: json.encode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _handleHttpError(response);
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de réinitialisation: ${e.toString()}');
    }
  }

  Future<Map<String, String>> uploadAssureImages({
    required String devisId,
    required String rectoPath,
    required String versoPath,
  }) async {
    try {
      final url = '$baseUrl${ApiConstants.uploadAssureImages}/$devisId/upload/assure-images';
      final token = await _getToken();

      if (token == null) {
        throw ApiException('Token d\'authentification manquant');
      }

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final rectoFile = File(rectoPath);
      final versoFile = File(versoPath);

      if (!await rectoFile.exists()) {
        throw ApiException('Fichier recto introuvable');
      }
      if (!await versoFile.exists()) {
        throw ApiException('Fichier verso introuvable');
      }

      final rectoMultipartFile = await http.MultipartFile.fromPath(
        'files',
        rectoPath,
        filename: 'recto.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(rectoMultipartFile);

      final versoMultipartFile = await http.MultipartFile.fromPath(
        'files',
        versoPath,
        filename: 'verso.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(versoMultipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final rectoPath = responseData['recto_path'];
        final versoPath = responseData['verso_path'];

        if (rectoPath == null || versoPath == null) {
          throw ApiException('Chemins des images manquants dans la réponse');
        }

        return {'recto_path': rectoPath, 'verso_path': versoPath};
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Erreur lors de l\'upload';
        throw ApiException('$errorMessage (${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur d\'upload: ${e.toString()}');
    }
  }

  Future<Map<String, String>> uploadBothImages({
    required String rectoPath,
    required String versoPath,
  }) async {
    try {
      final url = '$baseUrl${ApiConstants.uploadImages}';
      final token = await _getToken();

      if (token == null) {
        throw ApiException('Token d\'authentification manquant');
      }

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final rectoFile = File(rectoPath);
      final versoFile = File(versoPath);

      if (!await rectoFile.exists()) {
        throw ApiException('Fichier recto introuvable');
      }
      if (!await versoFile.exists()) {
        throw ApiException('Fichier verso introuvable');
      }

      final rectoMultipartFile = await http.MultipartFile.fromPath(
        'files',
        rectoPath,
        filename: 'recto.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(rectoMultipartFile);

      final versoMultipartFile = await http.MultipartFile.fromPath(
        'files',
        versoPath,
        filename: 'verso.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(versoMultipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final rectoPath = responseData['recto_path'];
        final versoPath = responseData['verso_path'];

        if (rectoPath == null || versoPath == null) {
          throw ApiException('Chemins des images manquants dans la réponse');
        }

        return {'recto_path': rectoPath, 'verso_path': versoPath};
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Erreur lors de l\'upload';
        throw ApiException('$errorMessage (${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur d\'upload: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await _getToken();
      if (token == null) return false;
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.updateProfile}'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        await _clearToken();
        return false;
      } else {
        return true;
      }
    } catch (e) {
      final token = await _getToken();
      return token != null;
    }
  }

  Future<bool> isLoggedInWithTimeout({
    Duration timeout = const Duration(hours: 24),
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString('auth_timestamp');
      if (timestampStr == null) return false;

      final loginTime = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final sessionAge = now.difference(loginTime);

      if (sessionAge > timeout) {
        await _clearToken();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    return '$baseUrl/$imagePath';
  }
}

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
