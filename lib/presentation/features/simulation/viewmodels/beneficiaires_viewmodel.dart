import 'package:flutter/material.dart';
import 'package:saarflex_app/core/utils/simulation_validators.dart';
import 'package:saarflex_app/core/utils/simulation_cache.dart';

/// ViewModel spécialisé pour la gestion des bénéficiaires
class BeneficiairesViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _beneficiaires = [];
  int _maxBeneficiaires = 0;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get beneficiaires =>
      List.unmodifiable(_beneficiaires);
  int get maxBeneficiaires => _maxBeneficiaires;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isComplete => _beneficiaires.length == _maxBeneficiaires;
  bool get isEmpty => _beneficiaires.isEmpty;
  int get count => _beneficiaires.length;

  /// Initialise les bénéficiaires avec le nombre maximum
  void initialize(int maxBeneficiaires) {
    _maxBeneficiaires = maxBeneficiaires;
    _beneficiaires.clear();
    _clearError();
    notifyListeners();
  }

  /// Ajoute un bénéficiaire
  void addBeneficiaire({
    required String nomComplet,
    required String lienSouscripteur,
  }) {
    if (_beneficiaires.length >= _maxBeneficiaires) {
      _setError('Nombre maximum de bénéficiaires atteint');
      return;
    }

    final beneficiaire = {
      'nom_complet': nomComplet.trim(),
      'lien_souscripteur': lienSouscripteur.trim(),
      'ordre': _beneficiaires.length + 1,
    };

    _beneficiaires.add(beneficiaire);
    _clearError();
    notifyListeners();
  }

  /// Met à jour un bénéficiaire existant
  void updateBeneficiaire(
    int index, {
    required String nomComplet,
    required String lienSouscripteur,
  }) {
    if (index < 0 || index >= _beneficiaires.length) {
      _setError('Index de bénéficiaire invalide');
      return;
    }

    _beneficiaires[index] = {
      'nom_complet': nomComplet.trim(),
      'lien_souscripteur': lienSouscripteur.trim(),
      'ordre': index + 1,
    };

    _clearError();
    notifyListeners();
  }

  /// Supprime un bénéficiaire
  void removeBeneficiaire(int index) {
    if (index < 0 || index >= _beneficiaires.length) {
      _setError('Index de bénéficiaire invalide');
      return;
    }

    _beneficiaires.removeAt(index);

    // Réorganiser les ordres après suppression
    for (int i = 0; i < _beneficiaires.length; i++) {
      _beneficiaires[i]['ordre'] = i + 1;
    }

    _clearError();
    notifyListeners();
  }

  /// Efface tous les bénéficiaires
  void clearBeneficiaires() {
    _beneficiaires.clear();
    _clearError();
    notifyListeners();
  }

  /// Définit la liste des bénéficiaires (utile pour l'initialisation)
  void setBeneficiaires(List<Map<String, dynamic>> newBeneficiaires) {
    _beneficiaires.clear();
    _beneficiaires.addAll(newBeneficiaires);
    notifyListeners();
  }

  /// Valide les bénéficiaires
  bool validateBeneficiaires() {
    if (_maxBeneficiaires == 0) return true;

    return SimulationValidators.validateBeneficiaires(
      _beneficiaires,
      _maxBeneficiaires,
    );
  }

  /// Retourne les erreurs de validation
  List<String> getValidationErrors() {
    final errors = <String>[];

    if (_maxBeneficiaires > 0 && _beneficiaires.length != _maxBeneficiaires) {
      errors.add('Vous devez ajouter $_maxBeneficiaires bénéficiaire(s)');
    }

    for (int i = 0; i < _beneficiaires.length; i++) {
      final beneficiaire = _beneficiaires[i];

      if (beneficiaire['nom_complet']?.toString().trim().isEmpty ?? true) {
        errors.add('Le nom du bénéficiaire ${i + 1} est obligatoire');
      }

      if (beneficiaire['lien_souscripteur']?.toString().trim().isEmpty ??
          true) {
        errors.add('Le lien du bénéficiaire ${i + 1} est obligatoire');
      }
    }

    return errors;
  }

  /// Sauvegarde les bénéficiaires en cache
  Future<void> saveToCache() async {
    await SimulationCache.saveBeneficiaires(_beneficiaires);
  }

  /// Charge les bénéficiaires depuis le cache
  Future<void> loadFromCache() async {
    final cachedBeneficiaires = await SimulationCache.getBeneficiaires();
    if (cachedBeneficiaires != null) {
      _beneficiaires.clear();
      _beneficiaires.addAll(cachedBeneficiaires);
      notifyListeners();
    }
  }

  /// Réinitialise les bénéficiaires
  void reset() {
    _beneficiaires.clear();
    _maxBeneficiaires = 0;
    _clearError();
    notifyListeners();
  }

  /// Définit une erreur
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Efface l'erreur
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
