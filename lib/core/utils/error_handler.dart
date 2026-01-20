import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saarciflex_app/data/services/api_service.dart';

class ErrorHandler {
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
      return 'Erreur de traitement des erreurs.';
    }
  }

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
      return 'Erreur de traitement des erreurs d\'upload.';
    }
  }

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
      return 'Erreur de traitement des erreurs de profil.';
    }
  }

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
      return 'Erreur de traitement des erreurs.';
    }
  }

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

  static String getErrorType(dynamic error) {
    if (error is ApiException) return 'API_ERROR';
    if (error is SocketException) return 'NETWORK_ERROR';
    if (error is FormatException) return 'FORMAT_ERROR';
    if (error is HttpException) return 'HTTP_ERROR';
    return 'UNKNOWN_ERROR';
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('Error showing snackbar: $e');
    }
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('Error showing snackbar: $e');
    }
  }

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

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (name.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

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
