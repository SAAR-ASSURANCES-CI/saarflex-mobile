import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/data/services/simulation_service.dart';
import 'package:saarflex_app/data/services/file_upload_service.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';

class SimulationRepository {
  final SimulationService _simulationService;
  final FileUploadService _fileUploadService;

  SimulationRepository({
    SimulationService? simulationService,
    FileUploadService? fileUploadService,
  })  : _simulationService = simulationService ?? SimulationService(),
        _fileUploadService = fileUploadService ?? FileUploadService();

  Future<List<CritereTarification>> getCriteresProduit(
    String produitId, {
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final criteres = await _simulationService.getCriteresProduit(
        produitId,
        page: page,
        limit: limit,
      );

      return criteres;
    } catch (e) {
      rethrow;
    }
  }

  Future<SimulationResponse> simulerDevisSimplifie({
    required String produitId,
    required Map<String, dynamic> criteres,
    required bool assureEstSouscripteur,
    Map<String, dynamic>? informationsAssure,
  }) async {
    try {
      final resultat = await _simulationService.simulerDevisSimplifie(
        produitId: produitId,
        criteres: criteres,
        assureEstSouscripteur: assureEstSouscripteur,
        informationsAssure: informationsAssure,
      );

      return resultat;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sauvegarderDevis(SauvegardeDevisRequest request) async {
    try {
      await _simulationService.sauvegarderDevis(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getGrilleTarifaireForProduit(String produitId) async {
    try {
      final grilleId = await _simulationService.getGrilleTarifaireForProduit(
        produitId,
      );

      return grilleId;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SimulationResponse>> getMesDevis({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final devis = await _simulationService.getMesDevis(
        page: page,
        limit: limit,
      );

      return devis;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> supprimerDevis(String devisId) async {
    try {
      await _simulationService.supprimerDevis(devisId);
    } catch (e) {
      rethrow;
    }
  }

  bool critereNecessiteFormatage(CritereTarification critere) {
    return _simulationService.critereNecessiteFormatage(critere);
  }

  Map<String, dynamic> nettoyerCriteres(
    Map<String, dynamic> criteres,
    List<CritereTarification> criteresProduit,
  ) {
    return _simulationService.nettoyerCriteres(criteres, criteresProduit);
  }

  String? validateCritere(
    CritereTarification critere,
    dynamic valeur,
  ) {
    return _simulationService.validateCritere(critere, valeur);
  }

  Map<String, String> validateAllCriteres(
    Map<String, dynamic> criteresReponses,
    List<CritereTarification> criteresProduit,
  ) {
    return _simulationService.validateAllCriteres(
      criteresReponses,
      criteresProduit,
    );
  }

  bool isSaarNansou(String? produitId) {
    return _simulationService.isSaarNansou(produitId);
  }

  int? calculerDureeAuto(int age) {
    return _simulationService.calculerDureeAuto(age);
  }

  int calculerAge(DateTime birthDate) {
    return _simulationService.calculerAge(birthDate);
  }

  DateTime? parseBirthDate(dynamic dateNaissance) {
    return _simulationService.parseBirthDate(dateNaissance);
  }

  String? formatBirthDateForApi(DateTime? birthDate) {
    return _simulationService.formatBirthDateForApi(birthDate);
  }

  Map<String, dynamic>? nettoyerInformationsAssure(
    Map<String, dynamic>? informationsAssure,
  ) {
    return _simulationService.nettoyerInformationsAssure(informationsAssure);
  }

  Future<Map<String, String>> uploadAssureImages({
    required String devisId,
    required String rectoPath,
    required String versoPath,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      return await _fileUploadService.uploadAssureImages(
        devisId: devisId,
        rectoPath: rectoPath,
        versoPath: versoPath,
        authToken: token,
      );
    } catch (e) {
      rethrow;
    }
  }
}
