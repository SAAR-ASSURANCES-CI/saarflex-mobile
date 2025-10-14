import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/core/utils/simulation_cache.dart';

/// ViewModel spécialisé pour la gestion du formulaire de simulation
class SimulationFormViewModel extends ChangeNotifier {
  final Map<String, dynamic> _criteresReponses = {};
  final Map<String, String> _validationErrors = {};
  List<CritereTarification> _criteresProduit = [];

  bool _isValidating = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic> get criteresReponses =>
      Map.unmodifiable(_criteresReponses);
  Map<String, String> get validationErrors =>
      Map.unmodifiable(_validationErrors);
  List<CritereTarification> get criteresProduit =>
      List.unmodifiable(_criteresProduit);
  bool get isValidating => _isValidating;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Initialise le formulaire avec les critères
  void initializeForm(List<CritereTarification> criteres) {
    _criteresProduit = List.from(criteres);
    _criteresReponses.clear();
    _validationErrors.clear();
    _errorMessage = null;

    // Initialiser les valeurs par défaut
    for (final critere in _criteresProduit) {
      if (critere.type == TypeCritere.booleen) {
        _criteresReponses[critere.nom] = false;
      } else if (critere.type == TypeCritere.categoriel && critere.hasValeurs) {
        _criteresReponses[critere.nom] = null;
      }
    }

    notifyListeners();
  }

  /// Met à jour la réponse d'un critère
  void updateCritereReponse(String nomCritere, dynamic valeur) {
    if (_criteresReponses[nomCritere] == valeur) return;

    _criteresReponses[nomCritere] = valeur;
    _validationErrors.remove(nomCritere);
    _clearError();

    // Validation en temps réel
    _validateCritere(nomCritere, valeur);
    notifyListeners();
  }

  /// Valide un critère individuel
  void _validateCritere(String nomCritere, dynamic valeur) {
    final critere = _criteresProduit.firstWhere(
      (c) => c.nom == nomCritere,
      orElse: () => throw Exception('Critère $nomCritere non trouvé'),
    );

    // Validation basique des critères
    if (critere.obligatoire &&
        (valeur == null || valeur.toString().trim().isEmpty)) {
      _validationErrors[nomCritere] = 'Ce champ est obligatoire';
    }
  }

  /// Valide l'ensemble du formulaire
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

  /// Vérifie si le formulaire est valide
  bool get isFormValid {
    // Vérifier les champs obligatoires
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

  /// Retourne les critères triés par ordre
  List<CritereTarification> get criteresProduitTries {
    final criteres = List<CritereTarification>.from(_criteresProduit);
    criteres.sort((a, b) => a.ordre.compareTo(b.ordre));
    return criteres;
  }

  /// Retourne l'erreur de validation pour un critère
  String? getValidationError(String nomCritere) {
    return _validationErrors[nomCritere];
  }

  /// Vérifie si un critère a une erreur de validation
  bool hasValidationError(String nomCritere) {
    return _validationErrors.containsKey(nomCritere);
  }

  /// Nettoie les critères pour l'envoi
  Map<String, dynamic> getCriteresNettoyes() {
    // Nettoyer les valeurs des séparateurs pour les champs numériques
    final criteresNettoyes = Map<String, dynamic>.from(_criteresReponses);

    for (final critere in _criteresProduit) {
      if (critere.type == TypeCritere.numerique &&
          criteresNettoyes[critere.nom] is String) {
        // Nettoyer la valeur des séparateurs
        final valeurNettoyee = criteresNettoyes[critere.nom]
            .toString()
            .replaceAll(RegExp(r'[^\d]'), '');

        criteresNettoyes[critere.nom] = num.tryParse(valeurNettoyee) ?? 0;
      }
    }

    return criteresNettoyes;
  }

  /// Sauvegarde les réponses en cache
  Future<void> saveToCache() async {
    await SimulationCache.saveCriteresReponses(_criteresReponses);
  }

  /// Charge les réponses depuis le cache
  Future<void> loadFromCache() async {
    final cachedReponses = await SimulationCache.getCriteresReponses();
    if (cachedReponses != null) {
      _criteresReponses.clear();
      _criteresReponses.addAll(cachedReponses);
      notifyListeners();
    }
  }

  /// Réinitialise le formulaire
  void resetForm() {
    _criteresReponses.clear();
    _validationErrors.clear();
    _errorMessage = null;
    notifyListeners();
  }

  /// Définit l'état de validation
  void _setValidating(bool validating) {
    _isValidating = validating;
    notifyListeners();
  }

  /// Efface l'erreur
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
