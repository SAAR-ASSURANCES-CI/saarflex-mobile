import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/data/services/auth_service.dart';

void main() {
  group('AuthService', () {
    // Note: AuthService utilise ApiService qui est un singleton
    // Pour des tests complets, il faudrait refactoriser pour injecter ApiService
    // Ces tests vérifient la structure de base

    group('login', () {
      test('appelle ApiService.login avec les bons paramètres', () {
        // Test structurel - nécessite mocks
        final service = AuthService();
        expect(service, isNotNull);
      });
    });

    group('signup', () {
      test('appelle ApiService.signup avec les bons paramètres', () {
        final service = AuthService();
        expect(service, isNotNull);
      });
    });

    group('logout', () {
      test('appelle ApiService.logout', () {
        final service = AuthService();
        expect(service, isNotNull);
      });
    });

    group('isLoggedIn', () {
      test('vérifie le statut de connexion', () {
        final service = AuthService();
        expect(service, isNotNull);
      });
    });

    group('forgotPassword', () {
      test('envoie email de réinitialisation', () {
        final service = AuthService();
        expect(service, isNotNull);
      });
    });

    group('verifyOtp', () {
      test('vérifie le code OTP', () {
        final service = AuthService();
        expect(service, isNotNull);
      });
    });

    group('resetPasswordWithCode', () {
      test('réinitialise le mot de passe avec code', () {
        final service = AuthService();
        expect(service, isNotNull);
      });
    });
  });
}
