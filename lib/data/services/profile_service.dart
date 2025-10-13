import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/data/models/user_model.dart';
import 'package:saarflex_app/core/utils/api_config.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';
import 'package:saarflex_app/core/utils/logger.dart';

/// Service de gestion du profil utilisateur
/// Responsabilité : Logique métier pure pour la gestion du profil
class ProfileService {
  static const String _basePath = '/profile';

  /// Récupération du profil utilisateur
  /// Logique métier : Récupère les données du profil depuis l'API
  Future<User> getUserProfile() async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ProfileException('Authentification requise');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      AppLogger.info('📋 Récupération du profil utilisateur');

      final response = await http.get(url, headers: headers);

      AppLogger.api('API Profil - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);

        AppLogger.info('✅ Profil récupéré avec succès');
        return user;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de la récupération du profil';
        throw ProfileException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Erreur récupération profil: $e');
      throw ProfileException(_getUserFriendlyError(e));
    }
  }

  /// Mise à jour d'un champ spécifique du profil
  /// Logique métier : Met à jour un champ du profil via l'API
  Future<User> updateProfileField(String field, dynamic value) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ProfileException('Authentification requise');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final payload = {field: value};

      AppLogger.info('📝 Mise à jour du champ: $field');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      AppLogger.api('API Mise à jour - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);

        AppLogger.info('✅ Champ $field mis à jour avec succès');
        return user;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de la mise à jour';
        throw ProfileException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Erreur mise à jour profil: $e');
      throw ProfileException(_getUserFriendlyError(e));
    }
  }

  /// Mise à jour complète du profil
  /// Logique métier : Met à jour plusieurs champs du profil en une fois
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ProfileException('Authentification requise');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      AppLogger.info('📝 Mise à jour complète du profil');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(profileData),
      );

      AppLogger.api(
        'API Mise à jour complète - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);

        AppLogger.info('✅ Profil mis à jour avec succès');
        return user;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de la mise à jour du profil';
        throw ProfileException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Erreur mise à jour profil: $e');
      throw ProfileException(_getUserFriendlyError(e));
    }
  }

  /// Validation des données du profil
  /// Logique métier : Valide les données selon les règles métier
  Map<String, String> validateProfileData(Map<String, dynamic> data) {
    final errors = <String, String>{};

    // Validation du nom
    if (data.containsKey('nom')) {
      final nom = data['nom']?.toString().trim();
      if (nom == null || nom.isEmpty) {
        errors['nom'] = 'Le nom est obligatoire';
      } else if (nom.length < 2) {
        errors['nom'] = 'Le nom doit contenir au moins 2 caractères';
      }
    }

    // Validation de l'email
    if (data.containsKey('email')) {
      final email = data['email']?.toString().trim();
      if (email == null || email.isEmpty) {
        errors['email'] = 'L\'email est obligatoire';
      } else if (!_isValidEmail(email)) {
        errors['email'] = 'Format d\'email invalide';
      }
    }

    // Validation du téléphone
    if (data.containsKey('telephone')) {
      final telephone = data['telephone']?.toString().trim();
      if (telephone != null &&
          telephone.isNotEmpty &&
          !_isValidPhone(telephone)) {
        errors['telephone'] = 'Format de téléphone invalide';
      }
    }

    // Validation de la date de naissance
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

  /// Vérification de la complétude du profil
  /// Logique métier : Vérifie si le profil est complet selon les règles métier
  bool isProfileComplete(User user) {
    // Champs obligatoires pour un profil complet
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

  /// Validation de l'email
  /// Logique métier : Valide le format de l'email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validation du téléphone
  /// Logique métier : Valide le format du téléphone
  bool _isValidPhone(String phone) {
    // Supprimer tous les espaces et caractères spéciaux
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Vérifier que c'est un numéro de téléphone valide (8-15 chiffres)
    return cleanPhone.length >= 8 && cleanPhone.length <= 15;
  }

  /// Gestion des erreurs utilisateur
  /// Logique métier : Convertit les erreurs techniques en messages utilisateur
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

/// Exception spécialisée pour les erreurs de profil
class ProfileException implements Exception {
  final String message;

  ProfileException(this.message);

  @override
  String toString() => message;
}
