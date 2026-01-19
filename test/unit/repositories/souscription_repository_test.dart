import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/souscription_repository.dart';
import 'package:saarciflex_app/data/services/souscription_service.dart';
import 'package:saarciflex_app/data/models/souscription_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';

// Mock
class MocksouscriptionService extends Mock implements souscriptionService {}

void main() {
  group('SouscriptionRepository', () {
    late SouscriptionRepository repository;
    late MocksouscriptionService mocksouscriptionService;

    setUp(() {
      mocksouscriptionService = MocksouscriptionService();
      repository = SouscriptionRepository(service: mocksouscriptionService);
    });

    group('souscrire', () {
      test('appelle souscriptionService.souscrire avec la bonne requête', () async {
        // Arrange
        final request = SouscriptionRequest(
          devisId: 'devis-123',
          methodePaiement: 'wave',
          beneficiaires: [],
        );
        final expectedResponse = SouscriptionResponse(
          id: 'souscription-1',
          statut: 'en_attente',
          message: 'Souscription créée avec succès',
          createdAt: DateTime.now(),
        );

        when(mocksouscriptionService.souscrire(request))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.souscrire(request);

        // Assert
        expect(result, equals(expectedResponse));
        expect(result.id, 'souscription-1');
        verify(mocksouscriptionService.souscrire(request)).called(1);
      });

      test('propage les erreurs de souscriptionService', () async {
        // Arrange
        final request = SouscriptionRequest(
          devisId: 'invalid-devis',
          methodePaiement: 'wave',
          beneficiaires: [],
        );

        when(mocksouscriptionService.souscrire(request))
            .thenThrow(ApiException('Devis non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.souscrire(request),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getMesSouscriptions', () {
      test('appelle souscriptionService.getMesSouscriptions avec les bons paramètres', () async {
        // Arrange
        final expectedSouscriptions = [
          SouscriptionResponse(
            id: 'souscription-1',
            statut: 'en_attente',
            message: 'Souscription en attente',
            createdAt: DateTime.now(),
          ),
        ];

        when(mocksouscriptionService.getMesSouscriptions(page: 1, limit: 20))
            .thenAnswer((_) async => expectedSouscriptions);

        // Act
        final result = await repository.getMesSouscriptions();

        // Assert
        expect(result, equals(expectedSouscriptions));
        expect(result.length, 1);
        verify(mocksouscriptionService.getMesSouscriptions(page: 1, limit: 20))
            .called(1);
      });

      test('utilise les paramètres page et limit personnalisés', () async {
        // Arrange
        when(mocksouscriptionService.getMesSouscriptions(page: 2, limit: 10))
            .thenAnswer((_) async => <SouscriptionResponse>[]);

        // Act
        await repository.getMesSouscriptions(page: 2, limit: 10);

        // Assert
        verify(mocksouscriptionService.getMesSouscriptions(page: 2, limit: 10))
            .called(1);
      });

      test('propage les erreurs de souscriptionService', () async {
        // Arrange
        when(mocksouscriptionService.getMesSouscriptions(page: 1, limit: 20))
            .thenThrow(ApiException('Erreur serveur', 500));

        // Act & Assert
        expect(
          () => repository.getMesSouscriptions(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getSouscriptionById', () {
      test('appelle souscriptionService.getSouscriptionById avec le bon id', () async {
        // Arrange
        final expectedSouscription = SouscriptionResponse(
          id: 'souscription-1',
          statut: 'valide',
          message: 'Souscription validée',
          createdAt: DateTime.now(),
          numeroContrat: 'CONTRACT-001',
        );

        when(mocksouscriptionService.getSouscriptionById('souscription-1'))
            .thenAnswer((_) async => expectedSouscription);

        // Act
        final result = await repository.getSouscriptionById('souscription-1');

        // Assert
        expect(result, equals(expectedSouscription));
        expect(result.id, 'souscription-1');
        expect(result.numeroContrat, 'CONTRACT-001');
        verify(mocksouscriptionService.getSouscriptionById('souscription-1'))
            .called(1);
      });

      test('propage les erreurs de souscriptionService', () async {
        // Arrange
        when(mocksouscriptionService.getSouscriptionById('invalid-id'))
            .thenThrow(ApiException('Souscription non trouvée', 404));

        // Act & Assert
        expect(
          () => repository.getSouscriptionById('invalid-id'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('annulerSouscription', () {
      test('appelle souscriptionService.annulerSouscription avec le bon id', () async {
        // Arrange
        when(mocksouscriptionService.annulerSouscription('souscription-1'))
            .thenAnswer((_) async => {});

        // Act
        await repository.annulerSouscription('souscription-1');

        // Assert
        verify(mocksouscriptionService.annulerSouscription('souscription-1'))
            .called(1);
      });

      test('propage les erreurs de souscriptionService', () async {
        // Arrange
        when(mocksouscriptionService.annulerSouscription('invalid-id'))
            .thenThrow(ApiException('Souscription non trouvée', 404));

        // Act & Assert
        expect(
          () => repository.annulerSouscription('invalid-id'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('validateSouscriptionData', () {
      test('appelle souscriptionService.validatesouscriptionData', () {
        // Arrange
        final request = SouscriptionRequest(
          devisId: 'devis-123',
          methodePaiement: 'wave',
          beneficiaires: [],
        );

        when(mocksouscriptionService.validatesouscriptionData(request))
            .thenReturn(true);

        // Act
        final result = repository.validateSouscriptionData(request);

        // Assert
        expect(result, true);
        verify(mocksouscriptionService.validatesouscriptionData(request))
            .called(1);
      });

      test('retourne false si données invalides', () {
        // Arrange
        final request = SouscriptionRequest(
          devisId: '',
          methodePaiement: 'wave',
          beneficiaires: [],
        );

        when(mocksouscriptionService.validatesouscriptionData(request))
            .thenReturn(false);

        // Act
        final result = repository.validateSouscriptionData(request);

        // Assert
        expect(result, false);
      });
    });

    group('formatPhoneNumber', () {
      test('appelle souscriptionService.formatPhoneNumber', () {
        // Arrange
        when(mocksouscriptionService.formatPhoneNumber('0123456789'))
            .thenReturn('+221123456789');

        // Act
        final result = repository.formatPhoneNumber('0123456789');

        // Assert
        expect(result, '+221123456789');
        verify(mocksouscriptionService.formatPhoneNumber('0123456789'))
            .called(1);
      });

      test('formate différents formats de numéro', () {
        // Arrange
        when(mocksouscriptionService.formatPhoneNumber('123456789'))
            .thenReturn('+221123456789');

        // Act
        final result = repository.formatPhoneNumber('123456789');

        // Assert
        expect(result, '+221123456789');
      });
    });
  });
}
