import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/core/utils/storage_helper.dart';

class ProfileService {

  Future<User> getUserProfile() async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ProfileException('Authentification requise');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileBasePath}');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        return user;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de la récupération du profil';
        throw ProfileException(errorMessage);
      }
    } catch (e) {
      throw ProfileException(_getUserFriendlyError(e));
    }
  }

  Future<User> updateProfileField(String field, dynamic value) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ProfileException('Authentification requise');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileBasePath}');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final payload = {field: value};

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        return user;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de la mise à jour';
        throw ProfileException(errorMessage);
      }
    } catch (e) {
      throw ProfileException(_getUserFriendlyError(e));
    }
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ProfileException('Authentification requise');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileBasePath}');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        return user;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de la mise à jour du profil';
        throw ProfileException(errorMessage);
      }
    } catch (e) {
      throw ProfileException(_getUserFriendlyError(e));
    }
  }

  Map<String, String> validateProfileData(Map<String, dynamic> data) {
    final errors = <String, String>{};

    if (data.containsKey('nom')) {
      final nom = data['nom']?.toString().trim();
      if (nom == null || nom.isEmpty) {
        errors['nom'] = 'Le nom est obligatoire';
      } else if (nom.length < 2) {
        errors['nom'] = 'Le nom doit contenir au moins 2 caractères';
      }
    }

    if (data.containsKey('email')) {
      final email = data['email']?.toString().trim();
      if (email == null || email.isEmpty) {
        errors['email'] = 'L\'email est obligatoire';
      } else if (!_isValidEmail(email)) {
        errors['email'] = 'Format d\'email invalide';
      }
    }

    if (data.containsKey('telephone')) {
      final telephone = data['telephone']?.toString().trim();
      if (telephone != null &&
          telephone.isNotEmpty &&
          !_isValidPhone(telephone)) {
        errors['telephone'] = 'Format de téléphone invalide';
      }
    }

    if (data.containsKey('date_naissance')) {
      final birthDate = data['date_naissance'];
      if (birthDate != null) {
        if (birthDate is String) {
          try {
            final date = DateTime.parse(birthDate);
            if (date.isAfter(DateTime.now())) {
              errors['date_naissance'] =
                  'La date de naissance ne peut pas être dans le futur';
            }
          } catch (e) {
            errors['date_naissance'] = 'Format de date invalide';
          }
        }
      }
    }

    return errors;
  }

  bool isProfileComplete(User user) {
    final requiredFields = [
      user.nom,
      user.email,
      user.telephone,
      user.birthDate,
      user.gender,
      user.nationality,
      user.address,
    ];

    return requiredFields.every(
      (field) => field != null && field.toString().trim().isNotEmpty,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 8 && cleanPhone.length <= 15;
  }

  String _getUserFriendlyError(dynamic error) {
    if (error is SocketException) {
      return 'Problème de connexion internet';
    } else if (error is FormatException) {
      return 'Erreur de format des données';
    } else if (error is HttpException) {
      return 'Erreur de communication avec le serveur';
    } else if (error is String) {
      if (error.contains('400')) return 'Données invalides';
      if (error.contains('401')) return 'Authentification requise';
      if (error.contains('404')) return 'Profil non trouvé';
      if (error.contains('500')) return 'Erreur interne du serveur';
      return 'Une erreur est survenue';
    }
    return 'Une erreur inattendue est survenue';
  }
}

class ProfileException implements Exception {
  final String message;

  ProfileException(this.message);

  @override
  String toString() => message;
}
