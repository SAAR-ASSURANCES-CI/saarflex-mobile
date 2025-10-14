import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';

/// Gestionnaire de cache pour la simulation
class SimulationCache {
  static const String _criteresKey = 'simulation_criteres';
  static const String _criteresReponsesKey = 'simulation_criteres_reponses';
  static const String _informationsAssureKey = 'simulation_informations_assure';
  static const String _produitIdKey = 'simulation_produit_id';
  static const String _cacheTimestampKey = 'simulation_cache_timestamp';

  // Durée de validité du cache (24 heures)
  static const Duration _cacheValidityDuration = Duration(hours: 24);

  /// Sauvegarde les critères en cache
  static Future<void> saveCriteres(
    String produitId,
    List<CritereTarification> criteres,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Convertir les critères en JSON
    final criteresJson = criteres.map((c) => c.toJson()).toList();

    await prefs.setString(
      '${_criteresKey}_$produitId',
      json.encode(criteresJson),
    );
    await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
  }

  /// Récupère les critères du cache
  static Future<List<CritereTarification>?> getCriteres(
    String produitId,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Vérifier si le cache est encore valide
    if (!await _isCacheValid()) {
      await clearCache();
      return null;
    }

    final criteresJsonString = prefs.getString('${_criteresKey}_$produitId');
    if (criteresJsonString == null) return null;

    try {
      final criteresJson = json.decode(criteresJsonString) as List;
      return criteresJson
          .map((json) => CritereTarification.fromJson(json))
          .toList();
    } catch (e) {
      // En cas d'erreur de parsing, nettoyer le cache
      await clearCache();
      return null;
    }
  }

  /// Sauvegarde les réponses aux critères
  static Future<void> saveCriteresReponses(
    Map<String, dynamic> reponses,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_criteresReponsesKey, json.encode(reponses));
  }

  /// Récupère les réponses aux critères
  static Future<Map<String, dynamic>?> getCriteresReponses() async {
    final prefs = await SharedPreferences.getInstance();
    final reponsesJsonString = prefs.getString(_criteresReponsesKey);

    if (reponsesJsonString == null) return null;

    try {
      final reponsesJson =
          json.decode(reponsesJsonString) as Map<String, dynamic>;
      return Map<String, dynamic>.from(reponsesJson);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les informations de l'assuré
  static Future<void> saveInformationsAssure(
    Map<String, dynamic> informations,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_informationsAssureKey, json.encode(informations));
  }

  /// Récupère les informations de l'assuré
  static Future<Map<String, dynamic>?> getInformationsAssure() async {
    final prefs = await SharedPreferences.getInstance();
    final informationsJsonString = prefs.getString(_informationsAssureKey);

    if (informationsJsonString == null) return null;

    try {
      final informationsJson =
          json.decode(informationsJsonString) as Map<String, dynamic>;
      return Map<String, dynamic>.from(informationsJson);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde l'ID du produit
  static Future<void> saveProduitId(String produitId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_produitIdKey, produitId);
  }

  /// Récupère l'ID du produit
  static Future<String?> getProduitId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_produitIdKey);
  }

  /// Sauvegarde une simulation complète
  static Future<void> saveSimulationData({
    required String produitId,
    required List<CritereTarification> criteres,
    required Map<String, dynamic> criteresReponses,
    Map<String, dynamic>? informationsAssure,
  }) async {
    await saveCriteres(produitId, criteres);
    await saveCriteresReponses(criteresReponses);
    await saveProduitId(produitId);

    if (informationsAssure != null) {
      await saveInformationsAssure(informationsAssure);
    }
  }

  /// Récupère toutes les données de simulation
  static Future<SimulationCacheData?> getSimulationData() async {
    final produitId = await getProduitId();
    if (produitId == null) return null;

    final criteres = await getCriteres(produitId);
    final criteresReponses = await getCriteresReponses();
    final informationsAssure = await getInformationsAssure();

    if (criteres == null || criteresReponses == null) {
      return null;
    }

    return SimulationCacheData(
      produitId: produitId,
      criteres: criteres,
      criteresReponses: criteresReponses,
      informationsAssure: informationsAssure,
    );
  }

  /// Vérifie si le cache est encore valide
  static Future<bool> _isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampString = prefs.getString(_cacheTimestampKey);

    if (timestampString == null) return false;

    try {
      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();
      return now.difference(timestamp) < _cacheValidityDuration;
    } catch (e) {
      return false;
    }
  }

  /// Nettoie tout le cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Supprimer toutes les clés liées à la simulation
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_criteresKey) ||
          key == _criteresReponsesKey ||
          key == _informationsAssureKey ||
          key == _produitIdKey ||
          key == _cacheTimestampKey) {
        await prefs.remove(key);
      }
    }
  }

  /// Nettoie le cache pour un produit spécifique
  static Future<void> clearCacheForProduit(String produitId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_criteresKey}_$produitId');
  }
}

/// Modèle de données pour le cache de simulation
class SimulationCacheData {
  final String produitId;
  final List<CritereTarification> criteres;
  final Map<String, dynamic> criteresReponses;
  final Map<String, dynamic>? informationsAssure;

  SimulationCacheData({
    required this.produitId,
    required this.criteres,
    required this.criteresReponses,
    this.informationsAssure,
  });
}
