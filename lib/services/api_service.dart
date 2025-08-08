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
    switch (response.statusCode) {
      case 400:
        throw ApiException('Données invalides', response.statusCode);
      case 401:
        throw ApiException('Non autorisé - Veuillez vous reconnecter', response.statusCode);
      case 403:
        throw ApiException('Accès interdit', response.statusCode);
      case 404:
        throw ApiException('Ressource non trouvée', response.statusCode);
      case 422:
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Erreur de validation';
        throw ApiException(message, response.statusCode);
      case 500:
        throw ApiException('Erreur serveur - Veuillez réessayer', response.statusCode);
      default:
        throw ApiException('Erreur réseau (${response.statusCode})', response.statusCode);
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _defaultHeaders,
        body: json.encode({
          'email': email,
          'mot_de_passe': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final user = User.fromJson(data['user']);

        await _saveToken(token);

        return AuthResponse(user: user, token: token);
      } else {
        _handleHttpError(response);
        throw ApiException('Erreur de connexion', response.statusCode);
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
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
        Uri.parse('$baseUrl/auth/register'),
        headers: _defaultHeaders,
        body: json.encode({
          'nom': nom,
          'email': email,
          'téléphone': telephone,
          'mot_de_passe': password,
          'type_utilisateur': 'client',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['token'];
        final user = User.fromJson(data['user']);

        await _saveToken(token);
        return AuthResponse(user: user, token: token);
      } else {
        _handleHttpError(response);
        throw ApiException('Erreur lors de l\'inscription', response.statusCode);
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur d\'inscription: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _authHeaders,
      );
    } finally {
      await _clearToken();
    }
  }

  Future<User> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        _handleHttpError(response);
        throw ApiException('Erreur lors du chargement du profil', response.statusCode);
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
      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: await _authHeaders,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        _handleHttpError(response);
        throw ApiException('Erreur lors de la mise à jour', response.statusCode);
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de mise à jour: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: _defaultHeaders,
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200) {
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