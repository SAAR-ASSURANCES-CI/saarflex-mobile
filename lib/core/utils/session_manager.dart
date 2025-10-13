import 'dart:async';
import 'package:saarflex_app/core/utils/logger.dart';
import 'package:saarflex_app/data/services/auth_service.dart';

/// Gestionnaire de session avec la logique de déconnexion demandée
///
/// RÈGLES IMPLÉMENTÉES:
/// 1. Background → Timer 5min → Déconnexion
/// 2. Reload → Déconnexion immédiate
/// 3. Fermeture → Déconnexion immédiate
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // Services
  final AuthService _authService = AuthService();

  // Timer pour le background
  Timer? _backgroundTimer;
  static const Duration _backgroundTimeout = Duration(minutes: 5);

  // État de l'application
  bool _isInBackground = false;
  bool _isAppClosed = false;

  /// Initialisation du gestionnaire de session
  /// À appeler au démarrage de l'app
  void initialize() {
    AppLogger.info('🚀 Initialisation SessionManager');
    _setupAppLifecycleListener();
  }

  /// Configuration de l'écouteur du cycle de vie de l'app
  void _setupAppLifecycleListener() {
    // Détection du reload au démarrage
    _detectReload();
    AppLogger.info('📱 Configuration écouteur cycle de vie');
  }

  /// Détection du reload de l'application
  void _detectReload() {
    // Vérifier si l'app a été rechargée
    // Cette logique sera appelée à chaque démarrage
    AppLogger.info('🔄 Vérification reload...');

    // Si l'app démarre et qu'il y a un token, c'est probablement un reload
    // La déconnexion sera gérée par l'AuthViewModel lors de l'initialisation
  }

  // ===== GESTION DU BACKGROUND (RÈGLE 1) =====

  /// App passe en background
  /// Démarre le timer de 5 minutes
  void onAppPaused() {
    if (_isAppClosed) return; // Ignorer si app fermée

    AppLogger.info('🟡 App en background - Démarrage timer 5min');
    _isInBackground = true;
    _startBackgroundTimer();
  }

  /// App revient au premier plan
  /// Annule le timer si l'utilisateur revient à temps
  void onAppResumed() {
    if (_isAppClosed) return; // Ignorer si app fermée

    AppLogger.info('🟢 App au premier plan - Annulation timer');
    _isInBackground = false;
    _cancelBackgroundTimer();
  }

  /// Démarrage du timer de 5 minutes
  void _startBackgroundTimer() {
    _cancelBackgroundTimer(); // Annuler le timer précédent si existe

    _backgroundTimer = Timer(_backgroundTimeout, () {
      AppLogger.error('⏰ Timer 5min expiré - Déconnexion automatique');
      _logoutUser('Session expirée (5 minutes d\'inactivité)');
    });

    AppLogger.info('⏰ Timer 5min démarré');
  }

  /// Annulation du timer de background
  void _cancelBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    AppLogger.info('✅ Timer 5min annulé - Session maintenue');
  }

  // ===== GESTION DU RELOAD (RÈGLE 2) =====

  /// Reload détecté
  /// Déconnexion immédiate
  void onAppReload() {
    AppLogger.error('🔄 Reload détecté - Déconnexion immédiate');
    _logoutUser('Application rechargée');
  }

  // ===== GESTION DE LA FERMETURE (RÈGLE 3) =====

  /// App fermée
  /// Déconnexion immédiate
  void onAppClosed() {
    AppLogger.error('🔴 App fermée - Déconnexion immédiate');
    _isAppClosed = true;
    _logoutUser('Application fermée');
  }

  // ===== LOGIQUE DE DÉCONNEXION =====

  /// Déconnexion de l'utilisateur
  /// Nettoie toutes les données et redirige vers login
  Future<void> _logoutUser(String reason) async {
    try {
      AppLogger.info('🚪 Déconnexion utilisateur: $reason');

      // Annuler tous les timers
      _cancelBackgroundTimer();

      // Déconnexion via AuthService
      await _authService.logout();

      // Nettoyage des états
      _isInBackground = false;
      _isAppClosed = false;

      AppLogger.info('✅ Déconnexion réussie');
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la déconnexion: $e');
    }
  }

  // ===== MÉTHODES UTILITAIRES =====

  /// Vérifie si l'app est en background
  bool get isInBackground => _isInBackground;

  /// Vérifie si l'app est fermée
  bool get isAppClosed => _isAppClosed;

  /// Vérifie si le timer de background est actif
  bool get isBackgroundTimerActive => _backgroundTimer?.isActive ?? false;

  /// Temps restant avant déconnexion automatique
  Duration? get remainingBackgroundTime {
    if (!isBackgroundTimerActive) return null;

    // Note: Cette implémentation nécessite de stocker le timestamp de démarrage
    // Pour une implémentation complète, il faudrait tracker le temps de démarrage
    return _backgroundTimeout;
  }

  /// Nettoyage des ressources
  void dispose() {
    _cancelBackgroundTimer();
    AppLogger.info('🧹 SessionManager nettoyé');
  }
}
