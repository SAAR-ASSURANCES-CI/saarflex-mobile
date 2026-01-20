import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/simulation_repository.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';
import '../../mocks/mocks.dart';

void main() {
  group('SimulationRepository', () {
    late SimulationRepository repository;
    late MockSimulationService mockSimulationService;
    late MockFileUploadService mockFileUploadService;

    setUp(() {
      mockSimulationService = MockSimulationService();
      mockFileUploadService = MockFileUploadService();
      repository = SimulationRepository(
        simulationService: mockSimulationService,
        fileUploadService: mockFileUploadService,
      );
    });

    group('getCriteresProduit', () {
      test('appelle SimulationService.getCriteresProduit avec les bons paramètres', () async {
        final expectedCriteres = [
          CritereTarification(
            id: '1',
            produitId: 'prod1',
            nom: 'capital',
            type: TypeCritere.numerique,
            ordre: 1,
            obligatoire: true,
            valeurs: [],
          ),
        ];

        when(mockSimulationService.getCriteresProduit(
          'prod1',
          page: 1,
          limit: 100,
        )).thenAnswer((_) async => expectedCriteres);

        final result = await repository.getCriteresProduit('prod1');

        expect(result, equals(expectedCriteres));
        expect(result.length, 1);
        verify(mockSimulationService.getCriteresProduit(
          'prod1',
          page: 1,
          limit: 100,
        )).called(1);
      });

      test('utilise les paramètres page et limit personnalisés', () async {
        when(mockSimulationService.getCriteresProduit(
          'prod1',
          page: 2,
          limit: 50,
        )).thenAnswer((_) async => []);

        await repository.getCriteresProduit('prod1', page: 2, limit: 50);

        verify(mockSimulationService.getCriteresProduit(
          'prod1',
          page: 2,
          limit: 50,
        )).called(1);
      });

      test('propage les erreurs de SimulationService', () async {
        when(mockSimulationService.getCriteresProduit(
          'invalid-prod',
          page: 1,
          limit: 100,
        )).thenThrow(ApiException('Produit non trouvé', 404));

        expect(
          () => repository.getCriteresProduit('invalid-prod'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('simulerDevisSimplifie', () {
      test('appelle SimulationService.simulerDevisSimplifie avec les bons paramètres', () async {
        final criteres = {'capital': 1000000, 'duree': 12};
        final expectedResponse = SimulationResponse(
          id: 'devis-123',
          nomProduit: 'Test Product',
          typeProduit: 'vie',
          periodicitePrime: 'mensuelle',
          criteresUtilisateur: criteres,
          primeCalculee: 50000,
          assureEstSouscripteur: true,
          beneficiaires: [],
          createdAt: DateTime.now(),
        );

        when(mockSimulationService.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: criteres,
          assureEstSouscripteur: true,
          informationsAssure: null,
          informationsVehicule: null,
        )).thenAnswer((_) async => expectedResponse);

        final result = await repository.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: criteres,
          assureEstSouscripteur: true,
        );

        expect(result, equals(expectedResponse));
        expect(result.id, 'devis-123');
        verify(mockSimulationService.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: criteres,
          assureEstSouscripteur: true,
          informationsAssure: null,
          informationsVehicule: null,
        )).called(1);
      });

      test('passe les informationsAssure et informationsVehicule si fournies', () async {
        final criteres = {'capital': 1000000};
        final infosAssure = {'nom': 'Test User'};
        final infosVehicule = {'marque': 'Toyota'};
        final expectedResponse = SimulationResponse(
          id: 'devis-123',
          nomProduit: 'Test Product',
          typeProduit: 'vie',
          periodicitePrime: 'mensuelle',
          criteresUtilisateur: criteres,
          primeCalculee: 50000,
          assureEstSouscripteur: false,
          informationsAssure: infosAssure,
          beneficiaires: [],
          createdAt: DateTime.now(),
        );

        when(mockSimulationService.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: criteres,
          assureEstSouscripteur: false,
          informationsAssure: infosAssure,
          informationsVehicule: infosVehicule,
        )).thenAnswer((_) async => expectedResponse);

        await repository.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: criteres,
          assureEstSouscripteur: false,
          informationsAssure: infosAssure,
          informationsVehicule: infosVehicule,
        );

        verify(mockSimulationService.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: criteres,
          assureEstSouscripteur: false,
          informationsAssure: infosAssure,
          informationsVehicule: infosVehicule,
        )).called(1);
      });

      test('propage les erreurs de SimulationService', () async {
        when(mockSimulationService.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: {},
          assureEstSouscripteur: true,
          informationsAssure: null,
          informationsVehicule: null,
        )).thenThrow(ApiException('Critères invalides', 400));

        expect(
          () => repository.simulerDevisSimplifie(
            produitId: 'prod1',
            criteres: {},
            assureEstSouscripteur: true,
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('sauvegarderDevis', () {
      test('appelle SimulationService.sauvegarderDevis avec la bonne requête', () async {
        final request = SauvegardeDevisRequest(
          devisId: 'devis-123',
          nomPersonnalise: 'Mon Devis',
        );

        when(mockSimulationService.sauvegarderDevis(request))
            .thenAnswer((_) async => {});

        await repository.sauvegarderDevis(request);

        verify(mockSimulationService.sauvegarderDevis(request)).called(1);
      });

      test('propage les erreurs de SimulationService', () async {
        final request = SauvegardeDevisRequest(devisId: 'invalid-devis');

        when(mockSimulationService.sauvegarderDevis(request))
            .thenThrow(ApiException('Devis non trouvé', 404));

        expect(
          () => repository.sauvegarderDevis(request),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getGrilleTarifaireForProduit', () {
      test('appelle SimulationService.getGrilleTarifaireForProduit', () async {
        when(mockSimulationService.getGrilleTarifaireForProduit('prod1'))
            .thenAnswer((_) async => 'grille-123');

        final result = await repository.getGrilleTarifaireForProduit('prod1');

        expect(result, 'grille-123');
        verify(mockSimulationService.getGrilleTarifaireForProduit('prod1'))
            .called(1);
      });

      test('retourne null si SimulationService retourne null', () async {
        when(mockSimulationService.getGrilleTarifaireForProduit('prod1'))
            .thenAnswer((_) async => null);

        final result = await repository.getGrilleTarifaireForProduit('prod1');

        expect(result, isNull);
      });

      test('propage les erreurs de SimulationService', () async {
        when(mockSimulationService.getGrilleTarifaireForProduit('invalid-prod'))
            .thenThrow(ApiException('Produit non trouvé', 404));

        expect(
          () => repository.getGrilleTarifaireForProduit('invalid-prod'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getMesDevis', () {
      test('appelle SimulationService.getMesDevis avec les bons paramètres', () async {
        final expectedDevis = [
          SimulationResponse(
            id: 'devis-1',
            nomProduit: 'Test Product',
            typeProduit: 'vie',
            periodicitePrime: 'mensuelle',
            criteresUtilisateur: {},
            primeCalculee: 50000,
            assureEstSouscripteur: true,
            beneficiaires: [],
            createdAt: DateTime.now(),
          ),
        ];

        when(mockSimulationService.getMesDevis(page: 1, limit: 10))
            .thenAnswer((_) async => expectedDevis);

        final result = await repository.getMesDevis();

        expect(result, equals(expectedDevis));
        expect(result.length, 1);
        verify(mockSimulationService.getMesDevis(page: 1, limit: 10)).called(1);
      });

      test('utilise les paramètres page et limit personnalisés', () async {
        when(mockSimulationService.getMesDevis(page: 2, limit: 20))
            .thenAnswer((_) async => []);

        await repository.getMesDevis(page: 2, limit: 20);

        verify(mockSimulationService.getMesDevis(page: 2, limit: 20)).called(1);
      });
    });

    group('supprimerDevis', () {
      test('appelle SimulationService.supprimerDevis avec le bon devisId', () async {
        when(mockSimulationService.supprimerDevis('devis-123'))
            .thenAnswer((_) async => {});

        await repository.supprimerDevis('devis-123');

        verify(mockSimulationService.supprimerDevis('devis-123')).called(1);
      });

      test('propage les erreurs de SimulationService', () async {
        when(mockSimulationService.supprimerDevis('invalid-devis'))
            .thenThrow(ApiException('Devis non trouvé', 404));

        expect(
          () => repository.supprimerDevis('invalid-devis'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('Méthodes de validation et formatage', () {
      test('critereNecessiteFormatage délègue à SimulationService', () {
        final critere = CritereTarification(
          id: '1',
          produitId: 'prod1',
          nom: 'capital',
          type: TypeCritere.numerique,
          ordre: 1,
          obligatoire: true,
          valeurs: [],
        );

        when(mockSimulationService.critereNecessiteFormatage(critere))
            .thenReturn(true);

        final result = repository.critereNecessiteFormatage(critere);

        expect(result, true);
        verify(mockSimulationService.critereNecessiteFormatage(critere))
            .called(1);
      });

      test('nettoyerCriteres délègue à SimulationService', () {
        final criteres = {'capital': '1 000 000'};
        final criteresProduit = [
          CritereTarification(
            id: '1',
            produitId: 'prod1',
            nom: 'capital',
            type: TypeCritere.numerique,
            ordre: 1,
            obligatoire: true,
            valeurs: [],
          ),
        ];
        final expectedNettoyes = {'capital': 1000000};

        when(mockSimulationService.nettoyerCriteres(criteres, criteresProduit))
            .thenReturn(expectedNettoyes);

        final result = repository.nettoyerCriteres(criteres, criteresProduit);

        expect(result, equals(expectedNettoyes));
        verify(mockSimulationService.nettoyerCriteres(criteres, criteresProduit))
            .called(1);
      });

      test('validateCritere délègue à SimulationService', () {
        final critere = CritereTarification(
          id: '1',
          produitId: 'prod1',
          nom: 'capital',
          type: TypeCritere.numerique,
          ordre: 1,
          obligatoire: true,
          valeurs: [],
        );

        when(mockSimulationService.validateCritere(critere, 1000000))
            .thenReturn(null);

        final result = repository.validateCritere(critere, 1000000);

        expect(result, isNull);
        verify(mockSimulationService.validateCritere(critere, 1000000))
            .called(1);
      });

      test('validateAllCriteres délègue à SimulationService', () {
        final criteresReponses = {'capital': 1000000};
        final criteresProduit = [
          CritereTarification(
            id: '1',
            produitId: 'prod1',
            nom: 'capital',
            type: TypeCritere.numerique,
            ordre: 1,
            obligatoire: true,
            valeurs: [],
          ),
        ];
        final expectedErrors = <String, String>{};

        when(mockSimulationService.validateAllCriteres(
          criteresReponses,
          criteresProduit,
        )).thenReturn(expectedErrors);

        final result = repository.validateAllCriteres(
          criteresReponses,
          criteresProduit,
        );

        expect(result, equals(expectedErrors));
        verify(mockSimulationService.validateAllCriteres(
          criteresReponses,
          criteresProduit,
        )).called(1);
      });

      test('isSaarNansou délègue à SimulationService', () {
        when(mockSimulationService.isSaarNansou('prod-saar-nansou'))
            .thenReturn(true);

        final result = repository.isSaarNansou('prod-saar-nansou');

        expect(result, true);
        verify(mockSimulationService.isSaarNansou('prod-saar-nansou'))
            .called(1);
      });

      test('calculerDureeAuto délègue à SimulationService', () async {
        when(mockSimulationService.calculerDureeAuto(25))
            .thenAnswer((_) async => 10);

        final result = await repository.calculerDureeAuto(25);

        expect(result, 10);
        verify(mockSimulationService.calculerDureeAuto(25)).called(1);
      });

      test('calculerAge délègue à SimulationService', () {
        final birthDate = DateTime(1990, 1, 1);
        final expectedAge = DateTime.now().year - 1990;

        when(mockSimulationService.calculerAge(birthDate))
            .thenReturn(expectedAge);

        final result = repository.calculerAge(birthDate);

        expect(result, expectedAge);
        verify(mockSimulationService.calculerAge(birthDate)).called(1);
      });
    });
  });
}
