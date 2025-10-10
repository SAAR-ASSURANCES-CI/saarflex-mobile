import 'package:saarflex_app/data/services/api_service.dart';
import 'package:saarflex_app/data/models/user_model.dart';
import 'package:saarflex_app/core/utils/logger.dart';

/// Service utilisateur - Logique métier pour la gestion du profil
/// Responsabilité : Gestion des données utilisateur et du profil
class UserService {
  final ApiService _apiService = ApiService();

  /// Chargement du profil utilisateur complet
  /// Retourne les informations détaillées de l'utilisateur
  Future<User> getUserProfile() async {
    try {
      AppLogger.info('👤 Chargement du profil utilisateur');

      final user = await _apiService.getUserProfile();

      AppLogger.info('✅ Profil chargé: ${user.nom} (${user.email})');
      return user;
    } catch (e) {
      AppLogger.error('❌ Erreur chargement profil: $e');
      rethrow;
    }
  }

  /// Mise à jour du profil utilisateur
  /// Met à jour les informations utilisateur
  Future<User> updateProfile(Map<String, dynamic> updates) async {
    try {
      AppLogger.info('📝 Mise à jour du profil: ${updates.keys.join(', ')}');

      final updatedUser = await _apiService.updateProfile(updates);

      AppLogger.info('✅ Profil mis à jour: ${updatedUser.nom}');
      return updatedUser;
    } catch (e) {
      AppLogger.error('❌ Erreur mise à jour profil: $e');
      rethrow;
    }
  }

  /// Vérification du statut de complétion du profil
  /// Retourne true si le profil est complet
  Future<bool> checkProfileStatus() async {
    try {
      AppLogger.info('🔍 Vérification statut profil');

      final isComplete = await _apiService.checkProfileStatus();

      AppLogger.info(
        '✅ Statut profil: ${isComplete ? "Complet" : "Incomplet"}',
      );
      return isComplete;
    } catch (e) {
      AppLogger.error('❌ Erreur vérification statut: $e');
      return false;
    }
  }

  /// Mise à jour d'un champ spécifique du profil
  /// Met à jour un seul champ du profil utilisateur
  Future<User> updateUserField(String fieldName, dynamic value) async {
    try {
      AppLogger.info('📝 Mise à jour champ: $fieldName');

      final updates = {fieldName: value};
      final updatedUser = await _apiService.updateProfile(updates);

      AppLogger.info('✅ Champ $fieldName mis à jour');
      return updatedUser;
    } catch (e) {
      AppLogger.error('❌ Erreur mise à jour champ: $e');
      rethrow;
    }
  }

  /// Vérification des rôles utilisateur
  /// Retourne true si l'utilisateur a le rôle spécifié
  bool hasRole(User user, TypeUtilisateur role) {
    try {
      final hasRole = user.typeUtilisateur == role;
      AppLogger.info('🔐 Vérification rôle $role: $hasRole');
      return hasRole;
    } catch (e) {
      AppLogger.error('❌ Erreur vérification rôle: $e');
      return false;
    }
  }

  /// Vérification des permissions d'accès
  /// Retourne true si l'utilisateur peut accéder aux rôles spécifiés
  bool canAccess(User user, List<TypeUtilisateur> allowedRoles) {
    try {
      final canAccess = allowedRoles.contains(user.typeUtilisateur);
      AppLogger.info('🔐 Vérification accès: $canAccess');
      return canAccess;
    } catch (e) {
      AppLogger.error('❌ Erreur vérification accès: $e');
      return false;
    }
  }

  /// Vérification de la complétion des documents d'identité
  /// Retourne true si tous les documents sont présents
  bool hasCompleteIdentityDocuments(User user) {
    try {
      final hasDocuments =
          user.frontDocumentPath != null &&
          user.frontDocumentPath!.isNotEmpty &&
          user.backDocumentPath != null &&
          user.backDocumentPath!.isNotEmpty;

      AppLogger.info(
        '📄 Documents identité: ${hasDocuments ? "Complets" : "Incomplets"}',
      );
      return hasDocuments;
    } catch (e) {
      AppLogger.error('❌ Erreur vérification documents: $e');
      return false;
    }
  }

  /// Actualisation des données utilisateur
  /// Recharge les données utilisateur depuis le serveur
  Future<User> refreshUserData() async {
    try {
      AppLogger.info('🔄 Actualisation données utilisateur');

      final user = await _apiService.getUserProfile();

      AppLogger.info('✅ Données actualisées: ${user.nom}');
      return user;
    } catch (e) {
      AppLogger.error('❌ Erreur actualisation: $e');
      rethrow;
    }
  }

  /// Validation des données utilisateur
  /// Valide les informations avant sauvegarde
  bool validateUserData(Map<String, dynamic> userData) {
    try {
      // Validation des champs obligatoires
      final requiredFields = ['nom', 'email', 'telephone'];

      for (final field in requiredFields) {
        if (userData[field] == null ||
            userData[field].toString().trim().isEmpty) {
          AppLogger.error('⚠️ Champ obligatoire manquant: $field');
          return false;
        }
      }

      // Validation de l'email
      final email = userData['email']?.toString() ?? '';
      if (!_isValidEmail(email)) {
        AppLogger.error('⚠️ Email invalide: $email');
        return false;
      }

      // Validation du téléphone
      final telephone = userData['telephone']?.toString() ?? '';
      if (!_isValidPhone(telephone)) {
        AppLogger.error('⚠️ Téléphone invalide: $telephone');
        return false;
      }

      AppLogger.info('✅ Données utilisateur valides');
      return true;
    } catch (e) {
      AppLogger.error('❌ Erreur validation: $e');
      return false;
    }
  }

  /// Validation de l'email
  /// Retourne true si l'email est valide
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validation du téléphone
  /// Retourne true si le téléphone est valide
  bool _isValidPhone(String phone) {
    // Supprimer les espaces et caractères spéciaux
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Vérifier que c'est un numéro de téléphone valide (8-15 chiffres)
    return cleanPhone.length >= 8 && cleanPhone.length <= 15;
  }
}
