import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/services/simulation_service.dart';
import 'package:saarflex_app/core/utils/simulation_error_handler.dart';

/// ViewModel spécialisé pour la gestion des résultats de simulation
class SimulationResultViewModel extends ChangeNotifier {
  final SimulationService _simulationService = SimulationService();

  SimulationResponse? _dernierResultat;
  bool _isSaving = false;
  String? _saveError;

  // Getters
  SimulationResponse? get dernierResultat => _dernierResultat;
  bool get isSaving => _isSaving;
  String? get saveError => _saveError;
  bool get hasSaveError => _saveError != null;

  /// Définit le résultat de simulation
  void setResultat(SimulationResponse resultat) {
    _dernierResultat = resultat;
    _clearSaveError();
    notifyListeners();
  }

  /// Sauvegarde un devis
  Future<void> sauvegarderDevis({
    required String devisId,
    String? nomPersonnalise,
    String? notes,
    required BuildContext context,
  }) async {
    if (_dernierResultat == null) {
      _setSaveError('Aucun résultat de simulation à sauvegarder');
      return;
    }

    _setSaving(true);
    _clearSaveError();

    try {
      final request = SauvegardeDevisRequest(
        devisId: devisId,
        nomPersonnalise: nomPersonnalise,
        notes: notes,
      );

      await _simulationService.sauvegarderDevis(request);

      // Mettre à jour le statut du résultat
      _dernierResultat = _dernierResultat!.copyWith(
        statut: StatutDevis.sauvegarde,
      );

      _clearSaveError();
      SimulationErrorHandler.showSuccessSnackBar(
        context,
        'Devis sauvegardé avec succès !',
      );
    } catch (error) {
      final errorMessage = SimulationErrorHandler.getUserFriendlyError(error);
      _setSaveError('Erreur lors de la sauvegarde: $errorMessage');

      SimulationErrorHandler.handleSaveError(context, errorMessage);
    } finally {
      _setSaving(false);
    }
  }

  /// Efface l'erreur de sauvegarde
  void clearSaveError() {
    _clearSaveError();
    notifyListeners();
  }

  /// Réinitialise le résultat
  void resetResultat() {
    _dernierResultat = null;
    _clearSaveError();
    notifyListeners();
  }

  /// Vérifie si le devis peut être sauvegardé
  bool get canSave {
    return _dernierResultat != null &&
        _dernierResultat!.statut != StatutDevis.sauvegarde &&
        !_isSaving;
  }

  /// Vérifie si le devis est déjà sauvegardé
  bool get isAlreadySaved {
    return _dernierResultat?.statut == StatutDevis.sauvegarde;
  }

  /// Définit l'état de sauvegarde
  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  /// Définit une erreur de sauvegarde
  void _setSaveError(String error) {
    _saveError = error;
    notifyListeners();
  }

  /// Efface l'erreur de sauvegarde
  void _clearSaveError() {
    _saveError = null;
    notifyListeners();
  }
}

/// Extension pour créer une copie de SimulationResponse avec des modifications
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
