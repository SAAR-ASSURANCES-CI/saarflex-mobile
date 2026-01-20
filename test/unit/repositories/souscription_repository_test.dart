import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/souscription_repository.dart';
import 'package:saarciflex_app/data/models/souscription_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';
import '../../mocks/mocks.dart';

void main() {
  group('SouscriptionRepository', () {
    late SouscriptionRepository repository;
    late MockSouscriptionService mockSouscriptionService;

    setUp(() {
      mockSouscriptionService = MockSouscriptionService();
      repository = SouscriptionRepository(service: mockSouscriptionService);
    });

    group('souscrire', () {
      test('appelle souscriptionService.souscrire avec la bonne requête', () async {
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

        when(mockSouscriptionService.souscrire(request))
            .thenAnswer((_) async => expectedResponse);

        final result = await repository.souscrire(request);

        expect(result, equals(expectedResponse));
        expect(result.id, 'souscription-1');
        verify(mockSouscriptionService.souscrire(request)).called(1);
      });

      test('propage les erreurs de souscriptionService', () async {
        final request = SouscriptionRequest(
          devisId: 'invalid-devis',
          methodePaiement: 'wave',
          beneficiaires: [],
        );

        when(mockSouscriptionService.souscrire(request))
            .thenThrow(ApiException('Devis non trouvé', 404));

        expect(
          () => repository.souscrire(request),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getMesSouscriptions', () {
      test('appelle souscriptionService.getMesSouscriptions avec les bons paramètres', () async {
        final expectedSouscriptions = [
          SouscriptionResponse(
            id: 'souscription-1',
            statut: 'en_attente',
            message: 'Souscription en attente',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockSouscriptionService.getMesSouscriptions(page: 1, limit: 20))
            .thenAnswer((_) async => expectedSouscriptions);

        final result = await repository.getMesSouscriptions();

        expect(result, equals(expectedSouscriptions));
        expect(result.length, 1);
        verify(mockSouscriptionService.getMesSouscriptions(page: 1, limit: 20))
            .called(1);
      });

      test('utilise les paramètres page et limit personnalisés', () async {
        when(mockSouscriptionService.getMesSouscriptions(page: 2, limit: 10))
            .thenAnswer((_) async => <SouscriptionResponse>[]);

        await repository.getMesSouscriptions(page: 2, limit: 10);

        verify(mockSouscriptionService.getMesSouscriptions(page: 2, limit: 10))
            .called(1);
      });

      test('propage les erreurs de souscriptionService', () async {
        when(mockSouscriptionService.getMesSouscriptions(page: 1, limit: 20))
            .thenThrow(ApiException('Erreur serveur', 500));

        expect(
          () => repository.getMesSouscriptions(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getSouscriptionById', () {
      test('appelle souscriptionService.getSouscriptionById avec le bon id', () async {
        final expectedSouscription = SouscriptionResponse(
          id: 'souscription-1',
          statut: 'valide',
          message: 'Souscription validée',
          createdAt: DateTime.now(),
          numeroContrat: 'CONTRACT-001',
        );

        when(mockSouscriptionService.getSouscriptionById('souscription-1'))
            .thenAnswer((_) async => expectedSouscription);

        final result = await repository.getSouscriptionById('souscription-1');

        expect(result, equals(expectedSouscription));
        expect(result.id, 'souscription-1');
        expect(result.numeroContrat, 'CONTRACT-001');
        verify(mockSouscriptionService.getSouscriptionById('souscription-1'))
            .called(1);
      });

      test('propage les erreurs de souscriptionService', () async {
        when(mockSouscriptionService.getSouscriptionById('invalid-id'))
            .thenThrow(ApiException('Souscription non trouvée', 404));

        expect(
          () => repository.getSouscriptionById('invalid-id'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('annulerSouscription', () {
      test('appelle souscriptionService.annulerSouscription avec le bon id', () async {
        when(mockSouscriptionService.annulerSouscription('souscription-1'))
            .thenAnswer((_) async => {});

        await repository.annulerSouscription('souscription-1');

        verify(mockSouscriptionService.annulerSouscription('souscription-1'))
            .called(1);
      });

      test('propage les erreurs de souscriptionService', () async {
        when(mockSouscriptionService.annulerSouscription('invalid-id'))
            .thenThrow(ApiException('Souscription non trouvée', 404));

        expect(
          () => repository.annulerSouscription('invalid-id'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('validateSouscriptionData', () {
      test('appelle souscriptionService.validatesouscriptionData', () {
        final request = SouscriptionRequest(
          devisId: 'devis-123',
          methodePaiement: 'wave',
          beneficiaires: [],
        );

        when(mockSouscriptionService.validatesouscriptionData(request))
            .thenReturn(true);

        final result = repository.validateSouscriptionData(request);

        expect(result, true);
        verify(mockSouscriptionService.validatesouscriptionData(request))
            .called(1);
      });

      test('retourne false si données invalides', () {
        final request = SouscriptionRequest(
          devisId: '',
          methodePaiement: 'wave',
          beneficiaires: [],
        );

        when(mockSouscriptionService.validatesouscriptionData(request))
            .thenReturn(false);

        final result = repository.validateSouscriptionData(request);

        expect(result, false);
      });
    });

    group('formatPhoneNumber', () {
      test('appelle souscriptionService.formatPhoneNumber', () {
        when(mockSouscriptionService.formatPhoneNumber('0123456789'))
            .thenReturn('+221123456789');

        final result = repository.formatPhoneNumber('0123456789');

        expect(result, '+221123456789');
        verify(mockSouscriptionService.formatPhoneNumber('0123456789'))
            .called(1);
      });

      test('formate différents formats de numéro', () {
        when(mockSouscriptionService.formatPhoneNumber('123456789'))
            .thenReturn('+221123456789');

        final result = repository.formatPhoneNumber('123456789');

        expect(result, '+221123456789');
      });
    });
  });
}
