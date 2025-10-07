import 'package:flutter/foundation.dart';

/// Système de logging optimisé pour la production
class AppLogger {
  /// Log de niveau debug (développement uniquement)
  static void debug(String message) {
    if (kDebugMode) {
      print('🐛 DEBUG: $message');
    }
  }

  /// Log de niveau info
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  /// Log de niveau error
  static void error(String message, [dynamic error]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) {
        print('❌ ERROR DETAILS: $error');
      }
    }
  }

  /// Log pour les opérations API
  static void api(String message) {
    if (kDebugMode) {
      print('🌐 API: $message');
    }
  }

  /// Log pour les opérations d'authentification
  static void auth(String message) {
    if (kDebugMode) {
      print('🔐 AUTH: $message');
    }
  }

  /// Log pour les performances (développement uniquement)
  static void performance(String message) {
    if (kDebugMode) {
      print('⚡ PERF: $message');
    }
  }

  /// Log pour la navigation
  static void navigation(String message) {
    if (kDebugMode) {
      print('🧭 NAV: $message');
    }
  }
}
