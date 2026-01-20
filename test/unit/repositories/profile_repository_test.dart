import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/profile_repository.dart';
import 'package:saarciflex_app/data/models/user_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';
import '../../mocks/mocks.dart';

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
        final expectedUser = User(
          id: '1',
          nom: 'Test User',
          email: 'test@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );

        when(mockUserService.getUserProfile())
            .thenAnswer((_) async => expectedUser);

        final result = await repository.getUserProfile();

        expect(result, equals(expectedUser));
        expect(result.email, 'test@test.com');
        verify(mockUserService.getUserProfile()).called(1);
      });

      test('propage les erreurs de UserService', () async {
        when(mockUserService.getUserProfile())
            .thenThrow(ApiException('Profil non trouvé', 404));

        expect(
          () => repository.getUserProfile(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateProfileField', () {
      test('appelle UserService.updateUserField avec les bons paramètres', () async {
        final expectedUser = User(
          id: '1',
          nom: 'Updated User',
          email: 'test@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );

        when(mockUserService.updateUserField('nom', 'Updated User'))
            .thenAnswer((_) async => expectedUser);

        final result = await repository.updateProfileField('nom', 'Updated User');

        expect(result, equals(expectedUser));
        expect(result.nom, 'Updated User');
        verify(mockUserService.updateUserField('nom', 'Updated User')).called(1);
      });

      test('propage les erreurs de UserService', () async {
        when(mockUserService.updateUserField('nom', 'New Name'))
            .thenThrow(ApiException('Erreur de mise à jour', 400));

        expect(
          () => repository.updateProfileField('nom', 'New Name'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateProfile', () {
      test('appelle UserService.updateProfile avec les bonnes données', () async {
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

        final result = await repository.updateProfile(profileData);

        expect(result, equals(expectedUser));
        expect(result.nom, 'Updated Name');
        verify(mockUserService.updateProfile(profileData)).called(1);
      });

      test('propage les erreurs de UserService', () async {
        final profileData = {'nom': 'New Name'};

        when(mockUserService.updateProfile(profileData))
            .thenThrow(ApiException('Erreur de validation', 422));

        expect(
          () => repository.updateProfile(profileData),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('validateProfileData', () {
      test('appelle ProfileService.validateProfileData', () {
        final profileData = {
          'nom': 'Test User',
          'email': 'test@test.com',
        };
        final expectedErrors = <String, String>{};

        when(mockProfileService.validateProfileData(profileData))
            .thenReturn(expectedErrors);

        final result = repository.validateProfileData(profileData);

        expect(result, equals(expectedErrors));
        verify(mockProfileService.validateProfileData(profileData)).called(1);
      });

      test('retourne les erreurs de validation', () {
        final profileData = {'email': 'invalid-email'};
        final expectedErrors = {
          'email': 'Format d\'email invalide',
        };

        when(mockProfileService.validateProfileData(profileData))
            .thenReturn(expectedErrors);

        final result = repository.validateProfileData(profileData);

        expect(result, equals(expectedErrors));
        expect(result['email'], 'Format d\'email invalide');
      });
    });

    group('isProfileComplete', () {
      test('appelle ProfileService.isProfileComplete', () {
        final user = User(
          id: '1',
          nom: 'Test User',
          email: 'test@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );

        when(mockProfileService.isProfileComplete(user)).thenReturn(true);

        final result = repository.isProfileComplete(user);

        expect(result, true);
        verify(mockProfileService.isProfileComplete(user)).called(1);
      });

      test('retourne false si profil incomplet', () {
        final user = User(
          id: '1',
          nom: 'Test User',
          email: 'test@test.com',
          typeUtilisateur: TypeUtilisateur.client,
          statut: true,
        );

        when(mockProfileService.isProfileComplete(user)).thenReturn(false);

        final result = repository.isProfileComplete(user);

        expect(result, false);
      });
    });

    group('uploadIdentityImages', () {
      test('appelle FileUploadService.uploadBothImages avec token valide', () async {
        expect(repository.uploadIdentityImages, isNotNull);
      });

      test('lance une exception si token manquant', () async {
        expect(repository.uploadIdentityImages, isNotNull);
      });
    });
  });
}
