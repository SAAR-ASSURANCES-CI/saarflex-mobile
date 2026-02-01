import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Vérifie si l'authentification biométrique est disponible sur l'appareil
  /// Selon la doc: canCheckBiometrics vérifie le support matériel
  /// isDeviceSupported vérifie si l'appareil supporte l'authentification locale
  static Future<bool> isAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      
      // Retourne true si au moins une méthode est disponible
      return canCheckBiometrics || isDeviceSupported;
    } catch (e) {
      debugPrint('Erreur lors de la vérification biométrique: $e');
      return false;
    }
  }

  /// Obtient la liste des biométries disponibles (enrolled)
  /// Important: canCheckBiometrics ne garantit pas qu'il y a des biométries enregistrées
  /// Il faut utiliser getAvailableBiometrics() pour vérifier
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des biométries: $e');
      return [];
    }
  }

  /// Authentifie l'utilisateur avec biométrie
  /// Selon la doc: biometricOnly: true force l'utilisation de la biométrie uniquement
  /// (pas de fallback sur PIN/password)
  static Future<bool> authenticate({
    String? reason,
  }) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason ?? 
            'Veuillez vous authentifier pour accéder à votre compte SAAR CI',
        options: const AuthenticationOptions(
          biometricOnly: true, // Force l'utilisation de la biométrie uniquement
          stickyAuth: true, // Maintient l'authentification même si l'app est mise en arrière-plan
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Erreur d\'authentification biométrique: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Erreur inattendue lors de l\'authentification biométrique: $e');
      return false;
    }
  }

  /// Obtient le nom du type biométrique pour l'affichage
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Empreinte digitale';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Authentification forte';
      case BiometricType.weak:
        return 'Authentification faible';
    }
  }

  /// Vérifie si au moins une biométrie est enregistrée
  static Future<bool> hasEnrolledBiometrics() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

