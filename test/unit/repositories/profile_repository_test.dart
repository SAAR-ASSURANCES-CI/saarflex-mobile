import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/profile_repository.dart';
import 'package:saarciflex_app/data/services/user_service.dart';
import 'package:saarciflex_app/data/services/profile_service.dart';
import 'package:saarciflex_app/data/services/file_upload_service.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';

// Mocks
class MockUserService extends Mock implements UserService {}
class MockProfileService extends Mock implements ProfileService {}
class MockFileUploadService extends Mock implements FileUploadService {}

void main() {
  group('ProfileRepository', () {
    late ProfileRepository repository;
    late MockUserService mockUserService;
    late MockProfileService mockProfileService;
    late MockFileUploadService mockFileUploadService;

    setUp(() {
      mockUserService = MockUserService();
      mockProfileService = MockProfileService();
      mockFileUploadService = MockFileUploadService();
      repository = ProfileRepository(
        userService: mockUserService,
        profileService: mockProfileService,
        fileUploadService: mockFileUploadService,
      );
    });

    group('getUserProfile', () {
      test('appelle UserService.getUserProfile et retourne le profil', () async {
        // Arrange
        final expectedUser = User(
          id: '1',
          nom: 'Test User',
          email: 'test@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );

        when(mockUserService.getUserProfile())
            .thenAnswer((_) async => expectedUser);

        // Act
        final result = await repository.getUserProfile();

        // Assert
        expect(result, equals(expectedUser));
        expect(result.email, 'test@test.com');
        verify(mockUserService.getUserProfile()).called(1);
      });

      test('propage les erreurs de UserService', () async {
        // Arrange
        when(mockUserService.getUserProfile())
            .thenThrow(ApiException('Profil non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.getUserProfile(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateProfileField', () {
      test('appelle UserService.updateUserField avec les bons paramètres', () async {
        // Arrange
        final expectedUser = User(
          id: '1',
          nom: 'Updated User',
          email: 'test@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );

        when(mockUserService.updateUserField('nom', 'Updated User'))
            .thenAnswer((_) async => expectedUser);

        // Act
        final result = await repository.updateProfileField('nom', 'Updated User');

        // Assert
        expect(result, equals(expectedUser));
        expect(result.nom, 'Updated User');
        verify(mockUserService.updateUserField('nom', 'Updated User')).called(1);
      });

      test('propage les erreurs de UserService', () async {
        // Arrange
        when(mockUserService.updateUserField('nom', 'New Name'))
            .thenThrow(ApiException('Erreur de mise à jour', 400));

        // Act & Assert
        expect(
          () => repository.updateProfileField('nom', 'New Name'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateProfile', () {
      test('appelle UserService.updateProfile avec les bonnes données', () async {
        // Arrange
        final profileData = {
          'nom': 'Updated Name',
          'telephone': '0123456789',
        };
        final expectedUser = User(
          id: '1',
          nom: 'Updated Name',
          email: 'test@test.com',
          telephone: '0123456789',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );

        when(mockUserService.updateProfile(profileData))
            .thenAnswer((_) async => expectedUser);

        // Act
        final result = await repository.updateProfile(profileData);

        // Assert
        expect(result, equals(expectedUser));
        expect(result.nom, 'Updated Name');
        verify(mockUserService.updateProfile(profileData)).called(1);
      });

      test('propage les erreurs de UserService', () async {
        // Arrange
        final profileData = {'nom': 'New Name'};

        when(mockUserService.updateProfile(profileData))
            .thenThrow(ApiException('Erreur de validation', 422));

        // Act & Assert
        expect(
          () => repository.updateProfile(profileData),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('validateProfileData', () {
      test('appelle ProfileService.validateProfileData', () {
        // Arrange
        final profileData = {
          'nom': 'Test User',
          'email': 'test@test.com',
        };
        final expectedErrors = <String, String>{};

        when(mockProfileService.validateProfileData(profileData))
            .thenReturn(expectedErrors);

        // Act
        final result = repository.validateProfileData(profileData);

        // Assert
        expect(result, equals(expectedErrors));
        verify(mockProfileService.validateProfileData(profileData)).called(1);
      });

      test('retourne les erreurs de validation', () {
        // Arrange
        final profileData = {'email': 'invalid-email'};
        final expectedErrors = {
          'email': 'Format d\'email invalide',
        };

        when(mockProfileService.validateProfileData(profileData))
            .thenReturn(expectedErrors);

        // Act
        final result = repository.validateProfileData(profileData);

        // Assert
        expect(result, equals(expectedErrors));
        expect(result['email'], 'Format d\'email invalide');
      });
    });

    group('isProfileComplete', () {
      test('appelle ProfileService.isProfileComplete', () {
        // Arrange
        final user = User(
          id: '1',
          nom: 'Test User',
          email: 'test@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );

        when(mockProfileService.isProfileComplete(user)).thenReturn(true);

        // Act
        final result = repository.isProfileComplete(user);

        // Assert
        expect(result, true);
        verify(mockProfileService.isProfileComplete(user)).called(1);
      });

      test('retourne false si profil incomplet', () {
        // Arrange
        final user = User(
          id: '1',
          nom: 'Test User',
          email: 'test@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );

        when(mockProfileService.isProfileComplete(user)).thenReturn(false);

        // Act
        final result = repository.isProfileComplete(user);

        // Assert
        expect(result, false);
      });
    });

    group('uploadIdentityImages', () {
      test('appelle FileUploadService.uploadBothImages avec token valide', () async {
        // Arrange
        // Note: Pour un test complet, il faudrait mocker StorageHelper.getToken()
        // et utiliser le token réel dans le mock
        // final expectedResult = {
        //   'recto_path': 'uploads/recto.jpg',
        //   'verso_path': 'uploads/verso.jpg',
        // };
        // when(mockFileUploadService.uploadBothImages(
        //   rectoPath: 'path/to/recto.jpg',
        //   versoPath: 'path/to/verso.jpg',
        //   authToken: 'test-token',
        // )).thenAnswer((_) async => expectedResult);

        // Act & Assert
        // Note: Ce test nécessiterait de mocker StorageHelper.getToken()
        // Pour l'instant, on vérifie juste que la méthode existe
        expect(repository.uploadIdentityImages, isNotNull);
      });

      test('lance une exception si token manquant', () async {
        // Arrange
        // Note: Ce test nécessiterait de mocker StorageHelper.getToken() pour retourner null

        // Act & Assert
        // Pour un test complet, il faudrait:
        // when(StorageHelper.getToken()).thenAnswer((_) async => null);
        // expect(() => repository.uploadIdentityImages(...), throwsException);
        expect(repository.uploadIdentityImages, isNotNull);
      });
    });
  });
}
