import 'package:saarflex_app/data/services/api_service.dart';
import 'package:saarflex_app/core/utils/logger.dart';

/// Service d'authentification - Logique métier pure
/// Responsabilité : Gestion de l'authentification utilisateur
class AuthService {
  final ApiService _apiService = ApiService();

  /// Authentification utilisateur
  /// Retourne les informations utilisateur et le token
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('🔐 Tentative de connexion pour: $email');

      final authResponse = await _apiService.login(
        email: email,
        password: password,
      );

      AppLogger.info('✅ Connexion réussie pour: $email');
      return authResponse;
    } catch (e) {
      AppLogger.error('❌ Erreur de connexion: $e');
      rethrow;
    }
  }

  /// Inscription utilisateur
  /// Retourne les informations utilisateur et le token
  Future<AuthResponse> signup({
    required String nom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    try {
      AppLogger.info('📝 Tentative d\'inscription pour: $email');

      final authResponse = await _apiService.signup(
        nom: nom,
        email: email,
        telephone: telephone,
        password: password,
      );

      AppLogger.info('✅ Inscription réussie pour: $email');
      return authResponse;
    } catch (e) {
      AppLogger.error('❌ Erreur d\'inscription: $e');
      rethrow;
    }
  }

  /// Déconnexion utilisateur
  /// Nettoie les données locales et notifie le serveur
  Future<void> logout() async {
    try {
      AppLogger.info('🚪 Déconnexion utilisateur');

      await _apiService.logout();

      AppLogger.info('✅ Déconnexion réussie');
    } catch (e) {
      AppLogger.error('❌ Erreur de déconnexion: $e');
      // On continue même en cas d'erreur serveur
      // car on veut déconnecter l'utilisateur localement
    }
  }

  /// Vérification du statut de connexion
  /// Retourne true si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      return await _apiService.isLoggedIn();
    } catch (e) {
      AppLogger.error('❌ Erreur vérification statut: $e');
      return false;
    }
  }

  /// Demande de réinitialisation de mot de passe
  /// Envoie un email avec un code de réinitialisation
  Future<void> forgotPassword(String email) async {
    try {
      AppLogger.info('🔑 Demande de réinitialisation pour: $email');

      await _apiService.forgotPassword(email);

      AppLogger.info('✅ Email de réinitialisation envoyé');
    } catch (e) {
      AppLogger.error('❌ Erreur envoi email: $e');
      rethrow;
    }
  }

  /// Vérification du code OTP
  /// Valide le code reçu par email
  Future<void> verifyOtp({required String email, required String code}) async {
    try {
      AppLogger.info('🔐 Vérification OTP pour: $email');

      await _apiService.verifyOtp(email: email, code: code);

      AppLogger.info('✅ Code OTP vérifié');
    } catch (e) {
      AppLogger.error('❌ Erreur vérification OTP: $e');
      rethrow;
    }
  }

  /// Réinitialisation du mot de passe avec code
  /// Change le mot de passe après vérification du code
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      AppLogger.info('🔑 Réinitialisation mot de passe pour: $email');

      await _apiService.resetPasswordWithCode(
        email: email,
        code: code,
        newPassword: newPassword,
      );

      AppLogger.info('✅ Mot de passe réinitialisé');
    } catch (e) {
      AppLogger.error('❌ Erreur réinitialisation: $e');
      rethrow;
    }
  }

  /// Vérification de la validité du token
  /// Retourne true si le token est valide
  Future<bool> checkTokenValidity() async {
    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      return isLoggedIn;
    } catch (e) {
      AppLogger.error('❌ Erreur vérification token: $e');
      return false;
    }
  }

  /// Initialisation de l'authentification
  /// Vérifie le statut de connexion au démarrage
  Future<bool> initializeAuth() async {
    try {
      AppLogger.info('🚀 Initialisation authentification');

      final isLoggedIn = await _apiService.isLoggedIn();

      if (isLoggedIn) {
        AppLogger.info('✅ Utilisateur déjà connecté');
      } else {
        AppLogger.info('ℹ️ Utilisateur non connecté');
      }

      return isLoggedIn;
    } catch (e) {
      AppLogger.error('❌ Erreur initialisation: $e');
      return false;
    }
  }
}
