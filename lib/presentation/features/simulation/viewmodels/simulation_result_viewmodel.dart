import 'package:flutter/material.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/data/repositories/simulation_repository.dart';
import 'package:saarciflex_app/core/utils/simulation_validators.dart';

class SimulationResultViewModel extends ChangeNotifier {
  final SimulationRepository _simulationRepository;

  SimulationResultViewModel({SimulationRepository? simulationRepository})
    : _simulationRepository = simulationRepository ?? SimulationRepository();

  SimulationResponse? _dernierResultat;
  bool _isSaving = false;
  String? _saveError;
  final Map<String, String> _validationErrors = {};

  SimulationResponse? get dernierResultat => _dernierResultat;
  bool get isSaving => _isSaving;
  String? get saveError => _saveError;
  bool get hasSaveError => _saveError != null;
  Map<String, String> get validationErrors =>
      Map.unmodifiable(_validationErrors);

  void setResultat(SimulationResponse resultat) {
    _dernierResultat = resultat;
    _clearSaveError();
    notifyListeners();
  }

  Future<bool> sauvegarderDevis({
    required String devisId,
    String? nomPersonnalise,
    String? notes,
    required BuildContext context,
  }) async {
    if (_dernierResultat == null) {
      _setSaveError('Aucun résultat de simulation à sauvegarder');
      return false;
    }

    final validationResult = SimulationValidators.validateSaveInfo(
      devisId: devisId,
      nomPersonnalise: nomPersonnalise,
      notes: notes,
    );

    if (!validationResult.isValid) {
      _validationErrors.clear();
      _validationErrors.addAll(validationResult.errors);
      _setSaveError(
        validationResult.firstError ?? 'Données de sauvegarde invalides',
      );
      notifyListeners();
      return false;
    }

    _setSaving(true);
    _clearSaveError();
    _validationErrors.clear();

    try {
      final request = SauvegardeDevisRequest(
        devisId: devisId,
        nomPersonnalise: nomPersonnalise,
        notes: notes,
      );

      await _simulationRepository.sauvegarderDevis(request);

      _dernierResultat = _dernierResultat!.copyWith(
        statut: StatutDevis.sauvegarde,
      );

      _clearSaveError();

      _triggerImageUploadAfterSave(request.devisId);

      return true;
    } catch (error) {
      final errorMessage = _getUserFriendlyError(error);
      _setSaveError('Erreur lors de la sauvegarde: $errorMessage');

      return false;
    } finally {
      _setSaving(false);
      notifyListeners();
    }
  }

  void clearSaveError() {
    _clearSaveError();
    _validationErrors.clear();
    notifyListeners();
  }

  void _triggerImageUploadAfterSave(String devisId) {}

  void clearTempImagesAfterSave() {}

  void resetResultat() {
    _dernierResultat = null;
    _clearSaveError();
    _validationErrors.clear();
    notifyListeners();
  }

  bool get canSave {
    return _dernierResultat != null &&
        _dernierResultat!.statut != StatutDevis.sauvegarde &&
        !_isSaving;
  }

  bool get isAlreadySaved {
    return _dernierResultat?.statut == StatutDevis.sauvegarde;
  }

  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  String? getValidationError(String field) {
    return _validationErrors[field];
  }

  void setValidationError(String field, String error) {
    _validationErrors[field] = error;
    notifyListeners();
  }

  void clearValidationError(String field) {
    _validationErrors.remove(field);
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  void _setSaveError(String error) {
    _saveError = error;
    notifyListeners();
  }

  void _clearSaveError() {
    _saveError = null;
    notifyListeners();
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Problème de connexion internet';
    } else if (errorString.contains('timeout')) {
      return 'Délai d\'attente dépassé';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Authentification requise';
    } else if (errorString.contains('403') ||
        errorString.contains('forbidden')) {
      return 'Accès non autorisé';
    } else if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return 'Ressource non trouvée';
    } else if (errorString.contains('500') || errorString.contains('server')) {
      return 'Erreur interne du serveur';
    } else if (errorString.contains('format')) {
      return 'Format de données invalide';
    }

    return 'Une erreur inattendue est survenue';
  }
}

extension SimulationResponseCopyWith on SimulationResponse {
  SimulationResponse copyWith({
    String? id,
    String? nomProduit,
    String? typeProduit,
    String? periodicitePrime,
    Map<String, dynamic>? criteresUtilisateur,
    double? primeCalculee,
    bool? assureEstSouscripteur,
    Map<String, dynamic>? informationsAssure,
    List<Map<String, dynamic>>? beneficiaires,
    DateTime? createdAt,
    double? franchiseCalculee,
    double? plafondCalcule,
    DetailsCalcul? detailsCalcul,
    StatutDevis? statut,
    DateTime? expiresAt,
  }) {
    return SimulationResponse(
      id: id ?? this.id,
      nomProduit: nomProduit ?? this.nomProduit,
      typeProduit: typeProduit ?? this.typeProduit,
      periodicitePrime: periodicitePrime ?? this.periodicitePrime,
      criteresUtilisateur: criteresUtilisateur ?? this.criteresUtilisateur,
      primeCalculee: primeCalculee ?? this.primeCalculee,
      assureEstSouscripteur:
          assureEstSouscripteur ?? this.assureEstSouscripteur,
      informationsAssure: informationsAssure ?? this.informationsAssure,
      beneficiaires: beneficiaires ?? this.beneficiaires,
      createdAt: createdAt ?? this.createdAt,
      franchiseCalculee: franchiseCalculee ?? this.franchiseCalculee,
      plafondCalcule: plafondCalcule ?? this.plafondCalcule,
      detailsCalcul: detailsCalcul ?? this.detailsCalcul,
      statut: statut ?? this.statut,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
