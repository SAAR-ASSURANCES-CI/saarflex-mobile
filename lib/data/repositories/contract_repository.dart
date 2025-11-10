import 'package:saarflex_app/data/models/saved_quote_model.dart';
import 'package:saarflex_app/data/models/contract_model.dart';
import 'package:saarflex_app/data/services/contract_service.dart';

class ContractRepository {
  final ContractService _contractService;

  ContractRepository({ContractService? contractService})
      : _contractService = contractService ?? ContractService();

  Future<List<SavedQuote>> getSavedQuotes({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _contractService.getSavedQuotes(
        page: page,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Contract>> getContracts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _contractService.getContracts(
        page: page,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSavedQuote(String quoteId) async {
    try {
      await _contractService.deleteSavedQuote(quoteId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Contract> subscribeQuote(String quoteId) async {
    try {
      return await _contractService.subscribeQuote(quoteId);
    } catch (e) {
      rethrow;
    }
  }

  Future<SavedQuote> updateSavedQuote({
    required String quoteId,
    String? nomPersonnalise,
    String? notes,
  }) async {
    try {
      return await _contractService.updateSavedQuote(
        quoteId: quoteId,
        nomPersonnalise: nomPersonnalise,
        notes: notes,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<SavedQuote> getSavedQuoteDetails(String quoteId) async {
    try {
      return await _contractService.getSavedQuoteDetails(quoteId);
    } catch (e) {
      rethrow;
    }
  }
}

