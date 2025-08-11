import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/api_constants.dart';

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
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  void _handleHttpError(http.Response response) {
    final responseBody = response.body;
    String userMessage;

    try {
      final errorData = json.decode(responseBody);
      final apiMessage = errorData['message'];

      switch (response.statusCode) {
        case 400:
          if (apiMessage is List) {
            userMessage = apiMessage.join('\n');
          } else {
            userMessage = apiMessage ?? 'Données invalides';
          }
          break;
        case 401:
          userMessage = 'Email ou mot de passe incorrect';
          break;
        case 403:
          userMessage = 'Accès interdit';
          break;
        case 404:
          userMessage = 'Service non disponible';
          break;
        case 409:
          userMessage = 'Un compte avec cet email existe déjà';
          break;
        case 422:
          if (apiMessage is List) {
            userMessage = apiMessage.join('\n');
          } else {
            userMessage = apiMessage ?? 'Erreur de validation';
          }
          break;
        case 429:
          userMessage =
              'Trop de tentatives. Veuillez patienter quelques minutes';
          break;
        case 500:
          userMessage = 'Erreur serveur. Veuillez réessayer plus tard';
          break;
        case 503:
          userMessage = 'Service temporairement indisponible';
          break;
        default:
          userMessage = 'Une erreur est survenue. Veuillez réessayer';
      }
    } catch (e) {
      userMessage = _getDefaultErrorMessage(response.statusCode);
    }

    throw ApiException(userMessage, response.statusCode);
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

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/users/login';
      final body = {'email': email, 'mot_de_passe': password};

      final response = await http.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: json.encode(body),
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
        _handleHttpError(response);
        throw ApiException('Erreur de connexion', response.statusCode);
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } on FormatException {
      throw ApiException('Erreur de format de réponse');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion: ${e.toString()}');
    }
  }

  Future<AuthResponse> signup({
    required String nom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: _defaultHeaders,
        body: json.encode({
          'nom': nom,
          'email': email,
          'telephone': telephone,
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
        Uri.parse('$baseUrl/users/logout'),
        headers: await _authHeaders,
      );
    } finally {
      await _clearToken();
    }
  }

  Future<User> getUserProfile() async {
    try {
      final url = '$baseUrl/users/me';

      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        bool profilAJour = _checkIfProfilComplete(data);

        return User(
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
          derniereConnexion: data['dernière_connexion'] != null
              ? DateTime.parse(data['dernière_connexion'])
              : null,
          updatedAt: data['date_modification'] != null
              ? DateTime.parse(data['date_modification'])
              : null,
          lieuNaissance: profilAJour ? data['lieu_naissance'] : null,
          sexe: profilAJour ? data['sexe'] : null,
          nationalite: profilAJour ? data['nationalite'] : null,
          profession: profilAJour ? data['profession'] : null,
          adresse: profilAJour ? data['adresse'] : null,
          numeroPieceIdentite: profilAJour
              ? data['numero_piece_identite']
              : null,
          typePieceIdentite: profilAJour ? data['type_piece_identite'] : null,
          profilComplet: profilAJour,
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

  bool _checkIfProfilComplete(Map<String, dynamic> data) {
    List<String> champsRequis = [
      'lieu_naissance',
      'sexe',
      'nationalite',
      'profession',
      'adresse',
      'numero_piece_identite',
      'type_piece_identite',
    ];

    for (String champ in champsRequis) {
      if (data[champ] == null ||
          (data[champ] is String && (data[champ] as String).trim().isEmpty)) {
        return false;
      }
    }

    return true;
  }

  Future<User> updateProfile(Map<String, dynamic> userData) async {
    try {
      final url = '$baseUrl/users/me';

      final response = await http.patch(
        Uri.parse(url),
        headers: await _authHeaders,
        body: json.encode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        bool profilAJour = _checkIfProfilComplete(data);

        return User(
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
          updatedAt: data['date_modification'] != null
              ? DateTime.parse(data['date_modification'])
              : null,
          lieuNaissance: data['lieu_naissance'],
          sexe: data['sexe'],
          nationalite: data['nationalite'],
          profession: data['profession'],
          adresse: data['adresse'],
          numeroPieceIdentite: data['numero_piece_identite'],
          typePieceIdentite: data['type_piece_identite'],
          profilComplet: profilAJour,
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

  Future<bool> checkProfileStatus() async {
    try {
      User user = await getUserProfile();
      return user.profilComplet ?? false;
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

  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
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
