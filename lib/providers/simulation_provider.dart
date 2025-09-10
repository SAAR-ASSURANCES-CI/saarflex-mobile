import 'package:flutter/material.dart';
import '../models/simulation_model.dart';
import '../models/critere_tarification_model.dart';
import '../services/simulation_service.dart';

class SimulationProvider extends ChangeNotifier {
  final SimulationService _simulationService = SimulationService();

  bool _isLoadingCriteres = false;
  bool _isSimulating = false;
  bool _isSaving = false;

  String? _produitId;
  String? _grilleTarifaireId;
  List<CritereTarification> _criteresProduit = [];
  final Map<String, dynamic> _criteresReponses = {};
  SimulationResponse? _dernierResultat;

  String? _errorMessage;
  final Map<String, String> _validationErrors = {};

  bool get isLoadingCriteres => _isLoadingCriteres;
  bool get isSimulating => _isSimulating;
  bool get isSaving => _isSaving;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  
  List<CritereTarification> get criteresProduit => List.unmodifiable(_criteresProduit);
  Map<String, dynamic> get criteresReponses => Map.unmodifiable(_criteresReponses);
  SimulationResponse? get dernierResultat => _dernierResultat;
  Map<String, String> get validationErrors => Map.unmodifiable(_validationErrors);

  String? get produitId => _produitId;
  String? get grilleTarifaireId => _grilleTarifaireId;

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
  }) async {
    _produitId = produitId;
    _grilleTarifaireId = null;
    _criteresReponses.clear();
    _validationErrors.clear();
    _dernierResultat = null;
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
        } else if (critere.type == TypeCritere.categoriel && critere.hasValeurs) {
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

  void _validateCritere(String nomCritere, dynamic valeur) {
    final critere = _criteresProduit.firstWhere(
      (c) => c.nom == nomCritere,
      orElse: () => throw Exception('Critère $nomCritere non trouvé'),
    );

    if (critere.type == TypeCritere.numerique && valeur != null) {
      if (valeur is String) {
        final numericValue = num.tryParse(valeur);
        if (numericValue == null) {
          _validationErrors[nomCritere] = 'Veuillez entrer un nombre valide';
          return;
        }
        _criteresReponses[nomCritere] = numericValue;
      }
    }

    if (critere.obligatoire && (valeur == null || valeur.toString().trim().isEmpty)) {
      _validationErrors[nomCritere] = 'Ce champ est obligatoire';
      return;
    }

    switch (critere.type) {
      case TypeCritere.numerique:
        if (valeur != null && valeur.toString().isNotEmpty) {
          final doubleValue = double.tryParse(valeur.toString());
          if (doubleValue == null) {
            _validationErrors[nomCritere] = 'Veuillez saisir un nombre valide';
          } else {
            for (final valeurCritere in critere.valeurs) {
              if (valeurCritere.valeurMin != null && doubleValue < valeurCritere.valeurMin!) {
                _validationErrors[nomCritere] = 'Valeur minimum: ${valeurCritere.valeurMin}';
                return;
              }
              if (valeurCritere.valeurMax != null && doubleValue > valeurCritere.valeurMax!) {
                _validationErrors[nomCritere] = 'Valeur maximum: ${valeurCritere.valeurMax}';
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

  void validateForm() {
    _validationErrors.clear();
    
    for (final critere in _criteresProduit) {
      final valeur = _criteresReponses[critere.nom];
      _validateCritere(critere.nom, valeur);
    }
    
    notifyListeners();
  }

 // REMPLACEZ toute la méthode simulerDevis par ceci :
Future<void> simulerDevisSimplifie(Map<String, dynamic> donneesSupplementaires) async {
  
  validateForm();
  
  if (!isFormValid) {
    _setError('Veuillez corriger les erreurs dans le formulaire');
    return;
  }

  _setSimulating(true);
  _clearError();

  try {
    // 1. Récupérer la grille tarifaire automatiquement
    final grilleId = await _simulationService.getGrilleTarifaireForProduit(_produitId!);
    
    if (grilleId == null) {
      _setError('Aucune grille tarifaire disponible pour ce produit');
      return;
    }

    // 2. Stocker l'ID de la grille pour référence
    _grilleTarifaireId = grilleId;

    // 3. Appeler la simulation SIMPLIFIÉE avec les bons paramètres
    _dernierResultat = await _simulationService.simulerDevisSimplifie(
      produitId: _produitId!,
      criteres: Map.from(_criteresReponses),
      donneesSupplementaires: donneesSupplementaires,
    );
    
  } catch (e) {
    _setError(e.toString());
  } finally {
    _setSimulating(false);
  }
}
// Future<void> simulerDevis() async {
//   validateForm();
  
//   if (!isFormValid) {
//     _setError('Veuillez corriger les erreurs dans le formulaire');
//     return;
//   }

//   _setSimulating(true);
//   _clearError();

//   try {
//     // 1. Récupérer la grille tarifaire automatiquement
//     final grilleId = await _simulationService.getGrilleTarifaireForProduit(_produitId!);
    
//     if (grilleId == null) {
//       _setError('Aucune grille tarifaire disponible pour ce produit');
//       return;
//     }

//     // 2. Stocker l'ID de la grille pour référence
//     _grilleTarifaireId = grilleId;

//     // 3. Préparer la requête avec produit ID, grille ID et critères
//     final request = SimulationRequest(
//       produitId: _produitId!,
//       grilleTarifaireId: grilleId,
//       criteresUtilisateur: Map.from(_criteresReponses),
//     );

//     // 4. Appeler la simulation SIMPLIFIÉE (SEULE LIGNE MODIFIÉE)
//     _dernierResultat = await _simulationService.simulerDevis(request);
    
//   } catch (e) {
//     _setError(e.toString());
//   } finally {
//     _setSimulating(false);
//   }
// }



  Future<void> sauvegarderDevis({
    String? nomPersonnalise,
    String? notes,
  }) async {
    if (_dernierResultat == null) {
      _setError('Aucun devis à sauvegarder');
      return;
    }

    _setSaving(true);
    _clearError();

    try {
      final request = SauvegardeDevisRequest(
        devisId: _dernierResultat!.id,
        nomPersonnalise: nomPersonnalise,
        notes: notes,
      );

      await _simulationService.sauvegarderDevis(request);
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setSaving(false);
    }
  }

  void resetSimulation() {
    _produitId = null;
    _grilleTarifaireId = null;
    _criteresProduit.clear();
    _criteresReponses.clear();
    _validationErrors.clear();
    _dernierResultat = null;
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

  void _setSaving(bool saving) {
    _isSaving = saving;
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