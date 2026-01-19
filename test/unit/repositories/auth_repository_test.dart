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
        // Arrange
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

        // Act
        final result = await repository.login(
          email: 'test@test.com',
          password: 'password123',
        );

        // Assert
        expect(result, equals(expectedResponse));
        expect(result.user.email, 'test@test.com');
        expect(result.token, 'test-token');
        verify(mockAuthService.login(
          email: 'test@test.com',
          password: 'password123',
        )).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        // Arrange
        when(mockAuthService.login(
          email: 'test@test.com',
          password: 'wrongpassword',
        )).thenThrow(ApiException('Mot de passe incorrect', 401));

        // Act & Assert
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
        // Arrange
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

        // Act
        final result = await repository.signup(
          nom: 'New User',
          email: 'new@test.com',
          password: 'password123',
        );

        // Assert
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
        // Arrange
        when(mockAuthService.signup(
          nom: 'New User',
          email: 'existing@test.com',
          password: 'password123',
        )).thenThrow(ApiException('Un compte avec cet email existe déjà', 409));

        // Act & Assert
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
        // Arrange
        when(mockAuthService.logout()).thenAnswer((_) async => {});

        // Act
        await repository.logout();

        // Assert
        verify(mockAuthService.logout()).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        // Arrange
        when(mockAuthService.logout())
            .thenThrow(ApiException('Erreur de déconnexion', 500));

        // Act & Assert
        expect(
          () => repository.logout(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('isLoggedIn', () {
      test('retourne true si AuthService.isLoggedIn retourne true', () async {
        // Arrange
        when(mockAuthService.isLoggedIn()).thenAnswer((_) async => true);

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, true);
        verify(mockAuthService.isLoggedIn()).called(1);
      });

      test('retourne false si AuthService.isLoggedIn retourne false', () async {
        // Arrange
        when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, false);
        verify(mockAuthService.isLoggedIn()).called(1);
      });

      test('retourne false en cas d\'erreur', () async {
        // Arrange
        when(mockAuthService.isLoggedIn())
            .thenThrow(Exception('Erreur de connexion'));

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, false);
      });
    });

    group('forgotPassword', () {
      test('appelle AuthService.forgotPassword avec le bon email', () async {
        // Arrange
        when(mockAuthService.forgotPassword('test@test.com'))
            .thenAnswer((_) async => {});

        // Act
        await repository.forgotPassword('test@test.com');

        // Assert
        verify(mockAuthService.forgotPassword('test@test.com')).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        // Arrange
        when(mockAuthService.forgotPassword('invalid@test.com'))
            .thenThrow(ApiException('Email non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.forgotPassword('invalid@test.com'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('verifyOtp', () {
      test('appelle AuthService.verifyOtp avec les bons paramètres', () async {
        // Arrange
        when(mockAuthService.verifyOtp(
          email: 'test@test.com',
          code: '123456',
        )).thenAnswer((_) async => {});

        // Act
        await repository.verifyOtp(
          email: 'test@test.com',
          code: '123456',
        );

        // Assert
        verify(mockAuthService.verifyOtp(
          email: 'test@test.com',
          code: '123456',
        )).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        // Arrange
        when(mockAuthService.verifyOtp(
          email: 'test@test.com',
          code: 'wrongcode',
        )).thenThrow(ApiException('Code OTP invalide', 400));

        // Act & Assert
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
      test('appelle AuthService.resetPasswordWithCode avec les bons paramètres', () async {
        // Arrange
        when(mockAuthService.resetPasswordWithCode(
          email: 'test@test.com',
          code: '123456',
          newPassword: 'newpassword123',
        )).thenAnswer((_) async => {});

        // Act
        await repository.resetPasswordWithCode(
          email: 'test@test.com',
          code: '123456',
          newPassword: 'newpassword123',
        );

        // Assert
        verify(mockAuthService.resetPasswordWithCode(
          email: 'test@test.com',
          code: '123456',
          newPassword: 'newpassword123',
        )).called(1);
      });

      test('propage les erreurs de AuthService', () async {
        // Arrange
        when(mockAuthService.resetPasswordWithCode(
          email: 'test@test.com',
          code: 'wrongcode',
          newPassword: 'newpassword123',
        )).thenThrow(ApiException('Code OTP invalide', 400));

        // Act & Assert
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
      test('retourne true si AuthService.checkTokenValidity retourne true', () async {
        // Arrange
        when(mockAuthService.checkTokenValidity())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.checkTokenValidity();

        // Assert
        expect(result, true);
        verify(mockAuthService.checkTokenValidity()).called(1);
      });

      test('retourne false en cas d\'erreur', () async {
        // Arrange
        when(mockAuthService.checkTokenValidity())
            .thenThrow(Exception('Erreur'));

        // Act
        final result = await repository.checkTokenValidity();

        // Assert
        expect(result, false);
      });
    });

    group('initializeAuth', () {
      test('retourne true si AuthService.initializeAuth retourne true', () async {
        // Arrange
        when(mockAuthService.initializeAuth())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.initializeAuth();

        // Assert
        expect(result, true);
        verify(mockAuthService.initializeAuth()).called(1);
      });

      test('retourne false en cas d\'erreur', () async {
        // Arrange
        when(mockAuthService.initializeAuth())
            .thenThrow(Exception('Erreur'));

        // Act
        final result = await repository.initializeAuth();

        // Assert
        expect(result, false);
      });
    });
  });
}
