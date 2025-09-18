/// Configuration pour la production
class ProductionConfig {
  // Désactiver les logs en production
  static const bool enableLogs = false;

  // Configuration de l'API
  static const String baseUrl = 'https://api.saarflex.com';

  // Timeouts optimisés pour la production
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Configuration de l'interface utilisateur
  static const bool enableDebugFeatures = false;
  static const bool enablePerformanceLogs = false;

  // Configuration de la sécurité
  static const bool enableAutoLogout = true;
  static const Duration autoLogoutDuration = Duration(hours: 24);

  // Configuration des erreurs
  static const bool showDetailedErrors = false;
  static const String defaultErrorMessage = 'Une erreur est survenue';
}
