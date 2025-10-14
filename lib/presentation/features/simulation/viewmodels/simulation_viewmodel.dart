import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/data/services/simulation_service.dart';
import 'package:saarflex_app/data/services/api_service.dart';
import 'package:saarflex_app/core/utils/error_handler.dart';

class SimulationViewModel extends ChangeNotifier {
  final SimulationService _simulationService = SimulationService();
  final ApiService _apiService = ApiService();

  bool _isLoadingCriteres = false;
  bool _isSimulating = false;
  bool _isSaving = false;
  String? _saveError;
  String? get saveError => _saveError;

  // Variables pour l'upload d'images
  XFile? _tempRectoImage;
  XFile? _tempVersoImage;
  String? _devisId;
  String? _uploadedRectoUrl;
  String? _uploadedVersoUrl;
  bool _isUploadingImages = false;

  String? _produitId;
  String? _grilleTarifaireId;
  List<CritereTarification> _criteresProduit = [];
  final Map<String, dynamic> _criteresReponses = {};
  SimulationResponse? _dernierResultat;

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

  bool get assureEstSouscripteur => _assureEstSouscripteur;
  Map<String, dynamic>? get informationsAssure => _informationsAssure;

  // Getters pour l'upload d'images
  XFile? get tempRectoImage => _tempRectoImage;
  XFile? get tempVersoImage => _tempVersoImage;
  String? get devisId => _devisId;
  String? get uploadedRectoUrl => _uploadedRectoUrl;
  String? get uploadedVersoUrl => _uploadedVersoUrl;
  bool get isUploadingImages => _isUploadingImages;
  bool get hasTempImages => _tempRectoImage != null && _tempVersoImage != null;
  bool get hasUploadedImages =>
      _uploadedRectoUrl != null && _uploadedVersoUrl != null;

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

      // Convertir les informations de l'assuré si nécessaire
      Map<String, dynamic>? informationsAssureConverties;
      if (_informationsAssure != null) {
        informationsAssureConverties = Map<String, dynamic>.from(
          _informationsAssure!,
        );

        // Convertir la date de naissance en string si c'est un DateTime
        if (informationsAssureConverties.containsKey('date_naissance')) {
          final dateNaissance = informationsAssureConverties['date_naissance'];
          if (dateNaissance is DateTime) {
            final day = dateNaissance.day.toString().padLeft(2, '0');
            final month = dateNaissance.month.toString().padLeft(2, '0');
            informationsAssureConverties['date_naissance'] =
                '$day-$month-${dateNaissance.year}';
          }
        }
      }

      _dernierResultat = await _simulationService.simulerDevisSimplifie(
        produitId: _produitId!,
        criteres: criteresNettoyes, // Utiliser les valeurs nettoyées
        assureEstSouscripteur: _assureEstSouscripteur,
        informationsAssure: informationsAssureConverties,
      );
    } catch (e) {
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
    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      final request = SauvegardeDevisRequest(
        devisId: devisId,
        nomPersonnalise: nomPersonnalise,
        notes: notes,
      );

      await _simulationService.sauvegarderDevis(request);
      _saveError = null;
    } catch (error) {
      _saveError = 'Erreur lors de la sauvegarde: $error';
    } finally {
      _isSaving = false;
      notifyListeners();
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
    _assureEstSouscripteur = true;
    _informationsAssure = null;
    _clearError();
    _clearImageData();
    notifyListeners();
  }

  /// Réinitialise complètement pour une nouvelle simulation
  void resetForNewSimulation() {
    resetSimulation();
    // S'assurer que les images temporaires sont bien nettoyées
    _clearTempImages();
  }

  void _clearImageData() {
    _tempRectoImage = null;
    _tempVersoImage = null;
    _devisId = null;
    _uploadedRectoUrl = null;
    _uploadedVersoUrl = null;
    _isUploadingImages = false;
  }

  /// Nettoie uniquement les images temporaires (garde les URLs uploadées)
  void _clearTempImages() {
    _tempRectoImage = null;
    _tempVersoImage = null;
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

  // Méthodes pour l'upload d'images
  void setDevisId(String devisId) {
    _devisId = devisId;
    notifyListeners();
  }

  /// Sélection d'une image (stockage temporaire)
  Future<void> pickImage(bool isRecto, BuildContext context) async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Validation basique de l'image
        final extension = image.path.toLowerCase();
        if (!extension.endsWith('.jpg') &&
            !extension.endsWith('.jpeg') &&
            !extension.endsWith('.png') &&
            !extension.endsWith('.webp')) {
          throw Exception(
            'Format d\'image non supporté. Formats acceptés: JPEG, PNG, WebP',
          );
        }

        // Stockage temporaire (pas d'upload immédiat)
        if (isRecto) {
          _tempRectoImage = image;
        } else {
          _tempVersoImage = image;
        }

        notifyListeners();

        // Message pour l'autre image
        if (_tempRectoImage != null && _tempVersoImage != null) {
          ErrorHandler.showSuccessSnackBar(
            context,
            'Images prêtes pour l\'upload après sauvegarde',
          );
        } else {
          final message = isRecto
              ? 'Veuillez maintenant sélectionner l\'image verso'
              : 'Veuillez maintenant sélectionner l\'image recto';
          ErrorHandler.showSuccessSnackBar(context, message);
        }
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        ErrorHandler.handleUploadError(e),
      );
    }
  }

  /// Upload des images après sauvegarde du devis
  Future<void> uploadImagesAfterSave(
    String devisId,
    BuildContext? context,
  ) async {
    if (_tempRectoImage == null || _tempVersoImage == null) {
      return;
    }

    _devisId = devisId;

    try {
      _isUploadingImages = true;
      notifyListeners();

      // Upload avec retry (sans context pour éviter l'erreur)
      final result = await _uploadWithRetry(devisId);

      // Stocker les URLs
      _uploadedRectoUrl = result['recto_path'];
      _uploadedVersoUrl = result['verso_path'];

      // Mettre à jour les informations de l'assuré
      if (_informationsAssure != null) {
        _informationsAssure!['assure_recto_image'] = result['recto_path'];
        _informationsAssure!['assure_verso_image'] = result['verso_path'];
      }

      // Afficher le message seulement si le context est encore valide
      if (context != null && context.mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Images uploadées avec succès !',
        );
      }

      // Nettoyer les images temporaires après upload réussi
      _clearTempImages();
    } catch (e) {
      // Afficher l'erreur seulement si le context est encore valide
      if (context != null && context.mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Erreur lors de l\'upload des images: ${e.toString()}',
        );
      }
    } finally {
      _isUploadingImages = false;
      notifyListeners();
    }
  }

  /// Upload avec retry automatique
  Future<Map<String, String>> _uploadWithRetry(String devisId) async {
    const maxRetries = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = await _apiService.uploadAssureImages(
          devisId: devisId,
          rectoPath: _tempRectoImage!.path,
          versoPath: _tempVersoImage!.path,
        );

        return result;
      } catch (e) {
        if (attempt == maxRetries) {
          throw Exception('Échec après $maxRetries tentatives: $e');
        }

        // Attendre avant le retry
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }

    throw Exception('Upload impossible après $maxRetries tentatives');
  }

  /// Suppression d'une image temporaire
  void deleteTempImage(bool isRecto) {
    if (isRecto) {
      _tempRectoImage = null;
    } else {
      _tempVersoImage = null;
    }
    notifyListeners();
  }

  /// Mise à jour des informations de l'assuré
  void updateInformationsAssure(Map<String, dynamic> informations) {
    _informationsAssure = informations;
    notifyListeners();
  }

  /// Nettoie les images temporaires après sauvegarde (méthode publique)
  void clearTempImagesAfterSave() {
    _clearTempImages();
  }
}
