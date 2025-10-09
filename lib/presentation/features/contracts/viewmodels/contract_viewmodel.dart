import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/saved_quote_model.dart';
import 'package:saarflex_app/data/models/contract_model.dart';
import 'package:saarflex_app/data/repositories/contract_service.dart';
import 'package:saarflex_app/core/utils/logger.dart';

class ContractViewModel extends ChangeNotifier {
  final ContractService _contractService = ContractService();

  // États pour les devis sauvegardés
  List<SavedQuote> _savedQuotes = [];
  bool _isLoadingSavedQuotes = false;
  String? _savedQuotesError;

  // États pour les contrats
  List<Contract> _contracts = [];
  bool _isLoadingContracts = false;
  String? _contractsError;

  // États généraux
  bool _isLoading = false;
  String? _error;

  // Getters pour les devis sauvegardés
  List<SavedQuote> get savedQuotes => List.unmodifiable(_savedQuotes);
  bool get isLoadingSavedQuotes => _isLoadingSavedQuotes;
  String? get savedQuotesError => _savedQuotesError;

  // Getters pour les contrats
  List<Contract> get contracts => List.unmodifiable(_contracts);
  bool get isLoadingContracts => _isLoadingContracts;
  String? get contractsError => _contractsError;

  // Getters généraux
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters combinés
  bool get hasAnyData => _savedQuotes.isNotEmpty || _contracts.isNotEmpty;
  bool get hasAnyError => _savedQuotesError != null || _contractsError != null;

  /// Charge les devis sauvegardés
  Future<void> loadSavedQuotes({bool forceRefresh = false}) async {
    if (_isLoadingSavedQuotes && !forceRefresh) return;

    _isLoadingSavedQuotes = true;
    _savedQuotesError = null;
    notifyListeners();

    try {
      AppLogger.info('Chargement des devis sauvegardés...');
      final quotes = await _contractService.getSavedQuotes();

      _savedQuotes = quotes;
      _savedQuotesError = null;

      AppLogger.info('${quotes.length} devis sauvegardés chargés');
    } catch (e) {
      _savedQuotesError = e.toString();
      AppLogger.error('Erreur lors du chargement des devis sauvegardés: $e');
    } finally {
      _isLoadingSavedQuotes = false;
      notifyListeners();
    }
  }

  /// Charge les contrats
  Future<void> loadContracts({bool forceRefresh = false}) async {
    if (_isLoadingContracts && !forceRefresh) return;

    _isLoadingContracts = true;
    _contractsError = null;
    notifyListeners();

    try {
      AppLogger.info('Chargement des contrats...');
      final contracts = await _contractService.getContracts();

      _contracts = contracts;
      _contractsError = null;

      AppLogger.info('${contracts.length} contrats chargés');
    } catch (e) {
      _contractsError = e.toString();
      AppLogger.error('Erreur lors du chargement des contrats: $e');
    } finally {
      _isLoadingContracts = false;
      notifyListeners();
    }
  }

  /// Charge toutes les données
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
      AppLogger.error('Erreur lors du chargement des données: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprime un devis sauvegardé
  Future<void> deleteSavedQuote(String quoteId) async {
    try {
      AppLogger.info('Suppression du devis $quoteId...');

      await _contractService.deleteSavedQuote(quoteId);

      // Retirer de la liste locale
      _savedQuotes.removeWhere((quote) => quote.id == quoteId);

      AppLogger.info('Devis $quoteId supprimé avec succès');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression du devis: $e');
      rethrow;
    }
  }

  /// Souscrit un devis (le transforme en contrat)
  Future<void> subscribeQuote(String quoteId) async {
    try {
      AppLogger.info('Souscription du devis $quoteId...');

      final contract = await _contractService.subscribeQuote(quoteId);

      // Retirer de la liste des devis sauvegardés
      _savedQuotes.removeWhere((quote) => quote.id == quoteId);

      // Ajouter à la liste des contrats
      _contracts.add(contract);

      AppLogger.info('Devis $quoteId souscrit avec succès');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Erreur lors de la souscription du devis: $e');
      rethrow;
    }
  }

  /// Met à jour un devis sauvegardé
  Future<void> updateSavedQuote({
    required String quoteId,
    String? nomPersonnalise,
    String? notes,
  }) async {
    try {
      AppLogger.info('Mise à jour du devis $quoteId...');

      final updatedQuote = await _contractService.updateSavedQuote(
        quoteId: quoteId,
        nomPersonnalise: nomPersonnalise,
        notes: notes,
      );

      // Mettre à jour dans la liste locale
      final index = _savedQuotes.indexWhere((quote) => quote.id == quoteId);
      if (index != -1) {
        _savedQuotes[index] = updatedQuote;
      }

      AppLogger.info('Devis $quoteId mis à jour avec succès');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du devis: $e');
      rethrow;
    }
  }

  /// Récupère les détails d'un devis sauvegardé
  Future<SavedQuote> getSavedQuoteDetails(String quoteId) async {
    try {
      AppLogger.info('Récupération des détails du devis $quoteId...');

      final quote = await _contractService.getSavedQuoteDetails(quoteId);

      AppLogger.info('Détails du devis $quoteId récupérés');
      return quote;
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des détails: $e');
      rethrow;
    }
  }

  /// Rafraîchit toutes les données
  Future<void> refresh() async {
    await loadAllData(forceRefresh: true);
  }

  /// Efface les erreurs
  void clearErrors() {
    _savedQuotesError = null;
    _contractsError = null;
    _error = null;
    notifyListeners();
  }

  /// Efface toutes les données
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

  /// Vérifie si un devis existe
  bool hasSavedQuote(String quoteId) {
    return _savedQuotes.any((quote) => quote.id == quoteId);
  }

  /// Vérifie si un contrat existe
  bool hasContract(String contractId) {
    return _contracts.any((contract) => contract.id == contractId);
  }

  /// Obtient un devis sauvegardé par son ID
  SavedQuote? getSavedQuoteById(String quoteId) {
    try {
      return _savedQuotes.firstWhere((quote) => quote.id == quoteId);
    } catch (e) {
      return null;
    }
  }

  /// Obtient un contrat par son ID
  Contract? getContractById(String contractId) {
    try {
      return _contracts.firstWhere((contract) => contract.id == contractId);
    } catch (e) {
      return null;
    }
  }
}
