import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:saarciflex_app/data/repositories/contract_repository.dart';
import 'package:saarciflex_app/data/services/contract_service.dart';
import 'package:saarciflex_app/data/models/contract_model.dart';
import 'package:saarciflex_app/data/models/saved_quote_model.dart';
import 'package:saarciflex_app/data/services/api_service.dart';

// Mock
class MockContractService extends Mock implements ContractService {}

void main() {
  group('ContractRepository', () {
    late ContractRepository repository;
    late MockContractService mockContractService;

    setUp(() {
      mockContractService = MockContractService();
      repository = ContractRepository(contractService: mockContractService);
    });

    group('getSavedQuotes', () {
      test('appelle ContractService.getSavedQuotes avec les bons paramètres', () async {
        // Arrange
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

        // Act
        final result = await repository.getSavedQuotes();

        // Assert
        expect(result, equals(expectedQuotes));
        expect(result.length, 1);
        verify(mockContractService.getSavedQuotes(page: 1, limit: 20)).called(1);
      });

      test('utilise les paramètres page et limit personnalisés', () async {
        // Arrange
        when(mockContractService.getSavedQuotes(page: 2, limit: 10))
            .thenAnswer((_) async => <SavedQuote>[]);

        // Act
        await repository.getSavedQuotes(page: 2, limit: 10);

        // Assert
        verify(mockContractService.getSavedQuotes(page: 2, limit: 10)).called(1);
      });

      test('propage les erreurs de ContractService', () async {
        // Arrange
        when(mockContractService.getSavedQuotes(page: 1, limit: 20))
            .thenThrow(ApiException('Erreur serveur', 500));

        // Act & Assert
        expect(
          () => repository.getSavedQuotes(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getContracts', () {
      test('appelle ContractService.getContracts avec les bons paramètres', () async {
        // Arrange
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

        // Act
        final result = await repository.getContracts();

        // Assert
        expect(result, equals(expectedContracts));
        expect(result.length, 1);
        verify(mockContractService.getContracts(page: 1, limit: 20)).called(1);
      });

      test('propage les erreurs de ContractService', () async {
        // Arrange
        when(mockContractService.getContracts(page: 1, limit: 20))
            .thenThrow(ApiException('Erreur serveur', 500));

        // Act & Assert
        expect(
          () => repository.getContracts(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('deleteSavedQuote', () {
      test('appelle ContractService.deleteSavedQuote avec le bon quoteId', () async {
        // Arrange
        when(mockContractService.deleteSavedQuote('quote-123'))
            .thenAnswer((_) async => {});

        // Act
        await repository.deleteSavedQuote('quote-123');

        // Assert
        verify(mockContractService.deleteSavedQuote('quote-123')).called(1);
      });

      test('propage les erreurs de ContractService', () async {
        // Arrange
        when(mockContractService.deleteSavedQuote('invalid-quote'))
            .thenThrow(ApiException('Quote non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.deleteSavedQuote('invalid-quote'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('subscribeQuote', () {
      test('appelle ContractService.subscribeQuote avec le bon quoteId', () async {
        // Arrange
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

        // Act
        final result = await repository.subscribeQuote('quote-123');

        // Assert
        expect(result, equals(expectedContract));
        expect(result.id, 'contract-1');
        verify(mockContractService.subscribeQuote('quote-123')).called(1);
      });

      test('propage les erreurs de ContractService', () async {
        // Arrange
        when(mockContractService.subscribeQuote('invalid-quote'))
            .thenThrow(ApiException('Quote non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.subscribeQuote('invalid-quote'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateSavedQuote', () {
      test('appelle ContractService.updateSavedQuote avec les bons paramètres', () async {
        // Arrange
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

        when(mockContractService.updateSavedQuote(
          quoteId: 'quote-123',
          nomPersonnalise: 'Mon Devis',
          notes: 'Notes de test',
        )).thenAnswer((_) async => expectedQuote);

        // Act
        final result = await repository.updateSavedQuote(
          quoteId: 'quote-123',
          nomPersonnalise: 'Mon Devis',
          notes: 'Notes de test',
        );

        // Assert
        expect(result, equals(expectedQuote));
        expect(result.nomPersonnalise, 'Mon Devis');
        verify(mockContractService.updateSavedQuote(
          quoteId: 'quote-123',
          nomPersonnalise: 'Mon Devis',
          notes: 'Notes de test',
        )).called(1);
      });

      test('passe null pour nomPersonnalise et notes si non fournis', () async {
        // Arrange
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

        when(mockContractService.updateSavedQuote(
          quoteId: 'quote-123',
          nomPersonnalise: null,
          notes: null,
        )).thenAnswer((_) async => expectedQuote);

        // Act
        await repository.updateSavedQuote(quoteId: 'quote-123');

        // Assert
        verify(mockContractService.updateSavedQuote(
          quoteId: 'quote-123',
          nomPersonnalise: null,
          notes: null,
        )).called(1);
      });
    });

    group('getSavedQuoteDetails', () {
      test('appelle ContractService.getSavedQuoteDetails avec le bon quoteId', () async {
        // Arrange
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

        // Act
        final result = await repository.getSavedQuoteDetails('quote-123');

        // Assert
        expect(result, equals(expectedQuote));
        expect(result.id, 'quote-123');
        verify(mockContractService.getSavedQuoteDetails('quote-123')).called(1);
      });

      test('propage les erreurs de ContractService', () async {
        // Arrange
        when(mockContractService.getSavedQuoteDetails('invalid-quote'))
            .thenThrow(ApiException('Quote non trouvé', 404));

        // Act & Assert
        expect(
          () => repository.getSavedQuoteDetails('invalid-quote'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getActiveContractsCount', () {
      test('appelle ContractService.getActiveContractsCount', () async {
        // Arrange
        when(mockContractService.getActiveContractsCount())
            .thenAnswer((_) async => 5);

        // Act
        final result = await repository.getActiveContractsCount();

        // Assert
        expect(result, 5);
        verify(mockContractService.getActiveContractsCount()).called(1);
      });

      test('retourne 0 si aucun contrat actif', () async {
        // Arrange
        when(mockContractService.getActiveContractsCount())
            .thenAnswer((_) async => 0);

        // Act
        final result = await repository.getActiveContractsCount();

        // Assert
        expect(result, 0);
      });

      test('propage les erreurs de ContractService', () async {
        // Arrange
        when(mockContractService.getActiveContractsCount())
            .thenThrow(ApiException('Erreur serveur', 500));

        // Act & Assert
        expect(
          () => repository.getActiveContractsCount(),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}
