import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

enum BiometricKind { face, iris, fingerprint, pattern, unknown }

class BiometricCapability {
  final bool isAvailable;
  final List<BiometricKind> availableKinds;
  final BiometricKind primaryKind;

  const BiometricCapability({
    required this.isAvailable,
    required this.availableKinds,
    required this.primaryKind,
  });

  factory BiometricCapability.unavailable() => const BiometricCapability(
        isAvailable: false,
        availableKinds: [],
        primaryKind: BiometricKind.unknown,
      );
}
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static BiometricCapability? _cache;

  static const _priority = [
    BiometricKind.face,
    BiometricKind.iris,
    BiometricKind.fingerprint,
    BiometricKind.pattern,
  ];


  static Future<bool> isAvailable() async {
    final cap = await _getCapability();
    return cap.isAvailable;
  }

  static Future<bool> hasEnrolledBiometrics() async {
    final cap = await _getCapability();
    return cap.availableKinds.isNotEmpty;
  }

  static Future<bool> isDeviceAuthSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticateWithFallback({String? reason}) async {
    try {
      final r = reason ?? await _buildReason();
      return await _auth.authenticate(
        localizedReason: r,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<BiometricKind> getPrimaryKind() async {
    final cap = await _getCapability();
    return cap.primaryKind;
  }

  static Future<IconData> getPrimaryIcon() async {
    return _iconFor(await getPrimaryKind());
  }
  static Future<String> getPrimaryLabel() async {
    return _labelFor(await getPrimaryKind());
  }

  static void invalidateCache() => _cache = null;

  static Future<BiometricCapability> _getCapability() async {
    if (_cache != null) return _cache!;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final deviceSupported = await _auth.isDeviceSupported();

      if (!canCheck && !deviceSupported) {
        return _cache = BiometricCapability.unavailable();
      }

      final enrolled = await _auth.getAvailableBiometrics();
      final kinds = enrolled.map(_mapType).toList();

      if (deviceSupported && !kinds.contains(BiometricKind.pattern)) {
        kinds.add(BiometricKind.pattern);
      }

      if (kinds.isEmpty) return _cache = BiometricCapability.unavailable();

      final primary = _priority.firstWhere(
        (k) => kinds.contains(k),
        orElse: () => kinds.first,
      );

      return _cache = BiometricCapability(
        isAvailable: true,
        availableKinds: kinds,
        primaryKind: primary,
      );
    } catch (_) {
      return _cache = BiometricCapability.unavailable();
    }
  }

  static BiometricKind _mapType(BiometricType t) {
    switch (t) {
      case BiometricType.face:
        return BiometricKind.face;
      case BiometricType.iris:
        return BiometricKind.iris;
      case BiometricType.fingerprint:
      case BiometricType.strong:
      case BiometricType.weak:
        return BiometricKind.fingerprint;
    }
  }

  static Future<String> _buildReason() async {
    final kind = await getPrimaryKind();
    switch (kind) {
      case BiometricKind.face:
        return 'Regardez la caméra pour accéder à votre compte SAARCIFLEX';
      case BiometricKind.iris:
        return 'Scannez votre œil pour accéder à votre compte SAARCIFLEX';
      case BiometricKind.fingerprint:
        return 'Placez votre doigt sur le capteur pour accéder à votre compte SAARCIFLEX';
      case BiometricKind.pattern:
        return 'Utilisez votre schéma ou PIN pour accéder à votre compte SAARCIFLEX';
      case BiometricKind.unknown:
        return 'Authentifiez-vous pour accéder à votre compte SAARCIFLEX';
    }
  }

  static IconData _iconFor(BiometricKind kind) {
    switch (kind) {
      case BiometricKind.face:
        return Icons.face_unlock_outlined;
      case BiometricKind.iris:
        return Icons.remove_red_eye_outlined;
      case BiometricKind.fingerprint:
        return Icons.fingerprint;
      case BiometricKind.pattern:
        return Icons.pin_outlined;
      case BiometricKind.unknown:
        return Icons.security;
    }
  }

  static String _labelFor(BiometricKind kind) {
    switch (kind) {
      case BiometricKind.face:
        return 'Face ID';
      case BiometricKind.iris:
        return 'Scan iris';
      case BiometricKind.fingerprint:
        return 'Empreinte digitale';
      case BiometricKind.pattern:
        return 'Schéma / PIN';
      case BiometricKind.unknown:
        return 'Authentification';
    }
  }
}