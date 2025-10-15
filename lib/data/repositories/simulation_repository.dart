import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/data/services/simulation_service.dart';
import 'package:saarflex_app/core/utils/logger.dart';

class SimulationRepository {
  final SimulationService _simulationService;

  SimulationRepository({SimulationService? simulationService})
    : _simulationService = simulationService ?? SimulationService();

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
}
