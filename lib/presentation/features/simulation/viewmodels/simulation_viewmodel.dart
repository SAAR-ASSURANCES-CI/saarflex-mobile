import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/data/services/simulation_service.dart';
import 'package:saarflex_app/core/utils/logger.dart';

class SimulationViewModel extends ChangeNotifier {
  final SimulationService _simulationService = SimulationService();

  bool _isLoadingCriteres = false;
  bool _isSimulating = false;
  bool _isSaving = false;
  String? _saveError;
  String? get saveError => _saveError;

  String? _produitId;
  String? _grilleTarifaireId;
  List<CritereTarification> _criteresProduit = [];
  final Map<String, dynamic> _criteresReponses = {};
  SimulationResponse? _dernierResultat;

  // Nouveaux champs pour les bénéficiaires
  final List<Map<String, dynamic>> _beneficiaires = [];
  bool _assureEstSouscripteur = true;
  Map<String, dynamic>? _informationsAssure;

  String? _errorMessage;
  final Map<String, String> _validationErrors = {};

  bool get isLoadingCriteres => _isLoadingCriteres;
  bool get isSimulating => _isSimulating;
  bool get isSaving => _isSaving;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  List<CritereTarification> get criteresProduit =>
      List.unmodifiable(_criteresProduit);
  Map<String, dynamic> get criteresReponses =>
      Map.unmodifiable(_criteresReponses);
  SimulationResponse? get dernierResultat => _dernierResultat;
  Map<String, String> get validationErrors =>
      Map.unmodifiable(_validationErrors);

  String? get produitId => _produitId;
  String? get grilleTarifaireId => _grilleTarifaireId;

  // Getters pour les bénéficiaires
  List<Map<String, dynamic>> get beneficiaires =>
      List.unmodifiable(_beneficiaires);
  bool get assureEstSouscripteur => _assureEstSouscripteur;
  Map<String, dynamic>? get informationsAssure => _informationsAssure;

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

  bool get canSimulate => isFormValid && !isSimulating && !isLoadingCriteres;

  Future<void> initierSimulation({
    required String produitId,
    required bool assureEstSouscripteur,
    Map<String, dynamic>? informationsAssure,
  }) async {
    _produitId = produitId;
    _grilleTarifaireId = null;
    _criteresReponses.clear();
    _validationErrors.clear();
    _dernierResultat = null;
    _beneficiaires.clear();
    _assureEstSouscripteur = assureEstSouscripteur;
    _informationsAssure = informationsAssure;
    _clearError();

    await chargerCriteresProduit();
  }

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

      for (final critere in _criteresProduit) {
        if (critere.type == TypeCritere.booleen) {
          _criteresReponses[critere.nom] = false;
        } else if (critere.type == TypeCritere.categoriel &&
            critere.hasValeurs) {
          _criteresReponses[critere.nom] = null;
        }
      }
    } catch (e) {
      _setError('Erreur lors du chargement des critères: $e');
    } finally {
      _setLoadingCriteres(false);
    }
  }

  void updateCritereReponse(String nomCritere, dynamic valeur) {
    if (_criteresReponses[nomCritere] == valeur) {
      return;
    }

    _criteresReponses[nomCritere] = valeur;
    _validationErrors.remove(nomCritere);
    _validateCritere(nomCritere, valeur);

    notifyListeners();
  }

  // Dans simulation_provider.dart - méthode _validateCritere
  void _validateCritere(String nomCritere, dynamic valeur) {
    final critere = _criteresProduit.firstWhere(
      (c) => c.nom == nomCritere,
      orElse: () => throw Exception('Critère $nomCritere non trouvé'),
    );

    // Gestion des séparateurs pour les champs numériques
    if (critere.type == TypeCritere.numerique && valeur != null) {
      String valeurString = valeur.toString();

      // Enlever les séparateurs de milliers pour la validation si nécessaire
      if (_critereNecessiteFormatage(critere)) {
        valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
      }

      final numericValue = num.tryParse(valeurString);
      if (numericValue == null) {
        _validationErrors[nomCritere] = 'Veuillez entrer un nombre valide';
        return;
      }
      // Stocker la valeur numérique (sans séparateurs)
      _criteresReponses[nomCritere] = numericValue;
    }

    // Le reste de votre validation existante...
    if (critere.obligatoire &&
        (valeur == null || valeur.toString().trim().isEmpty)) {
      _validationErrors[nomCritere] = 'Ce champ est obligatoire';
      return;
    }

    switch (critere.type) {
      case TypeCritere.numerique:
        if (valeur != null && valeur.toString().isNotEmpty) {
          // Utiliser la valeur déjà nettoyée des séparateurs
          final doubleValue = _criteresReponses[nomCritere] is num
              ? _criteresReponses[nomCritere].toDouble()
              : double.tryParse(
                  valeur.toString().replaceAll(RegExp(r'[^\d]'), ''),
                );

          if (doubleValue == null) {
            _validationErrors[nomCritere] = 'Veuillez saisir un nombre valide';
          } else {
            for (final valeurCritere in critere.valeurs) {
              if (valeurCritere.valeurMin != null &&
                  doubleValue < valeurCritere.valeurMin!) {
                _validationErrors[nomCritere] =
                    'Valeur minimum: ${valeurCritere.valeurMin}';
                return;
              }
              if (valeurCritere.valeurMax != null &&
                  doubleValue > valeurCritere.valeurMax!) {
                _validationErrors[nomCritere] =
                    'Valeur maximum: ${valeurCritere.valeurMax}';
                return;
              }
            }
          }
        }
        break;

      case TypeCritere.categoriel:
        if (valeur != null && critere.hasValeurs) {
          if (!critere.valeursString.contains(valeur.toString())) {
            _validationErrors[nomCritere] = 'Valeur non autorisée';
          }
        }
        break;

      case TypeCritere.booleen:
        break;
    }
  }

  // Ajouter cette méthode helper dans SimulationViewModel
  bool _critereNecessiteFormatage(CritereTarification critere) {
    const champsAvecSeparateurs = [
      'capital',
      'capital_assure',
      'montant',
      'prime',
      'franchise',
      'plafond',
      'souscription',
      'assurance',
    ];

    final nomCritereLower = critere.nom.toLowerCase();

    for (final motCle in champsAvecSeparateurs) {
      final contains = nomCritereLower.contains(motCle);
      if (contains) {
        return true;
      }
    }

    return false;
  }

  void validateForm() {
    _validationErrors.clear();

    for (final critere in _criteresProduit) {
      final valeur = _criteresReponses[critere.nom];
      _validateCritere(critere.nom, valeur);
    }

    notifyListeners();
  }

  // Méthodes pour gérer les bénéficiaires
  void addBeneficiaire({
    required String nomComplet,
    required String lienSouscripteur,
  }) {
    final beneficiaire = {
      'nom_complet': nomComplet,
      'lien_souscripteur': lienSouscripteur,
      'ordre': _beneficiaires.length + 1, // Génère automatiquement l'ordre
    };

    _beneficiaires.add(beneficiaire);
    _clearError();
    notifyListeners();
  }

  void removeBeneficiaire(int index) {
    if (index >= 0 && index < _beneficiaires.length) {
      _beneficiaires.removeAt(index);
      // Réorganiser les ordres après suppression
      for (int i = 0; i < _beneficiaires.length; i++) {
        _beneficiaires[i]['ordre'] = i + 1;
      }
      notifyListeners();
    }
  }

  void updateBeneficiaire(
    int index, {
    required String nomComplet,
    required String lienSouscripteur,
  }) {
    if (index >= 0 && index < _beneficiaires.length) {
      _beneficiaires[index] = {
        'nom_complet': nomComplet,
        'lien_souscripteur': lienSouscripteur,
        'ordre': index + 1, // Maintient l'ordre correct
      };
      notifyListeners();
    }
  }

  void clearBeneficiaires() {
    _beneficiaires.clear();
    notifyListeners();
  }

  // Dans simulation_provider.dart - méthode simulerDevisSimplifie
  Future<void> simulerDevisSimplifie() async {
    validateForm();

    if (!isFormValid) {
      _setError('Veuillez corriger les erreurs dans le formulaire');
      return;
    }

    _setSimulating(true);
    _clearError();

    try {
      // Nettoyer les valeurs des séparateurs avant envoi
      final criteresNettoyes = Map<String, dynamic>.from(_criteresReponses);

      for (final critere in _criteresProduit) {
        if (critere.type == TypeCritere.numerique &&
            _critereNecessiteFormatage(critere) &&
            criteresNettoyes[critere.nom] is String) {
          // Nettoyer la valeur des séparateurs
          final valeurNettoyee = criteresNettoyes[critere.nom]
              .toString()
              .replaceAll(RegExp(r'[^\d]'), '');

          criteresNettoyes[critere.nom] = num.tryParse(valeurNettoyee) ?? 0;
        }
      }

      _dernierResultat = await _simulationService.simulerDevisSimplifie(
        produitId: _produitId!,
        criteres: criteresNettoyes, // Utiliser les valeurs nettoyées
        assureEstSouscripteur: _assureEstSouscripteur,
        informationsAssure: _informationsAssure,
        beneficiaires: _beneficiaires,
      );
    } catch (e) {
      AppLogger.error('Erreur dans le provider: $e');
      _setError(e.toString());
    } finally {
      _setSimulating(false);
    }
  }

  Future<void> sauvegarderDevis({
    required String devisId,
    String? nomPersonnalise,
    String? notes,
    required BuildContext context,
  }) async {
    AppLogger.info('🔄 DEBUT sauvegarderDevis');
    AppLogger.info(
      '📋 Paramètres: devisId=$devisId, nom=$nomPersonnalise, notes=$notes',
    );

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      AppLogger.info('📦 Création de SauvegardeDevisRequest...');
      final request = SauvegardeDevisRequest(
        devisId: devisId,
        nomPersonnalise: nomPersonnalise,
        notes: notes,
      );
      AppLogger.info('📦 Request créée: ${request.toJson()}');

      AppLogger.info('🌐 Appel du service de sauvegarde...');
      await _simulationService.sauvegarderDevis(request);
      AppLogger.info('✅ Sauvegarde réussie');
      _saveError = null;
    } catch (error) {
      AppLogger.error('❌ Erreur lors de la sauvegarde: $error');
      AppLogger.error('❌ Type d\'erreur: ${error.runtimeType}');
      if (error.toString().contains('Exception:')) {
        AppLogger.error('❌ Exception détaillée: ${error.toString()}');
      }
      _saveError = 'Erreur lors de la sauvegarde: $error';
    } finally {
      _isSaving = false;
      notifyListeners();
      AppLogger.info(
        '🏁 FIN sauvegarderDevis - isSaving: $_isSaving, error: $_saveError',
      );
    }
  }

  void clearSaveError() {
    _saveError = null;
    notifyListeners();
  }

  void resetSimulation() {
    _produitId = null;
    _grilleTarifaireId = null;
    _criteresProduit.clear();
    _criteresReponses.clear();
    _validationErrors.clear();
    _dernierResultat = null;
    _beneficiaires.clear();
    _assureEstSouscripteur = true;
    _informationsAssure = null;
    _clearError();
    notifyListeners();
  }

  void _setLoadingCriteres(bool loading) {
    _isLoadingCriteres = loading;
    notifyListeners();
  }

  void _setSimulating(bool simulating) {
    _isSimulating = simulating;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String? getValidationError(String nomCritere) {
    return _validationErrors[nomCritere];
  }

  bool hasValidationError(String nomCritere) {
    return _validationErrors.containsKey(nomCritere);
  }
}
