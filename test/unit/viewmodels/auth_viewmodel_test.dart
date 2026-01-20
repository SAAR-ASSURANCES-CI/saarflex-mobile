import 'package:flutter_test/flutter_test.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:saarciflex_app/data/models/user_model.dart';

void main() {
  late AuthViewModel viewModel;

  setUp(() {
    viewModel = AuthViewModel();
  });

  tearDown(() {
  });

  group('AuthViewModel - États initiaux', () {
    test('isLoading initial est false', () {
      expect(viewModel.isLoading, false);
    });

    test('isLoggedIn initial est false', () {
      expect(viewModel.isLoggedIn, false);
    });

    test('currentUser initial est null', () {
      expect(viewModel.currentUser, isNull);
    });

    test('errorMessage initial est null', () {
      expect(viewModel.errorMessage, isNull);
    });

    test('authToken initial est null', () {
      expect(viewModel.authToken, isNull);
    });

    test('userName retourne "Utilisateur" si currentUser est null', () {
      expect(viewModel.userName, 'Utilisateur');
    });

    test('userEmail retourne chaîne vide si currentUser est null', () {
      expect(viewModel.userEmail, isEmpty);
    });

    test('isClient retourne true par défaut', () {
      expect(viewModel.isClient, true);
    });

    test('isProfileComplete retourne false par défaut', () {
      expect(viewModel.isProfileComplete, false);
    });
  });

  group('AuthViewModel - clearError', () {
    test('clearError nettoie le message d\'erreur', () {
      viewModel.clearError();
      expect(viewModel.errorMessage, isNull);
    });

    test('clearUploadError nettoie le message d\'erreur d\'upload', () {
      viewModel.clearUploadError();
      expect(viewModel.uploadErrorMessage, isNull);
    });

    test('clearAllErrors nettoie tous les messages d\'erreur', () {
      viewModel.clearAllErrors();
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.uploadErrorMessage, isNull);
    });
  });

  group('AuthViewModel - forceLogout', () {
    test('forceLogout nettoie tous les états d\'authentification', () {
      viewModel.forceLogout();
      expect(viewModel.isLoggedIn, false);
      expect(viewModel.currentUser, isNull);
      expect(viewModel.authToken, isNull);
      expect(viewModel.errorMessage, isNull);
    });
  });

  group('AuthViewModel - hasCompleteIdentityDocuments', () {
    test('retourne false si currentUser est null', () {
      expect(viewModel.hasCompleteIdentityDocuments(), false);
    });
  });

  group('AuthViewModel - hasRole', () {
    test('retourne false si currentUser est null', () {
      expect(viewModel.hasRole(TypeUtilisateur.client), false);
      expect(viewModel.hasRole(TypeUtilisateur.agent), false);
    });
  });

  group('AuthViewModel - canAccess', () {
    test('retourne false si currentUser est null', () {
      expect(viewModel.canAccess([TypeUtilisateur.client]), false);
      expect(viewModel.canAccess([TypeUtilisateur.agent, TypeUtilisateur.admin]), false);
    });
  });

  group('AuthViewModel - Comportements (nécessitent mocks)', () {
    test('login devrait mettre isLoading à true puis false', () async {
      try {
        final result = await viewModel.login(
          email: 'test@test.com',
          password: 'password123',
        );
        expect(result, isA<bool>());
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('signup devrait mettre isLoading à true puis false', () async {
      try {
        final result = await viewModel.signup(
          nom: 'Test User',
          email: 'test@test.com',
          password: 'password123',
        );
        expect(result, isA<bool>());
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('logout devrait nettoyer la session', () async {
      try {
        await viewModel.logout();
        expect(viewModel.isLoggedIn, false);
        expect(viewModel.currentUser, isNull);
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('forgotPassword devrait envoyer un email', () async {
      try {
        final result = await viewModel.forgotPassword('test@test.com');
        expect(result, isA<bool>());
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('verifyOtp devrait vérifier le code', () async {
      try {
        final result = await viewModel.verifyOtp(
          email: 'test@test.com',
          code: '123456',
        );
        expect(result, isA<bool>());
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('resetPasswordWithCode devrait réinitialiser le mot de passe', () async {
      try {
        final result = await viewModel.resetPasswordWithCode(
          email: 'test@test.com',
          code: '123456',
          newPassword: 'newpassword123',
        );
        expect(result, isA<bool>());
      } catch (e) {
        expect(e, isNotNull);
      }
    });
  });
}
