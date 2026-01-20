import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/contract_repository.dart';
import 'package:saarciflex_app/data/models/contract_model.dart';
import 'package:saarciflex_app/data/models/saved_quote_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';
import '../../mocks/mocks.dart';

void main() {
  group('ContractRepository', () {
    late ContractRepository repository;
    late MockContractService mockContractService;

    setUp(() {
      mockContractService = MockContractService();
      repository = ContractRepository(contractService: mockContractService);
    });

    group('getSavedQuotes', () {
      test('appelle ContractService.getSavedQuotes avec les bons paramètres',
          () async {
        final expectedQuotes = [
          SavedQuote(
            id: '1',
            nomProduit: 'Product 1',
            typeProduit: 'vie',
            primeCalculee: 50000,
            franchiseCalculee: 10000,
            statut: 'sauvegarde',
            createdAt: DateTime.now(),
            nombreBeneficiaires: 0,
            nombreDocuments: 0,
          ),
        ];

        when(mockContractService.getSavedQuotes(page: 1, limit: 20))
            .thenAnswer((_) async => expectedQuotes);

        final result = await repository.getSavedQuotes();

        expect(result, equals(expectedQuotes));
        expect(result.length, 1);
        verify(mockContractService.getSavedQuotes(page: 1, limit: 20))
            .called(1);
      });

      test('utilise les paramètres page et limit personnalisés', () async {
        when(mockContractService.getSavedQuotes(page: 2, limit: 10))
            .thenAnswer((_) async => <SavedQuote>[]);

        await repository.getSavedQuotes(page: 2, limit: 10);

        verify(mockContractService.getSavedQuotes(page: 2, limit: 10))
            .called(1);
      });

      test('propage les erreurs de ContractService', () async {
        when(mockContractService.getSavedQuotes(page: 1, limit: 20))
            .thenThrow(ApiException('Erreur serveur', 500));

        expect(
          () => repository.getSavedQuotes(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getContracts', () {
      test('appelle ContractService.getContracts avec les bons paramètres',
          () async {
        final expectedContracts = [
          Contract(
            id: '1',
            nomProduit: 'Product 1',
            typeProduit: 'vie',
            primeCalculee: 50000,
            franchiseCalculee: 10000,
            statut: 'actif',
            dateSouscription: DateTime.now(),
            numeroContrat: 'CONTRACT-001',
            nombreBeneficiaires: 1,
            nombreDocuments: 2,
          ),
        ];

        when(mockContractService.getContracts(page: 1, limit: 20))
            .thenAnswer((_) async => expectedContracts);

        final result = await repository.getContracts();

        expect(result, equals(expectedContracts));
        expect(result.length, 1);
        verify(mockContractService.getContracts(page: 1, limit: 20)).called(1);
      });

      test('propage les erreurs de ContractService', () async {
        when(mockContractService.getContracts(page: 1, limit: 20))
            .thenThrow(ApiException('Erreur serveur', 500));

        expect(
          () => repository.getContracts(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('deleteSavedQuote', () {
      test('appelle ContractService.deleteSavedQuote avec le bon quoteId',
          () async {
        when(mockContractService.deleteSavedQuote('quote-123'))
            .thenAnswer((_) async => {});

        await repository.deleteSavedQuote('quote-123');

        verify(mockContractService.deleteSavedQuote('quote-123')).called(1);
      });

      test('propage les erreurs de ContractService', () async {
        when(mockContractService.deleteSavedQuote('invalid-quote'))
            .thenThrow(ApiException('Quote non trouvé', 404));

        expect(
          () => repository.deleteSavedQuote('invalid-quote'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('subscribeQuote', () {
      test('appelle ContractService.subscribeQuote avec le bon quoteId',
          () async {
        final expectedContract = Contract(
          id: 'contract-1',
          nomProduit: 'Product 1',
          typeProduit: 'vie',
          primeCalculee: 50000,
          franchiseCalculee: 10000,
          statut: 'actif',
          dateSouscription: DateTime.now(),
          numeroContrat: 'CONTRACT-001',
          nombreBeneficiaires: 1,
          nombreDocuments: 2,
        );

        when(mockContractService.subscribeQuote('quote-123'))
            .thenAnswer((_) async => expectedContract);

        final result = await repository.subscribeQuote('quote-123');

        expect(result, equals(expectedContract));
        expect(result.id, 'contract-1');
        verify(mockContractService.subscribeQuote('quote-123')).called(1);
      });

      test('propage les erreurs de ContractService', () async {
        when(mockContractService.subscribeQuote('invalid-quote'))
            .thenThrow(ApiException('Quote non trouvé', 404));

        expect(
          () => repository.subscribeQuote('invalid-quote'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateSavedQuote', () {
      test('appelle ContractService.updateSavedQuote avec les bons paramètres',
          () async {
        final expectedQuote = SavedQuote(
          id: 'quote-123',
          nomProduit: 'Product 1',
          typeProduit: 'vie',
          primeCalculee: 50000,
          franchiseCalculee: 10000,
          statut: 'sauvegarde',
          createdAt: DateTime.now(),
          nomPersonnalise: 'Mon Devis',
          notes: 'Notes de test',
          nombreBeneficiaires: 0,
          nombreDocuments: 0,
        );

        when(
          mockContractService.updateSavedQuote(
            quoteId: 'quote-123',
            nomPersonnalise: 'Mon Devis',
            notes: 'Notes de test',
          ),
        ).thenAnswer((_) async => expectedQuote);

        final result = await repository.updateSavedQuote(
          quoteId: 'quote-123',
          nomPersonnalise: 'Mon Devis',
          notes: 'Notes de test',
        );

        expect(result, equals(expectedQuote));
        expect(result.nomPersonnalise, 'Mon Devis');
        verify(
          mockContractService.updateSavedQuote(
            quoteId: 'quote-123',
            nomPersonnalise: 'Mon Devis',
            notes: 'Notes de test',
          ),
        ).called(1);
      });

      test('passe null pour nomPersonnalise et notes si non fournis', () async {
        final expectedQuote = SavedQuote(
          id: 'quote-123',
          nomProduit: 'Product 1',
          typeProduit: 'vie',
          primeCalculee: 50000,
          franchiseCalculee: 10000,
          statut: 'sauvegarde',
          createdAt: DateTime.now(),
          nombreBeneficiaires: 0,
          nombreDocuments: 0,
        );

        when(
          mockContractService.updateSavedQuote(
            quoteId: 'quote-123',
            nomPersonnalise: null,
            notes: null,
          ),
        ).thenAnswer((_) async => expectedQuote);

        await repository.updateSavedQuote(quoteId: 'quote-123');

        verify(
          mockContractService.updateSavedQuote(
            quoteId: 'quote-123',
            nomPersonnalise: null,
            notes: null,
          ),
        ).called(1);
      });
    });

    group('getSavedQuoteDetails', () {
      test(
        'appelle ContractService.getSavedQuoteDetails avec le bon quoteId',
        () async {
          final expectedQuote = SavedQuote(
            id: 'quote-123',
            nomProduit: 'Product 1',
            typeProduit: 'vie',
            primeCalculee: 50000,
            franchiseCalculee: 10000,
            statut: 'sauvegarde',
            createdAt: DateTime.now(),
            nombreBeneficiaires: 0,
            nombreDocuments: 0,
          );

          when(mockContractService.getSavedQuoteDetails('quote-123'))
              .thenAnswer((_) async => expectedQuote);

          final result = await repository.getSavedQuoteDetails('quote-123');

          expect(result, equals(expectedQuote));
          expect(result.id, 'quote-123');
          verify(mockContractService.getSavedQuoteDetails('quote-123'))
              .called(1);
        },
      );

      test('propage les erreurs de ContractService', () async {
        when(mockContractService.getSavedQuoteDetails('invalid-quote'))
            .thenThrow(ApiException('Quote non trouvé', 404));

        expect(
          () => repository.getSavedQuoteDetails('invalid-quote'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getActiveContractsCount', () {
      test('appelle ContractService.getActiveContractsCount', () async {
        when(mockContractService.getActiveContractsCount())
            .thenAnswer((_) async => 5);

        final result = await repository.getActiveContractsCount();

        expect(result, 5);
        verify(mockContractService.getActiveContractsCount()).called(1);
      });

      test('retourne 0 si aucun contrat actif', () async {
        when(mockContractService.getActiveContractsCount())
            .thenAnswer((_) async => 0);

        final result = await repository.getActiveContractsCount();

        expect(result, 0);
      });

      test('propage les erreurs de ContractService', () async {
        when(mockContractService.getActiveContractsCount())
            .thenThrow(ApiException('Erreur serveur', 500));

        expect(
          () => repository.getActiveContractsCount(),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}