import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';
import 'package:saarciflex_app/data/repositories/simulation_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:saarciflex_app/core/utils/error_handler.dart';
import 'package:provider/provider.dart';
import 'package:saarciflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';

class SimulationViewModel extends ChangeNotifier {
  final SimulationRepository _simulationRepository = SimulationRepository();

  bool _isLoadingCriteres = false;
  bool _isSimulating = false;
  bool _isSaving = false;
  String? _saveError;
  String? get saveError => _saveError;

  XFile? _tempRectoImage;
  XFile? _tempVersoImage;
  XFile? _tempPermisRectoImage;
  XFile? _tempPermisVersoImage;
  String? _devisId;
  String? _uploadedRectoUrl;
  String? _uploadedVersoUrl;
  bool _isUploadingImages = false;

  String? _produitId;
  String? _grilleTarifaireId;
  List<CritereTarification> _criteresProduit = [];
  final Map<String, dynamic> _criteresReponses = {};
  SimulationResponse? _dernierResultat;
  List<CritereTarification>? _criteresProduitTriesCache;
  DateTime? _criteresProduitTriesCacheTime;

  bool _assureEstSouscripteur = true;
  Map<String, dynamic>? _informationsAssure;
  Map<String, dynamic>? _informationsVehicule;

  String? _errorMessage;
  Map<String, String> _validationErrors = {};

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

  XFile? get tempRectoImage => _tempRectoImage;
  XFile? get tempVersoImage => _tempVersoImage;
  XFile? get tempPermisRectoImage => _tempPermisRectoImage;
  XFile? get tempPermisVersoImage => _tempPermisVersoImage;
  String? get devisId => _devisId;
  String? get uploadedRectoUrl => _uploadedRectoUrl;
  String? get uploadedVersoUrl => _uploadedVersoUrl;
  bool get isUploadingImages => _isUploadingImages;
  bool get hasTempImages => _tempRectoImage != null && _tempVersoImage != null;
  bool get hasTempPermisImages => _tempPermisRectoImage != null && _tempPermisVersoImage != null;
  bool get hasUploadedImages =>
      _uploadedRectoUrl != null && _uploadedVersoUrl != null;
  
  Map<String, dynamic>? get informationsVehicule => _informationsVehicule;

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
    if (_criteresProduitTriesCache != null && 
        _criteresProduitTriesCacheTime != null &&
        DateTime.now().difference(_criteresProduitTriesCacheTime!).inSeconds < 5) {
      return _criteresProduitTriesCache!;
    }
    final criteres = List<CritereTarification>.from(_criteresProduit);
    criteres.sort((a, b) => a.ordre.compareTo(b.ordre));
    _criteresProduitTriesCache = criteres;
    _criteresProduitTriesCacheTime = DateTime.now();
    return criteres;
  }

  bool get canSimulate => isFormValid && !isSimulating && !isLoadingCriteres;

  BuildContext? _contextForAutoCalc;
  String? _produitNom;
  
  Future<void> initierSimulation({
    required String produitId,
    required bool assureEstSouscripteur,
    Map<String, dynamic>? informationsAssure,
    BuildContext? context,
    String? produitNom,
  }) async {
    _produitId = produitId;
    _produitNom = produitNom;
    _grilleTarifaireId = null;
    _criteresReponses.clear();
    _validationErrors.clear();
    _dernierResultat = null;
    _assureEstSouscripteur = assureEstSouscripteur;
    _informationsAssure = informationsAssure;
    _contextForAutoCalc = context;
    _clearError();

    await chargerCriteresProduit();
    
    if (_isSaarNansou() && _contextForAutoCalc != null && _criteresProduit.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () async {
        if (_contextForAutoCalc != null) {
          try {
            await calcAutoDureeWithContext(_contextForAutoCalc!);
          } catch (e) {
            if (kDebugMode) debugPrint('Auto duree error: $e');
          }
        }
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    return _simulationRepository.calculerAge(birthDate);
  }

  Future<void> chargerCriteresProduit() async {
    if (_produitId == null) return;

    _setLoadingCriteres(true);
    _clearError();

    try {
      _criteresProduit = await _simulationRepository.getCriteresProduit(
        _produitId!,
        page: 1,
        limit: 100,
      );
      _criteresProduitTriesCache = null;

      for (final critere in _criteresProduit) {
        if (critere.type == TypeCritere.booleen) {
          _criteresReponses[critere.nom] = false;
        } else if (critere.type == TypeCritere.categoriel &&
            critere.hasValeurs) {
          _criteresReponses[critere.nom] = null;
        } else if (critere.type == TypeCritere.date || critere.type == TypeCritere.texte) {
          _criteresReponses[critere.nom] = null;
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des critères: $e');
    } finally {
      _setLoadingCriteres(false);
      notifyListeners();
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

    final error = _simulationRepository.validateCritere(critere, valeur);
    if (error != null) {
      _validationErrors[nomCritere] = error;
    } else {
      _validationErrors.remove(nomCritere);
      
      if (critere.type == TypeCritere.numerique && valeur != null) {
        String valeurString = valeur.toString();
        if (_simulationRepository.critereNecessiteFormatage(critere)) {
          valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
          final numericValue = num.tryParse(valeurString);
          if (numericValue != null) {
            _criteresReponses[nomCritere] = numericValue;
          }
        }
      }
    }
  }

  void validateForm() {
    _validationErrors.clear();
    _validationErrors.addAll(
      _simulationRepository.validateAllCriteres(
        _criteresReponses,
        _criteresProduit,
      ),
    );

    notifyListeners();
  }

  Future<void> simulerDevisSimplifie() async {
    validateForm();

    if (!isFormValid) {
      _setError('Veuillez corriger les erreurs dans le formulaire');
      return;
    }

    _setSimulating(true);
    _clearError();

    Map<String, dynamic> criteresNettoyes = {};
    Map<String, dynamic>? informationsAssureConverties;

    try {
      criteresNettoyes = _simulationRepository.nettoyerCriteres(
        _criteresReponses,
        _criteresProduit,
      );

      informationsAssureConverties =
          _simulationRepository.nettoyerInformationsAssure(
        _informationsAssure,
      );

      _dernierResultat = await _simulationRepository.simulerDevisSimplifie(
        produitId: _produitId!,
        criteres: criteresNettoyes,
        assureEstSouscripteur: _assureEstSouscripteur,
        informationsAssure: informationsAssureConverties,
        informationsVehicule: _informationsVehicule,
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

      await _simulationRepository.sauvegarderDevis(request);
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
    _informationsVehicule = null;
    _criteresProduitTriesCache = null;
    _clearError();
    _clearImageData();
    notifyListeners();
  }

  void resetForNewSimulation() {
    resetSimulation();
    _clearTempImages();
  }

  void _clearImageData() {
    _tempRectoImage = null;
    _tempVersoImage = null;
    _tempPermisRectoImage = null;
    _tempPermisVersoImage = null;
    _devisId = null;
    _uploadedRectoUrl = null;
    _uploadedVersoUrl = null;
    _isUploadingImages = false;
  }

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

  void setDevisId(String devisId) {
    _devisId = devisId;
    notifyListeners();
  }

  Future<void> pickImage(bool isRecto, BuildContext context) async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final extension = image.path.toLowerCase();
        if (!extension.endsWith('.jpg') &&
            !extension.endsWith('.jpeg') &&
            !extension.endsWith('.png') &&
            !extension.endsWith('.webp')) {
          throw Exception(
            'Format d\'image non supporté. Formats acceptés: JPEG, PNG, WebP',
          );
        }

        if (isRecto) {
          _tempRectoImage = image;
        } else {
          _tempVersoImage = image;
        }

        notifyListeners();

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

  Future<void> pickPermisImage(bool isRecto, BuildContext context) async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final extension = image.path.toLowerCase();
        if (!extension.endsWith('.jpg') &&
            !extension.endsWith('.jpeg') &&
            !extension.endsWith('.png') &&
            !extension.endsWith('.webp')) {
          throw Exception(
            'Format d\'image non supporté. Formats acceptés: JPEG, PNG, WebP',
          );
        }

        if (isRecto) {
          _tempPermisRectoImage = image;
        } else {
          _tempPermisVersoImage = image;
        }

        notifyListeners();

        if (_tempPermisRectoImage != null && _tempPermisVersoImage != null) {
          ErrorHandler.showSuccessSnackBar(
            context,
            'Photos du permis prêtes',
          );
        } else {
          final message = isRecto
              ? 'Veuillez maintenant sélectionner le verso du permis'
              : 'Veuillez maintenant sélectionner le recto du permis';
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

      final result = await _uploadWithRetry(devisId);

      _uploadedRectoUrl = result['recto_path'];
      _uploadedVersoUrl = result['verso_path'];

      if (_informationsAssure != null) {
        _informationsAssure!['assure_recto_image'] = result['recto_path'];
        _informationsAssure!['assure_verso_image'] = result['verso_path'];
      }

      if (context != null && context.mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Images uploadées avec succès !',
        );
      }

      _clearTempImages();
    } catch (e) {
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

  Future<Map<String, String>> _uploadWithRetry(String devisId) async {
    const maxRetries = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = await _simulationRepository.uploadAssureImages(
          devisId: devisId,
          rectoPath: _tempRectoImage!.path,
          versoPath: _tempVersoImage!.path,
        );

        return result;
      } catch (e) {
        if (attempt == maxRetries) {
          throw Exception('Échec après $maxRetries tentatives: $e');
        }

        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }

    throw Exception('Upload impossible après $maxRetries tentatives');
  }

  void deleteTempImage(bool isRecto) {
    if (isRecto) {
      _tempRectoImage = null;
    } else {
      _tempVersoImage = null;
    }
    notifyListeners();
  }

  void updateInformationsAssure(Map<String, dynamic> informations) {
    _informationsAssure = informations;
    if (_isSaarNansou() && _criteresProduit.isNotEmpty) {
      _calcAutoDuree().catchError((e) {
      });
    }
    notifyListeners();
  }

  void updateInformationsVehicule(Map<String, dynamic> informations) {
    _informationsVehicule = informations;
    notifyListeners();
  }

  Future<void> calcDureeFromProfile(BuildContext context) async {
    await calcAutoDureeWithContext(context);
   }

  bool _isSaarNansou() {
    final isSaarNansouById = _simulationRepository.isSaarNansou(_produitId);
    
    if (!isSaarNansouById && _produitNom != null) {
      final nomLower = _produitNom!.toLowerCase();
      return nomLower.contains('nansou') || nomLower.contains('saar nansou');
    }
    
    return isSaarNansouById;
  }

  Future<void> _calcAutoDuree([BuildContext? context]) async {
    DateTime? birthDate = _getBirthDate();
    
    if (birthDate == null && context != null && _assureEstSouscripteur) {
      try {
        final authProvider = context.read<AuthViewModel>();
        final user = authProvider.currentUser;
        if (user?.birthDate != null) {
          birthDate = user!.birthDate;
          _informationsAssure ??= {};
          _informationsAssure!['date_naissance'] = birthDate;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Birth date update error: $e');
      }
    }
    
    if (birthDate == null) return;
    
    final age = _calculateAge(birthDate);
    final duree = await _calcDuree(age);
    
    if (duree != null) {
      _setDuree(duree);
    }
  }

  Future<void> calcAutoDureeWithContext(BuildContext context) async {
    if (!_isSaarNansou()) {
      return;
    }
    if (_criteresProduit.isEmpty) {
      return;
    }
    await _calcAutoDuree(context);
    notifyListeners();
  }

  DateTime? _getBirthDate() {
    final dateNaissance = _informationsAssure?['date_naissance'];
    return _simulationRepository.parseBirthDate(dateNaissance);
  }

  Future<int?> _calcDuree(int age) async {
    return await _simulationRepository.calculerDureeAuto(age, produitId: _produitId);
  }

  void _setDuree(int duree) {
    try {
      final critereDuree = _criteresProduit.firstWhere(
        (critere) {
          final nomLower = critere.nom.toLowerCase();
          return nomLower.contains('durée') || 
                 nomLower.contains('duree') || 
                 nomLower.contains('cotisation');
        },
        orElse: () => throw Exception('Critère Durée Cotisation non trouvé'),
      );

      final dureeString = duree.toString();
      if (critereDuree.valeursString.contains(dureeString)) {
        updateCritereReponse(critereDuree.nom, dureeString);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Duree update error: $e');
    }
  }

  void clearTempImagesAfterSave() {
    _clearTempImages();
  }
}
