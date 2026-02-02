import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticate({
    String? reason,
  }) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason ?? 
            'Veuillez vous authentifier pour accéder à votre compte SAARCIFLEX',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

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

  static Future<bool> hasEnrolledBiometrics() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isDeviceAuthSupported() async {
    try {
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasBiometricOnly() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticateWithFallback({
    String? reason,
  }) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason ?? 
            'Veuillez vous authentifier pour accéder à votre compte SAARCIFLEX',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<String> getAvailableAuthTypeName() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.isNotEmpty) {
        return getBiometricTypeName(biometrics.first);
      }
      final isSupported = await isDeviceAuthSupported();
      if (isSupported) {
        return 'Code PIN';
      }
      return 'Authentification';
    } catch (e) {
      return 'Authentification';
    }
  }
}

