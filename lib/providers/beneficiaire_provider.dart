import 'package:flutter/material.dart';
import '../models/beneficiaire_model.dart';
import '../services/beneficiaire_service.dart';
import '../utils/logger.dart';

class BeneficiaireProvider extends ChangeNotifier {
  final BeneficiaireService _beneficiaireService = BeneficiaireService();

  // État de chargement
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  // Données
  final BeneficiairesList _beneficiaires = BeneficiairesList();
  String? _contratId;
  String? _simulationId;

  // Gestion des erreurs
  String? _errorMessage;
  final Map<String, String> _validationErrors = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  Map<String, String> get validationErrors =>
      Map.unmodifiable(_validationErrors);

  List<Beneficiaire> get beneficiaires => _beneficiaires.beneficiaires;
  int get beneficiairesCount => _beneficiaires.count;
  bool get hasBeneficiaires => _beneficiaires.isNotEmpty;
  bool get canAddBeneficiaire => !_beneficiaires.isFull;

  // Nouveau: limite dynamique basée sur le produit
  int _maxBeneficiaires = 3;
  int get maxBeneficiaires => _maxBeneficiaires;
  void setMaxBeneficiaires(int max) {
    _maxBeneficiaires = max;
    notifyListeners();
  }

  bool get isFull => _beneficiaires.count >= _maxBeneficiaires;

  String? get contratId => _contratId;
  String? get simulationId => _simulationId;

  bool get isValid => _beneficiaires.isValid;
  List<String> get validationErrorsList => _beneficiaires.validationErrors;

  /// Initialiser les bénéficiaires pour un contrat ou une simulation
  void initializeForContrat(String contratId) {
    _contratId = contratId;
    _simulationId = null;
    _clearData();
    notifyListeners();
  }

  void initializeForSimulation(String simulationId) {
    _simulationId = simulationId;
    _contratId = null;
    _clearData();
    notifyListeners();
  }

  /// Charger les bénéficiaires existants
  Future<void> loadBeneficiaires() async {
    if (_contratId == null && _simulationId == null) {
      _setError('Aucun contrat ou simulation spécifié');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final beneficiaires = await _beneficiaireService.getBeneficiaires(
        contratId: _contratId,
        simulationId: _simulationId,
      );

      _beneficiaires.clear();
      for (final beneficiaire in beneficiaires) {
        _beneficiaires.addBeneficiaire(beneficiaire);
      }

      AppLogger.info('Bénéficiaires chargés: ${beneficiaires.length}');
    } catch (e) {
      _setError('Erreur lors du chargement des bénéficiaires: ${e.toString()}');
      AppLogger.error('Erreur chargement bénéficiaires: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Ajouter un nouveau bénéficiaire
  void addBeneficiaire({
    required String nomComplet,
    required String lienSouscripteur,
    required int ordre,
  }) {
    if (_beneficiaires.count >= _maxBeneficiaires) {
      _setError(
        'Le nombre maximum de bénéficiaires ($_maxBeneficiaires) est atteint',
      );
      return;
    }

    final beneficiaire = Beneficiaire(
      nomComplet: nomComplet,
      lienSouscripteur: lienSouscripteur,
      ordre: ordre,
    );

    // Validation
    final errors = beneficiaire.validationErrors;
    if (errors.isNotEmpty) {
      _setValidationErrors(errors);
      return;
    }

    // Vérifier l'unicité de l'ordre
    final existingOrdre = _beneficiaires.beneficiaires.any(
      (b) => b.ordre == ordre,
    );
    if (existingOrdre) {
      _setError('L\'ordre $ordre est déjà utilisé par un autre bénéficiaire');
      return;
    }

    _beneficiaires.addBeneficiaire(beneficiaire);
    _clearError();
    _clearValidationErrors();
    notifyListeners();
  }

  /// Mettre à jour un bénéficiaire existant
  void updateBeneficiaire(
    int index, {
    required String nomComplet,
    required String lienSouscripteur,
    required int ordre,
  }) {
    if (index < 0 || index >= _beneficiaires.count) {
      _setError('Index de bénéficiaire invalide');
      return;
    }

    final beneficiaire = Beneficiaire(
      id: _beneficiaires.beneficiaires[index].id,
      nomComplet: nomComplet,
      lienSouscripteur: lienSouscripteur,
      ordre: ordre,
    );

    // Validation
    final errors = beneficiaire.validationErrors;
    if (errors.isNotEmpty) {
      _setValidationErrors(errors);
      return;
    }

    // Vérifier l'unicité de l'ordre (sauf pour le bénéficiaire actuel)
    final existingOrdre = _beneficiaires.beneficiaires
        .where((b) => b != _beneficiaires.beneficiaires[index])
        .any((b) => b.ordre == ordre);
    if (existingOrdre) {
      _setError('L\'ordre $ordre est déjà utilisé par un autre bénéficiaire');
      return;
    }

    _beneficiaires.updateBeneficiaire(index, beneficiaire);
    _clearError();
    _clearValidationErrors();
    notifyListeners();
  }

  /// Supprimer un bénéficiaire
  void removeBeneficiaire(int index) {
    if (index < 0 || index >= _beneficiaires.count) {
      _setError('Index de bénéficiaire invalide');
      return;
    }

    _beneficiaires.removeBeneficiaireAt(index);
    _clearError();
    notifyListeners();
  }

  /// Sauvegarder les bénéficiaires sur le serveur
  Future<bool> saveBeneficiaires() async {
    if (_beneficiaires.isEmpty) {
      _setError('Aucun bénéficiaire à sauvegarder');
      return false;
    }

    _setSaving(true);
    _clearError();

    try {
      final beneficiairesData = _beneficiaires.toCreateDtoList();
      final savedBeneficiaires = await _beneficiaireService.createBeneficiaires(
        beneficiairesData: beneficiairesData,
      );

      // Mettre à jour les IDs des bénéficiaires sauvegardés
      _beneficiaires.clear();
      for (final beneficiaire in savedBeneficiaires) {
        _beneficiaires.addBeneficiaire(beneficiaire);
      }

      AppLogger.info('Bénéficiaires sauvegardés: ${savedBeneficiaires.length}');
      return true;
    } catch (e) {
      _setError(
        'Erreur lors de la sauvegarde des bénéficiaires: ${e.toString()}',
      );
      AppLogger.error('Erreur sauvegarde bénéficiaires: $e');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// Supprimer un bénéficiaire du serveur
  Future<bool> deleteBeneficiaireFromServer(String beneficiaireId) async {
    _setDeleting(true);
    _clearError();

    try {
      await _beneficiaireService.deleteBeneficiaire(beneficiaireId);
      AppLogger.info('Bénéficiaire supprimé: $beneficiaireId');
      return true;
    } catch (e) {
      _setError(
        'Erreur lors de la suppression du bénéficiaire: ${e.toString()}',
      );
      AppLogger.error('Erreur suppression bénéficiaire: $e');
      return false;
    } finally {
      _setDeleting(false);
    }
  }

  /// Obtenir les ordres disponibles
  List<int> get availableOrdres => _beneficiaires.availableOrdres;
  int get nextAvailableOrdre => _beneficiaires.nextAvailableOrdre;

  /// Réinitialiser les données
  void reset() {
    _clearData();
    _clearError();
    _clearValidationErrors();
    notifyListeners();
  }

  /// Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  void _setDeleting(bool deleting) {
    _isDeleting = deleting;
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

  void _setValidationErrors(List<String> errors) {
    _validationErrors.clear();
    for (int i = 0; i < errors.length; i++) {
      _validationErrors['error_$i'] = errors[i];
    }
    notifyListeners();
  }

  void _clearValidationErrors() {
    _validationErrors.clear();
    notifyListeners();
  }

  void _clearData() {
    _beneficiaires.clear();
    _contratId = null;
    _simulationId = null;
  }
}
