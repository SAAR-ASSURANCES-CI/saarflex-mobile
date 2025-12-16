import 'package:flutter/material.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';
import 'package:saarciflex_app/core/utils/simulation_cache.dart';

class SimulationFormViewModel extends ChangeNotifier {
  final Map<String, dynamic> _criteresReponses = {};
  final Map<String, String> _validationErrors = {};
  List<CritereTarification> _criteresProduit = [];

  bool _isValidating = false;
  String? _errorMessage;

  Map<String, dynamic> get criteresReponses =>
      Map.unmodifiable(_criteresReponses);
  Map<String, String> get validationErrors =>
      Map.unmodifiable(_validationErrors);
  List<CritereTarification> get criteresProduit =>
      List.unmodifiable(_criteresProduit);
  bool get isValidating => _isValidating;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  void initializeForm(List<CritereTarification> criteres) {
    _criteresProduit = List.from(criteres);
    _criteresReponses.clear();
    _validationErrors.clear();
    _errorMessage = null;

    for (final critere in _criteresProduit) {
      if (critere.type == TypeCritere.booleen) {
        _criteresReponses[critere.nom] = false;
      } else if (critere.type == TypeCritere.categoriel && critere.hasValeurs) {
        _criteresReponses[critere.nom] = null;
      }
    }

    notifyListeners();
  }

  void updateCritereReponse(String nomCritere, dynamic valeur) {
    if (_criteresReponses[nomCritere] == valeur) return;

    _criteresReponses[nomCritere] = valeur;
    _validationErrors.remove(nomCritere);
    _clearError();

    _validateCritere(nomCritere, valeur);
    notifyListeners();
  }

  void _validateCritere(String nomCritere, dynamic valeur) {
    final critere = _criteresProduit.firstWhere(
      (c) => c.nom == nomCritere,
      orElse: () => throw Exception('Critère $nomCritere non trouvé'),
    );

    if (critere.obligatoire &&
        (valeur == null || valeur.toString().trim().isEmpty)) {
      _validationErrors[nomCritere] = 'Ce champ est obligatoire';
    }
  }

  void validateForm() {
    _validationErrors.clear();
    _setValidating(true);

    for (final critere in _criteresProduit) {
      final valeur = _criteresReponses[critere.nom];
      _validateCritere(critere.nom, valeur);
    }

    _setValidating(false);
    notifyListeners();
  }

  bool get isFormValid {
    for (final critere in _criteresProduit) {
      if (critere.obligatoire) {
        final valeur = _criteresReponses[critere.nom];
        if (valeur == null || valeur.toString().trim().isEmpty) {
          return false;
        }
      }
    }

    return _validationErrors.isEmpty;
  }

  List<CritereTarification> get criteresProduitTries {
    final criteres = List<CritereTarification>.from(_criteresProduit);
    criteres.sort((a, b) => a.ordre.compareTo(b.ordre));
    return criteres;
  }

  String? getValidationError(String nomCritere) {
    return _validationErrors[nomCritere];
  }

  bool hasValidationError(String nomCritere) {
    return _validationErrors.containsKey(nomCritere);
  }

  Map<String, dynamic> getCriteresNettoyes() {
    final criteresNettoyes = Map<String, dynamic>.from(_criteresReponses);

    for (final critere in _criteresProduit) {
      if (critere.type == TypeCritere.numerique &&
          criteresNettoyes[critere.nom] is String) {
        final valeurNettoyee = criteresNettoyes[critere.nom]
            .toString()
            .replaceAll(RegExp(r'[^\d]'), '');

        criteresNettoyes[critere.nom] = num.tryParse(valeurNettoyee) ?? 0;
      }
    }

    return criteresNettoyes;
  }

  Future<void> saveToCache() async {
    await SimulationCache.saveCriteresReponses(_criteresReponses);
  }

  Future<void> loadFromCache() async {
    final cachedReponses = await SimulationCache.getCriteresReponses();
    if (cachedReponses != null) {
      _criteresReponses.clear();
      _criteresReponses.addAll(cachedReponses);
      notifyListeners();
    }
  }

  void resetForm() {
    _criteresReponses.clear();
    _validationErrors.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void _setValidating(bool validating) {
    _isValidating = validating;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
