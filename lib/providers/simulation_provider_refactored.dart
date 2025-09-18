import 'package:flutter/material.dart';
import '../models/simulation_model.dart';
import '../models/critere_tarification_model.dart';
import '../services/simulation_service.dart';
import '../services/validation_service.dart';
import '../services/criteria_processing_service.dart';
import '../utils/logger.dart';

class SimulationProviderRefactored extends ChangeNotifier {
  final SimulationService _simulationService = SimulationService();

  // État de chargement
  bool _isLoadingCriteres = false;
  bool _isSimulating = false;
  bool _isSaving = false;

  // Données
  String? _produitId;
  String? _grilleTarifaireId;
  List<CritereTarification> _criteresProduit = [];
  final Map<String, dynamic> _criteresReponses = {};
  SimulationResponse? _dernierResultat;

  // Gestion des erreurs
  String? _errorMessage;
  final Map<String, String> _validationErrors = {};
  String? _saveError;

  // Getters
  bool get isLoadingCriteres => _isLoadingCriteres;
  bool get isSimulating => _isSimulating;
  bool get isSaving => _isSaving;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  String? get saveError => _saveError;

  List<CritereTarification> get criteresProduit =>
      List.unmodifiable(_criteresProduit);
  Map<String, dynamic> get criteresReponses =>
      Map.unmodifiable(_criteresReponses);
  SimulationResponse? get dernierResultat => _dernierResultat;
  Map<String, String> get validationErrors =>
      Map.unmodifiable(_validationErrors);

  String? get produitId => _produitId;
  String? get grilleTarifaireId => _grilleTarifaireId;

  bool get isFormValid =>
      ValidationService.isFormValid(_criteresProduit, _criteresReponses);
  bool get canSimulate => isFormValid && !isSimulating && !isLoadingCriteres;

  List<CritereTarification> get criteresProduitTries {
    final criteres = List<CritereTarification>.from(_criteresProduit);
    criteres.sort((a, b) => a.ordre.compareTo(b.ordre));
    return criteres;
  }

  /// Initialise une nouvelle simulation
  Future<void> initierSimulation({required String produitId}) async {
    _produitId = produitId;
    _grilleTarifaireId = null;
    _criteresReponses.clear();
    _validationErrors.clear();
    _dernierResultat = null;
    _clearError();

    await chargerCriteresProduit();
  }

  /// Charge les critères du produit
  Future<void> chargerCriteresProduit() async {
    if (_produitId == null) return;

    _setLoadingCriteres(true);
    _clearError();

    try {
      _criteresProduit = await _simulationService.getCriteresProduit(
        _produitId!,
        page: 1,
        limit: 100,
      );

      _logCriteresReceived();
      _initializeDefaultValues();
    } catch (e) {
      _setError('Erreur lors du chargement des critères: $e');
    } finally {
      _setLoadingCriteres(false);
    }
  }

  /// Met à jour la réponse d'un critère
  void updateCritereReponse(String nomCritere, dynamic valeur) {
    if (_criteresReponses[nomCritere] == valeur) {
      return;
    }

    _criteresReponses[nomCritere] = valeur;
    _validationErrors.remove(nomCritere);
    _validateCritere(nomCritere, valeur);

    notifyListeners();
  }

  /// Lance une simulation
  Future<void> simulerDevis({
    required bool assureEstSouscripteur,
    Map<String, dynamic>? informationsAssure,
  }) async {
    if (!isFormValid) {
      _setError('Veuillez corriger les erreurs dans le formulaire');
      return;
    }

    _setSimulating(true);
    _clearError();

    try {
      final criteresNettoyes = CriteriaProcessingService.cleanCriteriaForApi(
        _criteresProduit,
        _criteresReponses,
      );

      _dernierResultat = await _simulationService.simulerDevisSimplifie(
        produitId: _produitId!,
        criteres: criteresNettoyes,
        assureEstSouscripteur: assureEstSouscripteur,
        informationsAssure: informationsAssure,
      );
    } catch (e) {
      AppLogger.error('Erreur dans le provider: $e');
      _setError(e.toString());
    } finally {
      _setSimulating(false);
    }
  }

  /// Sauvegarde un devis
  Future<void> sauvegarderDevis({
    required String devisId,
    String? nomPersonnalise,
    String? notes,
    required BuildContext context,
  }) async {
    _setSaving(true);
    _clearSaveError();

    try {
      // TODO: Implémenter la sauvegarde du devis
      // await _simulationService.sauvegarderDevis(devisId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Devis sauvegardé avec succès',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _setSaveError('Erreur lors de la sauvegarde: $e');
    } finally {
      _setSaving(false);
    }
  }

  /// Valide un critère spécifique
  void _validateCritere(String nomCritere, dynamic valeur) {
    final critere = _findCritere(nomCritere);
    if (critere == null) return;

    final error = ValidationService.validateCritere(critere, valeur);
    if (error != null) {
      _validationErrors[nomCritere] = error;
    } else {
      _validationErrors.remove(nomCritere);
    }
  }

  /// Trouve un critère par son nom
  CritereTarification? _findCritere(String nomCritere) {
    try {
      return _criteresProduit.firstWhere((c) => c.nom == nomCritere);
    } catch (e) {
      AppLogger.error('Critère $nomCritere non trouvé');
      return null;
    }
  }

  /// Initialise les valeurs par défaut
  void _initializeDefaultValues() {
    final defaultValues = CriteriaProcessingService.initializeDefaultValues(
      _criteresProduit,
    );
    _criteresReponses.addAll(defaultValues);
  }

  /// Log les critères reçus
  void _logCriteresReceived() {
    AppLogger.debug('Critères reçus:');
    for (var critere in _criteresProduit) {
      AppLogger.debug(' - ${critere.nom} (type: ${critere.type})');
    }
  }

  // Méthodes de gestion d'état
  void _setLoadingCriteres(bool loading) {
    _isLoadingCriteres = loading;
    notifyListeners();
  }

  void _setSimulating(bool simulating) {
    _isSimulating = simulating;
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setSaveError(String error) {
    _saveError = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearSaveError() {
    _saveError = null;
    notifyListeners();
  }

  /// Nettoie toutes les erreurs
  void clearAllErrors() {
    _clearError();
    _clearSaveError();
    _validationErrors.clear();
    notifyListeners();
  }

  /// Réinitialise le provider
  void reset() {
    _produitId = null;
    _grilleTarifaireId = null;
    _criteresProduit.clear();
    _criteresReponses.clear();
    _dernierResultat = null;
    _validationErrors.clear();
    _clearError();
    _clearSaveError();
    notifyListeners();
  }

  /// Obtient les options pour un critère catégoriel
  List<String> getCategoricalOptions(String nomCritere) {
    final critere = _findCritere(nomCritere);
    if (critere == null) return [];
    return CriteriaProcessingService.getCategoricalOptions(critere);
  }

  /// Obtient les contraintes pour un critère numérique
  Map<String, num?> getNumericConstraints(String nomCritere) {
    final critere = _findCritere(nomCritere);
    if (critere == null) return {'min': null, 'max': null};
    return CriteriaProcessingService.getNumericConstraints(critere);
  }

  /// Formate une valeur pour l'affichage
  String formatValueForDisplay(String nomCritere, dynamic valeur) {
    final critere = _findCritere(nomCritere);
    if (critere == null) return valeur?.toString() ?? '';
    return CriteriaProcessingService.formatValueForDisplay(critere, valeur);
  }
}
