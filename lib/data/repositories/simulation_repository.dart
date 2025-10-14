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
      AppLogger.info(
        '📋 Récupération des critères pour le produit: $produitId',
      );

      final criteres = await _simulationService.getCriteresProduit(
        produitId,
        page: page,
        limit: limit,
      );

      AppLogger.info('✅ ${criteres.length} critères récupérés');
      return criteres;
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la récupération des critères: $e');
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
      AppLogger.info(
        '🔄 Simulation de devis simplifiée pour le produit: $produitId',
      );
      AppLogger.info('📊 Critères: ${criteres.keys.join(', ')}');
      AppLogger.info('👤 Assuré est souscripteur: $assureEstSouscripteur');

      final resultat = await _simulationService.simulerDevisSimplifie(
        produitId: produitId,
        criteres: criteres,
        assureEstSouscripteur: assureEstSouscripteur,
        informationsAssure: informationsAssure,
      );

      AppLogger.info('✅ Simulation réussie - ID: ${resultat.id}');
      AppLogger.info('💰 Prime calculée: ${resultat.primeFormatee}');

      return resultat;
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la simulation: $e');
      rethrow;
    }
  }

  Future<void> sauvegarderDevis(SauvegardeDevisRequest request) async {
    try {
      AppLogger.info('💾 Sauvegarde du devis: ${request.devisId}');
      AppLogger.info('📝 Nom personnalisé: ${request.nomPersonnalise}');
      AppLogger.info('📄 Notes: ${request.notes}');

      await _simulationService.sauvegarderDevis(request);

      AppLogger.info('✅ Devis sauvegardé avec succès');
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la sauvegarde: $e');
      rethrow;
    }
  }

  Future<String?> getGrilleTarifaireForProduit(String produitId) async {
    try {
      AppLogger.info('📊 Récupération de la grille tarifaire pour: $produitId');

      final grilleId = await _simulationService.getGrilleTarifaireForProduit(
        produitId,
      );

      AppLogger.info('✅ Grille tarifaire récupérée: $grilleId');
      return grilleId;
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la récupération de la grille: $e');
      rethrow;
    }
  }

  Future<List<SimulationResponse>> getMesDevis({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info(
        '📋 Récupération des devis sauvegardés (page: $page, limit: $limit)',
      );

      final devis = await _simulationService.getMesDevis(
        page: page,
        limit: limit,
      );

      AppLogger.info('✅ ${devis.length} devis récupérés');
      return devis;
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la récupération des devis: $e');
      rethrow;
    }
  }

  Future<void> supprimerDevis(String devisId) async {
    try {
      AppLogger.info('🗑️ Suppression du devis: $devisId');

      await _simulationService.supprimerDevis(devisId);

      AppLogger.info('✅ Devis supprimé avec succès');
    } catch (e) {
      AppLogger.error('❌ Erreur lors de la suppression: $e');
      rethrow;
    }
  }
}
