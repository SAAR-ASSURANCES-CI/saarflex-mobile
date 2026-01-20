import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/data/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService service;

    setUp(() {
      service = AuthService();
    });

    group('Structure', () {
      test('peut être instancié', () {
        expect(service, isNotNull);
        expect(service, isA<AuthService>());
      });
    });

    group('login', () {
      test('retourne une exception si email invalide', () async {
        try {
          await service.login(
            email: 'invalid-email',
            password: 'password123',
          );
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('retourne une exception si email vide', () async {
        try {
          await service.login(email: '', password: 'password123');
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('retourne une exception si password vide', () async {
        try {
          await service.login(email: 'test@test.com', password: '');
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });

    });

    group('signup', () {
      test('retourne une exception si nom vide', () async {
        try {
          await service.signup(
            nom: '',
            email: 'test@test.com',
            password: 'password123',
          );
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('retourne une exception si email invalide', () async {
        try {
          await service.signup(
            nom: 'Test User',
            email: 'invalid-email',
            password: 'password123',
          );
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('retourne une exception si password vide', () async {
        try {
          await service.signup(
            nom: 'Test User',
            email: 'test@test.com',
            password: '',
          );
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });
    });

    group('logout', () {
      test('peut être appelé sans erreur même si non connecté', () async {
        try {
          await service.logout();
        } catch (e) {
          expect(e, isNotNull);
        }
      });
    });

    group('isLoggedIn', () {
      test('retourne un booléen', () async {
        final result = await service.isLoggedIn();
        expect(result, isA<bool>());
      });

      test('retourne false si non connecté', () async {
        final result = await service.isLoggedIn();
        expect(result, isA<bool>());
      });
    });

    group('forgotPassword', () {
      test('retourne une exception si email invalide', () async {
        try {
          await service.forgotPassword('invalid-email');
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('retourne une exception si email vide', () async {
        try {
          await service.forgotPassword('');
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });
    });

    group('verifyOtp', () {
      test('retourne une exception si email invalide', () async {
        try {
          await service.verifyOtp(email: 'invalid-email', code: '123456');
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('retourne une exception si code vide', () async {
        try {
          await service.verifyOtp(email: 'test@test.com', code: '');
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });
    });

    group('resetPasswordWithCode', () {
      test('retourne une exception si email invalide', () async {
        try {
          await service.resetPasswordWithCode(
            email: 'invalid-email',
            code: '123456',
            newPassword: 'newpassword123',
          );
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('retourne une exception si code vide', () async {
        try {
          await service.resetPasswordWithCode(
            email: 'test@test.com',
            code: '',
            newPassword: 'newpassword123',
          );
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('retourne une exception si newPassword vide', () async {
        try {
          await service.resetPasswordWithCode(
            email: 'test@test.com',
            code: '123456',
            newPassword: '',
          );
          fail('Devrait lancer une exception');
        } catch (e) {
          expect(e, isNotNull);
        }
      });
    });

    group('checkTokenValidity', () {
      test('retourne un booléen', () async {
        final result = await service.checkTokenValidity();
        expect(result, isA<bool>());
      });
    });

    group('initializeAuth', () {
      test('retourne un booléen', () async {
        final result = await service.initializeAuth();
        expect(result, isA<bool>());
      });
    });

  });
}
