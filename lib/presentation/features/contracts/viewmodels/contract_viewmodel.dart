import 'package:flutter/material.dart';
import 'package:saarciflex_app/data/models/saved_quote_model.dart';
import 'package:saarciflex_app/data/models/contract_model.dart';
import 'package:saarciflex_app/data/repositories/contract_repository.dart';

class ContractViewModel extends ChangeNotifier {
  final ContractRepository _contractRepository = ContractRepository();

  List<SavedQuote> _savedQuotes = [];
  bool _isLoadingSavedQuotes = false;
  String? _savedQuotesError;

  List<Contract> _contracts = [];
  bool _isLoadingContracts = false;
  String? _contractsError;

  bool _isLoading = false;
  String? _error;

  List<SavedQuote> get savedQuotes => List.unmodifiable(_savedQuotes);
  bool get isLoadingSavedQuotes => _isLoadingSavedQuotes;
  String? get savedQuotesError => _savedQuotesError;

  List<Contract> get contracts => List.unmodifiable(_contracts);
  bool get isLoadingContracts => _isLoadingContracts;
  String? get contractsError => _contractsError;

  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasAnyData => _savedQuotes.isNotEmpty || _contracts.isNotEmpty;
  bool get hasAnyError => _savedQuotesError != null || _contractsError != null;
  Future<void> loadSavedQuotes({bool forceRefresh = false}) async {
    if (_isLoadingSavedQuotes && !forceRefresh) return;

    _isLoadingSavedQuotes = true;
    _savedQuotesError = null;
    notifyListeners();

    try {
      final quotes = await _contractRepository.getSavedQuotes();
      _savedQuotes = quotes;
      _savedQuotesError = null;
    } catch (e) {
      _savedQuotesError = e.toString();
    } finally {
      _isLoadingSavedQuotes = false;
      notifyListeners();
    }
  }

  Future<void> loadContracts({bool forceRefresh = false}) async {
    if (_isLoadingContracts && !forceRefresh) return;

    _isLoadingContracts = true;
    _contractsError = null;
    notifyListeners();

    try {
      final contracts = await _contractRepository.getContracts();
      _contracts = contracts;
      _contractsError = null;
    } catch (e) {
      _contractsError = e.toString();
    } finally {
      _isLoadingContracts = false;
      notifyListeners();
    }
  }

  Future<void> loadAllData({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadSavedQuotes(forceRefresh: forceRefresh),
        loadContracts(forceRefresh: forceRefresh),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSavedQuote(String quoteId) async {
    try {
      await _contractRepository.deleteSavedQuote(quoteId);
      _savedQuotes.removeWhere((quote) => quote.id == quoteId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> subscribeQuote(String quoteId) async {
    try {
      final contract = await _contractRepository.subscribeQuote(quoteId);
      _savedQuotes.removeWhere((quote) => quote.id == quoteId);
      _contracts.add(contract);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSavedQuote({
    required String quoteId,
    String? nomPersonnalise,
    String? notes,
  }) async {
    try {
      final updatedQuote = await _contractRepository.updateSavedQuote(
        quoteId: quoteId,
        nomPersonnalise: nomPersonnalise,
        notes: notes,
      );
      final index = _savedQuotes.indexWhere((quote) => quote.id == quoteId);
      if (index != -1) {
        _savedQuotes[index] = updatedQuote;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<SavedQuote> getSavedQuoteDetails(String quoteId) async {
    try {
      final quote = await _contractRepository.getSavedQuoteDetails(quoteId);
      return quote;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadAllData(forceRefresh: true);
  }

  void clearErrors() {
    _savedQuotesError = null;
    _contractsError = null;
    _error = null;
    notifyListeners();
  }

  void clearAll() {
    _savedQuotes.clear();
    _contracts.clear();
    _savedQuotesError = null;
    _contractsError = null;
    _error = null;
    _isLoading = false;
    _isLoadingSavedQuotes = false;
    _isLoadingContracts = false;
    notifyListeners();
  }

  bool hasSavedQuote(String quoteId) {
    return _savedQuotes.any((quote) => quote.id == quoteId);
  }

  bool hasContract(String contractId) {
    return _contracts.any((contract) => contract.id == contractId);
  }

  SavedQuote? getSavedQuoteById(String quoteId) {
    try {
      return _savedQuotes.firstWhere((quote) => quote.id == quoteId);
    } catch (e) {
      return null;
    }
  }

  Contract? getContractById(String contractId) {
    try {
      return _contracts.firstWhere((contract) => contract.id == contractId);
    } catch (e) {
      return null;
    }
  }
}
