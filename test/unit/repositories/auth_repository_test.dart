import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/auth_repository.dart';
import 'package:saarciflex_app/data/services/api_service.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import '../../mocks/mocks.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepository repository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      repository = AuthRepository(authService: mockAuthService);
    });

    group('login', () {
      test('appelle AuthService.login avec les bons paramètres', () async {
        final expectedUser = User(
          id: '1',
          nom: 'Test User',
          email: 'test@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );
        final expectedResponse = AuthResponse(
          user: expectedUser,
          token: 'test-token',
        );

        when(mockAuthService.login(
          email: 'test@test.com',
          password: 'password123',
        )).thenAnswer((_) async => expectedResponse);

        final result = await repository.login(
          email: 'test@test.com',
          password: 'password123',
        );

        expect(result, equals(expectedResponse));
        expect(result.user.email, 'test@test.com');
        expect(result.token, 'test-token');
        verify(mockAuthService.login(
          email: 'test@test.com',
          password: 'password123',
        )).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        when(mockAuthService.login(
          email: 'test@test.com',
          password: 'wrongpassword',
        )).thenThrow(ApiException('Mot de passe incorrect', 401));

        expect(
          () => repository.login(
            email: 'test@test.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('signup', () {
      test('appelle AuthService.signup avec les bons paramètres', () async {
        final expectedUser = User(
          id: '1',
          nom: 'New User',
          email: 'new@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );
        final expectedResponse = AuthResponse(
          user: expectedUser,
          token: 'new-token',
        );

        when(mockAuthService.signup(
          nom: 'New User',
          email: 'new@test.com',
          password: 'password123',
        )).thenAnswer((_) async => expectedResponse);

        final result = await repository.signup(
          nom: 'New User',
          email: 'new@test.com',
          password: 'password123',
        );

        expect(result, equals(expectedResponse));
        expect(result.user.nom, 'New User');
        expect(result.user.email, 'new@test.com');
        verify(mockAuthService.signup(
          nom: 'New User',
          email: 'new@test.com',
          password: 'password123',
        )).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        when(mockAuthService.signup(
          nom: 'New User',
          email: 'existing@test.com',
          password: 'password123',
        )).thenThrow(
          ApiException('Un compte avec cet email existe déjà', 409),
        );

        expect(
          () => repository.signup(
            nom: 'New User',
            email: 'existing@test.com',
            password: 'password123',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('logout', () {
      test('appelle AuthService.logout', () async {
        when(mockAuthService.logout()).thenAnswer((_) async => {});

        await repository.logout();

        verify(mockAuthService.logout()).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        when(mockAuthService.logout())
            .thenThrow(ApiException('Erreur de déconnexion', 500));

        expect(
          () => repository.logout(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('isLoggedIn', () {
      test('retourne true si AuthService.isLoggedIn retourne true', () async {
        when(mockAuthService.isLoggedIn()).thenAnswer((_) async => true);

        final result = await repository.isLoggedIn();

        expect(result, true);
        verify(mockAuthService.isLoggedIn()).called(1);
      });

      test('retourne false si AuthService.isLoggedIn retourne false', () async {
        when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);

        final result = await repository.isLoggedIn();

        expect(result, false);
        verify(mockAuthService.isLoggedIn()).called(1);
      });

      test('retourne false en cas d\'erreur', () async {
        when(mockAuthService.isLoggedIn())
            .thenThrow(Exception('Erreur de connexion'));

        final result = await repository.isLoggedIn();

        expect(result, false);
      });
    });

    group('forgotPassword', () {
      test('appelle AuthService.forgotPassword avec le bon email', () async {
        when(mockAuthService.forgotPassword('test@test.com'))
            .thenAnswer((_) async => {});

        await repository.forgotPassword('test@test.com');

        verify(mockAuthService.forgotPassword('test@test.com')).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        when(mockAuthService.forgotPassword('invalid@test.com'))
            .thenThrow(ApiException('Email non trouvé', 404));

        expect(
          () => repository.forgotPassword('invalid@test.com'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('verifyOtp', () {
      test('appelle AuthService.verifyOtp avec les bons paramètres', () async {
        when(mockAuthService.verifyOtp(
          email: 'test@test.com',
          code: '123456',
        )).thenAnswer((_) async => {});

        await repository.verifyOtp(
          email: 'test@test.com',
          code: '123456',
        );

        verify(mockAuthService.verifyOtp(
          email: 'test@test.com',
          code: '123456',
        )).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        when(mockAuthService.verifyOtp(
          email: 'test@test.com',
          code: 'wrongcode',
        )).thenThrow(ApiException('Code OTP invalide', 400));

        expect(
          () => repository.verifyOtp(
            email: 'test@test.com',
            code: 'wrongcode',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('resetPasswordWithCode', () {
      test(
        'appelle AuthService.resetPasswordWithCode avec les bons paramètres',
        () async {
          when(
            mockAuthService.resetPasswordWithCode(
              email: 'test@test.com',
              code: '123456',
              newPassword: 'newpassword123',
            ),
          ).thenAnswer((_) async => {});

          await repository.resetPasswordWithCode(
            email: 'test@test.com',
            code: '123456',
            newPassword: 'newpassword123',
          );

          verify(
            mockAuthService.resetPasswordWithCode(
              email: 'test@test.com',
              code: '123456',
              newPassword: 'newpassword123',
            ),
          ).called(1);
        },
      );

      test('propage les erreurs de AuthService', () async {
        when(
          mockAuthService.resetPasswordWithCode(
            email: 'test@test.com',
            code: 'wrongcode',
            newPassword: 'newpassword123',
          ),
        ).thenThrow(ApiException('Code OTP invalide', 400));

        expect(
          () => repository.resetPasswordWithCode(
            email: 'test@test.com',
            code: 'wrongcode',
            newPassword: 'newpassword123',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('checkTokenValidity', () {
      test(
        'retourne true si AuthService.checkTokenValidity retourne true',
        () async {
          when(mockAuthService.checkTokenValidity())
              .thenAnswer((_) async => true);

          final result = await repository.checkTokenValidity();

          expect(result, true);
          verify(mockAuthService.checkTokenValidity()).called(1);
        },
      );

      test('retourne false en cas d\'erreur', () async {
        when(mockAuthService.checkTokenValidity())
            .thenThrow(Exception('Erreur'));

        final result = await repository.checkTokenValidity();

        expect(result, false);
      });
    });

    group('initializeAuth', () {
      test(
        'retourne true si AuthService.initializeAuth retourne true',
        () async {
          when(mockAuthService.initializeAuth())
              .thenAnswer((_) async => true);

          final result = await repository.initializeAuth();

          expect(result, true);
          verify(mockAuthService.initializeAuth()).called(1);
        },
      );

      test('retourne false en cas d\'erreur', () async {
        when(mockAuthService.initializeAuth())
            .thenThrow(Exception('Erreur'));

        final result = await repository.initializeAuth();

        expect(result, false);
      });
    });
  });
}