import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saarflex_app/data/services/api_service.dart';
import 'package:saarflex_app/core/utils/logger.dart';

/// Gestionnaire d'erreurs centralisé
/// Responsabilité : Gestion uniforme des erreurs dans l'application
class ErrorHandler {
  /// Traitement des erreurs d'authentification
  /// Convertit les erreurs techniques en messages utilisateur
  static String handleAuthError(dynamic error) {
    try {
      if (error is ApiException) {
        return _getAuthErrorMessage(error);
      } else if (error is SocketException) {
        return 'Problème de connexion internet. Vérifiez votre réseau.';
      } else if (error is FormatException) {
        return 'Erreur de format des données. Veuillez réessayer.';
      } else if (error is HttpException) {
        return 'Erreur de communication avec le serveur.';
      } else {
        return 'Une erreur inattendue est survenue.';
      }
    } catch (e) {
      AppLogger.error('❌ Erreur dans ErrorHandler: $e');
      return 'Erreur de traitement des erreurs.';
    }
  }

  /// Traitement des erreurs d'upload
  /// Convertit les erreurs d'upload en messages utilisateur
  static String handleUploadError(dynamic error) {
    try {
      if (error is ApiException) {
        return _getUploadErrorMessage(error);
      } else if (error is SocketException) {
        return 'Problème de connexion internet. Vérifiez votre réseau.';
      } else if (error is FormatException) {
        return 'Format de fichier non supporté.';
      } else if (error is HttpException) {
        return 'Erreur de communication avec le serveur.';
      } else if (error.toString().contains('Fichier trop volumineux')) {
        return 'Fichier trop volumineux. Taille maximum: 10MB.';
      } else if (error.toString().contains('Format de fichier non supporté')) {
        return 'Format de fichier non supporté. Utilisez JPG, PNG ou WebP.';
      } else {
        return 'Erreur lors de l\'upload du fichier.';
      }
    } catch (e) {
      AppLogger.error('❌ Erreur dans ErrorHandler upload: $e');
      return 'Erreur de traitement des erreurs d\'upload.';
    }
  }

  /// Traitement des erreurs de profil
  /// Convertit les erreurs de profil en messages utilisateur
  static String handleProfileError(dynamic error) {
    try {
      if (error is ApiException) {
        return _getProfileErrorMessage(error);
      } else if (error is SocketException) {
        return 'Problème de connexion internet. Vérifiez votre réseau.';
      } else if (error is FormatException) {
        return 'Erreur de format des données.';
      } else if (error is HttpException) {
        return 'Erreur de communication avec le serveur.';
      } else {
        return 'Erreur lors de la mise à jour du profil.';
      }
    } catch (e) {
      AppLogger.error('❌ Erreur dans ErrorHandler profile: $e');
      return 'Erreur de traitement des erreurs de profil.';
    }
  }

  /// Traitement des erreurs génériques
  /// Convertit les erreurs génériques en messages utilisateur
  static String handleGenericError(dynamic error) {
    try {
      if (error is ApiException) {
        return error.message;
      } else if (error is SocketException) {
        return 'Problème de connexion internet. Vérifiez votre réseau.';
      } else if (error is FormatException) {
        return 'Erreur de format des données.';
      } else if (error is HttpException) {
        return 'Erreur de communication avec le serveur.';
      } else {
        return 'Une erreur inattendue est survenue.';
      }
    } catch (e) {
      AppLogger.error('❌ Erreur dans ErrorHandler générique: $e');
      return 'Erreur de traitement des erreurs.';
    }
  }

  /// Messages d'erreur spécifiques à l'authentification
  /// Retourne un message utilisateur basé sur le code d'erreur
  static String _getAuthErrorMessage(ApiException error) {
    final statusCode = error.statusCode;
    final message = error.message.toLowerCase();

    switch (statusCode) {
      case 400:
        if (message.contains('email') || message.contains('utilisateur')) {
          return 'Aucun compte associé à cet email.';
        } else if (message.contains('mot de passe') ||
            message.contains('password')) {
          return 'Mot de passe incorrect.';
        } else {
          return 'Données invalides. Vérifiez vos informations.';
        }
      case 401:
        return 'Email ou mot de passe incorrect.';
      case 403:
        return 'Accès interdit. Vérifiez vos permissions.';
      case 404:
        return 'Service non disponible.';
      case 409:
        return 'Un compte avec cet email existe déjà.';
      case 422:
        return 'Erreur de validation. Vérifiez vos données.';
      case 429:
        return 'Trop de tentatives. Veuillez patienter quelques minutes.';
      case 500:
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      case 503:
        return 'Service temporairement indisponible.';
      default:
        return 'Erreur de connexion. Veuillez réessayer.';
    }
  }

  /// Messages d'erreur spécifiques à l'upload
  /// Retourne un message utilisateur basé sur le type d'erreur d'upload
  static String _getUploadErrorMessage(ApiException error) {
    final statusCode = error.statusCode;
    final message = error.message.toLowerCase();

    switch (statusCode) {
      case 400:
        if (message.contains('fichier') || message.contains('file')) {
          return 'Fichier invalide. Vérifiez le format et la taille.';
        } else {
          return 'Données d\'upload invalides.';
        }
      case 401:
        return 'Authentification requise pour l\'upload.';
      case 403:
        return 'Permission d\'upload refusée.';
      case 413:
        return 'Fichier trop volumineux. Taille maximum: 10MB.';
      case 415:
        return 'Format de fichier non supporté.';
      case 500:
        return 'Erreur serveur lors de l\'upload.';
      default:
        return 'Erreur lors de l\'upload du fichier.';
    }
  }

  /// Messages d'erreur spécifiques au profil
  /// Retourne un message utilisateur basé sur le type d'erreur de profil
  static String _getProfileErrorMessage(ApiException error) {
    final statusCode = error.statusCode;
    final message = error.message.toLowerCase();

    switch (statusCode) {
      case 400:
        if (message.contains('email')) {
          return 'Email invalide.';
        } else if (message.contains('téléphone') ||
            message.contains('telephone')) {
          return 'Numéro de téléphone invalide.';
        } else {
          return 'Données de profil invalides.';
        }
      case 401:
        return 'Authentification requise.';
      case 403:
        return 'Permission de modification refusée.';
      case 404:
        return 'Profil non trouvé.';
      case 422:
        return 'Erreur de validation des données.';
      case 500:
        return 'Erreur serveur lors de la mise à jour.';
      default:
        return 'Erreur lors de la mise à jour du profil.';
    }
  }

  /// Vérification si une erreur est récupérable
  /// Retourne true si l'utilisateur peut réessayer l'action
  static bool isRecoverableError(dynamic error) {
    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is ApiException) {
      final statusCode = error.statusCode;
      return statusCode == null ||
          statusCode >= 500 ||
          statusCode == 429; // Erreurs temporaires
    }
    return false;
  }

  /// Obtention du type d'erreur pour le logging
  /// Retourne le type d'erreur pour faciliter le debugging
  static String getErrorType(dynamic error) {
    if (error is ApiException) return 'API_ERROR';
    if (error is SocketException) return 'NETWORK_ERROR';
    if (error is FormatException) return 'FORMAT_ERROR';
    if (error is HttpException) return 'HTTP_ERROR';
    return 'UNKNOWN_ERROR';
  }

  // ===== MÉTHODES POUR L'UI (Widgets) =====

  /// Affichage d'un message d'erreur dans un SnackBar
  /// Affiche un message d'erreur à l'utilisateur
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Affichage d'un message de succès dans un SnackBar
  /// Affiche un message de succès à l'utilisateur
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Construction d'un widget d'erreur auto-disparissant
  /// Crée un widget d'erreur qui disparaît automatiquement
  static Widget buildAutoDisappearingErrorContainer(String? error) {
    if (error == null || error.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  /// Construction d'une liste d'erreurs
  /// Crée un widget affichant une liste d'erreurs
  static Widget buildErrorList(List<String> errors) {
    if (errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Erreurs détectées:',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                '• $error',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== MÉTHODES DE VALIDATION =====

  /// Validation d'un nom
  /// Retourne un message d'erreur si le nom est invalide
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (name.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  /// Validation d'un email
  /// Retourne un message d'erreur si l'email est invalide
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'L\'email est obligatoire';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Format d\'email invalide';
    }

    return null;
  }

  /// Validation d'un téléphone
  /// Retourne un message d'erreur si le téléphone est invalide
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Le téléphone est obligatoire';
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 8 || cleanPhone.length > 15) {
      return 'Numéro de téléphone invalide';
    }

    return null;
  }

  /// Validation d'un mot de passe
  /// Retourne un message d'erreur si le mot de passe est invalide
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }
}
