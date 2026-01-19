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
        // Arrange
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

        // Act
        final result = await repository.getCriteresProduit('prod1');

        // Assert
        expect(result, equals(expectedCriteres));
        expect(result.length, 1);
        verify(mockSimulationService.getCriteresProduit(
          'prod1',
          page: 1,
          limit: 100,
        )).called(1);
      });

      test('utilise les paramètres page et limit personnalisés', () async {
        // Arrange
        when(mockSimulationService.getCriteresProduit(
          'prod1',
          page: 2,
          limit: 50,
        )).thenAnswer((_) async => []);

        // Act
        await repository.getCriteresProduit('prod1', page: 2, limit: 50);

        // Assert
        verify(mockSimulationService.getCriteresProduit(
          'prod1',
          page: 2,
          limit: 50,
        )).called(1);
      });

      test('propage les erreurs de SimulationService', () async {
        // Arrange
        when(mockSimulationService.getCriteresProduit(
          'invalid-prod',
          page: 1,
          limit: 100,
        )).thenThrow(ApiException('Produit non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.getCriteresProduit('invalid-prod'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('simulerDevisSimplifie', () {
      test('appelle SimulationService.simulerDevisSimplifie avec les bons paramètres', () async {
        // Arrange
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

        // Act
        final result = await repository.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: criteres,
          assureEstSouscripteur: true,
        );

        // Assert
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
        // Arrange
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

        // Act
        await repository.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: criteres,
          assureEstSouscripteur: false,
          informationsAssure: infosAssure,
          informationsVehicule: infosVehicule,
        );

        // Assert
        verify(mockSimulationService.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: criteres,
          assureEstSouscripteur: false,
          informationsAssure: infosAssure,
          informationsVehicule: infosVehicule,
        )).called(1);
      });

      test('propage les erreurs de SimulationService', () async {
        // Arrange
        when(mockSimulationService.simulerDevisSimplifie(
          produitId: 'prod1',
          criteres: {},
          assureEstSouscripteur: true,
          informationsAssure: null,
          informationsVehicule: null,
        )).thenThrow(ApiException('Critères invalides', 400));

        // Act & Assert
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
        // Arrange
        final request = SauvegardeDevisRequest(
          devisId: 'devis-123',
          nomPersonnalise: 'Mon Devis',
        );

        when(mockSimulationService.sauvegarderDevis(request))
            .thenAnswer((_) async => {});

        // Act
        await repository.sauvegarderDevis(request);

        // Assert
        verify(mockSimulationService.sauvegarderDevis(request)).called(1);
      });

      test('propage les erreurs de SimulationService', () async {
        // Arrange
        final request = SauvegardeDevisRequest(devisId: 'invalid-devis');

        when(mockSimulationService.sauvegarderDevis(request))
            .thenThrow(ApiException('Devis non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.sauvegarderDevis(request),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getGrilleTarifaireForProduit', () {
      test('appelle SimulationService.getGrilleTarifaireForProduit', () async {
        // Arrange
        when(mockSimulationService.getGrilleTarifaireForProduit('prod1'))
            .thenAnswer((_) async => 'grille-123');

        // Act
        final result = await repository.getGrilleTarifaireForProduit('prod1');

        // Assert
        expect(result, 'grille-123');
        verify(mockSimulationService.getGrilleTarifaireForProduit('prod1'))
            .called(1);
      });

      test('retourne null si SimulationService retourne null', () async {
        // Arrange
        when(mockSimulationService.getGrilleTarifaireForProduit('prod1'))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getGrilleTarifaireForProduit('prod1');

        // Assert
        expect(result, isNull);
      });

      test('propage les erreurs de SimulationService', () async {
        // Arrange
        when(mockSimulationService.getGrilleTarifaireForProduit('invalid-prod'))
            .thenThrow(ApiException('Produit non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.getGrilleTarifaireForProduit('invalid-prod'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getMesDevis', () {
      test('appelle SimulationService.getMesDevis avec les bons paramètres', () async {
        // Arrange
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

        // Act
        final result = await repository.getMesDevis();

        // Assert
        expect(result, equals(expectedDevis));
        expect(result.length, 1);
        verify(mockSimulationService.getMesDevis(page: 1, limit: 10)).called(1);
      });

      test('utilise les paramètres page et limit personnalisés', () async {
        // Arrange
        when(mockSimulationService.getMesDevis(page: 2, limit: 20))
            .thenAnswer((_) async => []);

        // Act
        await repository.getMesDevis(page: 2, limit: 20);

        // Assert
        verify(mockSimulationService.getMesDevis(page: 2, limit: 20)).called(1);
      });
    });

    group('supprimerDevis', () {
      test('appelle SimulationService.supprimerDevis avec le bon devisId', () async {
        // Arrange
        when(mockSimulationService.supprimerDevis('devis-123'))
            .thenAnswer((_) async => {});

        // Act
        await repository.supprimerDevis('devis-123');

        // Assert
        verify(mockSimulationService.supprimerDevis('devis-123')).called(1);
      });

      test('propage les erreurs de SimulationService', () async {
        // Arrange
        when(mockSimulationService.supprimerDevis('invalid-devis'))
            .thenThrow(ApiException('Devis non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.supprimerDevis('invalid-devis'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('Méthodes de validation et formatage', () {
      test('critereNecessiteFormatage délègue à SimulationService', () {
        // Arrange
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

        // Act
        final result = repository.critereNecessiteFormatage(critere);

        // Assert
        expect(result, true);
        verify(mockSimulationService.critereNecessiteFormatage(critere))
            .called(1);
      });

      test('nettoyerCriteres délègue à SimulationService', () {
        // Arrange
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

        // Act
        final result = repository.nettoyerCriteres(criteres, criteresProduit);

        // Assert
        expect(result, equals(expectedNettoyes));
        verify(mockSimulationService.nettoyerCriteres(criteres, criteresProduit))
            .called(1);
      });

      test('validateCritere délègue à SimulationService', () {
        // Arrange
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

        // Act
        final result = repository.validateCritere(critere, 1000000);

        // Assert
        expect(result, isNull);
        verify(mockSimulationService.validateCritere(critere, 1000000))
            .called(1);
      });

      test('validateAllCriteres délègue à SimulationService', () {
        // Arrange
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

        // Act
        final result = repository.validateAllCriteres(
          criteresReponses,
          criteresProduit,
        );

        // Assert
        expect(result, equals(expectedErrors));
        verify(mockSimulationService.validateAllCriteres(
          criteresReponses,
          criteresProduit,
        )).called(1);
      });

      test('isSaarNansou délègue à SimulationService', () {
        // Arrange
        when(mockSimulationService.isSaarNansou('prod-saar-nansou'))
            .thenReturn(true);

        // Act
        final result = repository.isSaarNansou('prod-saar-nansou');

        // Assert
        expect(result, true);
        verify(mockSimulationService.isSaarNansou('prod-saar-nansou'))
            .called(1);
      });

      test('calculerDureeAuto délègue à SimulationService', () async {
        // Arrange
        when(mockSimulationService.calculerDureeAuto(25))
            .thenAnswer((_) async => 10);

        // Act
        final result = await repository.calculerDureeAuto(25);

        // Assert
        expect(result, 10);
        verify(mockSimulationService.calculerDureeAuto(25)).called(1);
      });

      test('calculerAge délègue à SimulationService', () {
        // Arrange
        final birthDate = DateTime(1990, 1, 1);
        final expectedAge = DateTime.now().year - 1990;

        when(mockSimulationService.calculerAge(birthDate))
            .thenReturn(expectedAge);

        // Act
        final result = repository.calculerAge(birthDate);

        // Assert
        expect(result, expectedAge);
        verify(mockSimulationService.calculerAge(birthDate)).called(1);
      });
    });
  });
}
