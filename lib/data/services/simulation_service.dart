import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/core/utils/api_config.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';
import 'package:saarflex_app/core/utils/logger.dart';

class SimulationService {
  static const String _basePath = '/simulation-devis-simplifie';

  Future<SimulationResponse> simulerDevisSimplifie({
    required String produitId,
    required Map<String, dynamic> criteres,
    required bool assureEstSouscripteur,
    Map<String, dynamic>? informationsAssure,
  }) async {
    Uri? url;
    Map<String, dynamic>? payload;
    
    try {
      final token = await StorageHelper.getToken();
      url = Uri.parse('${ApiConfig.baseUrl}/simulation-devis-simplifie');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // ✅ CORRECT - Utiliser directement les critères sans transformation
      // Les clés doivent être exactement les noms des critères chargés depuis l'API
      AppLogger.debug('''\n================= SIMULATION SERVICE =================
PRODUIT_ID              : $produitId
ASSURE_EST_SOUSCRIPTEUR : $assureEstSouscripteur
CRITERES (AVANT ENVOI)  : ${criteres.toString()}
CRITERES_KEYS           : ${criteres.keys.join(', ')}
CRITERES_COUNT          : ${criteres.length}
======================================================
''');

      payload = {
        'produit_id': produitId,
        'assure_est_souscripteur': assureEstSouscripteur,
        'criteres_utilisateur': criteres, // ✅ Utiliser directement, pas de transformation !
      };

      if (!assureEstSouscripteur && informationsAssure != null) {
        payload['informations_assure'] = informationsAssure;
      }

      // Logs détaillés de la requête (format lisible)
      final criteresUtilisateur = payload['criteres_utilisateur'];
      final criteresType = criteresUtilisateur.runtimeType.toString();
      
      String criteresKeys;
      int criteresCount = 0;
      if (criteresUtilisateur is Map) {
        criteresKeys = criteresUtilisateur.keys.join(', ');
        criteresCount = criteresUtilisateur.length;
      } else {
        criteresKeys = 'N/A (Type: $criteresType, Value: ${criteresUtilisateur?.toString() ?? 'null'})';
      }
      
      AppLogger.api('''\n================= SIMULATION DEVIS - REQUEST =================
METHOD  : POST
URL     : ${url.toString()}
HEADERS : ${_prettyJson(_maskHeaders(headers))}
BODY    : ${_prettyJson(payload)}
CRITERES_TYPE            : $criteresType
CRITERES_KEYS (ENVOYÉS)  : $criteresKeys
CRITERES_COUNT           : $criteresCount
---------------------------------------------------------------''');
      _logRequestChecklist(payload);

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      AppLogger.api('''\n================= SIMULATION DEVIS - RESPONSE ================
STATUS  : ${response.statusCode}
URL     : ${url.toString()}
BODY    : ${_prettyResponseBody(response.body)}
---------------------------------------------------------------''');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return SimulationResponse.fromJson(responseData);
      } else {
        final errorData = _tryDecode(response.body);
        final errorMessage =
            (errorData is Map && errorData['message'] != null)
                ? errorData['message']
                : 'Erreur de simulation (${response.statusCode})';
        AppLogger.error('''\n================= SIMULATION DEVIS - ERROR ===================
STATUS  : ${response.statusCode}
URL     : ${url.toString()}
MESSAGE : $errorMessage
BODY    : ${_prettyResponseBody(response.body)}
---------------------------------------------------------------''');
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      AppLogger.errorWithStack(
        '''\n================= SIMULATION DEVIS - EXCEPTION ===============
MESSAGE : Erreur inattendue
DETAILS : $e
TYPE    : ${e.runtimeType}
URL     : ${url?.toString() ?? 'Non disponible'}
PAYLOAD : ${payload != null ? _prettyJson(payload) : 'Non disponible'}
---------------------------------------------------------------''',
        e,
        stackTrace,
      );
      throw Exception(_getUserFriendlyError(e));
    }
  }

  // ❌ SUPPRIMÉ - Cette méthode transformait les noms de critères
  // Les critères doivent être envoyés avec leurs noms exacts depuis l'API
  // Ancienne méthode _normaliserCriteres() supprimée car elle transformait:
  // - "Capital Assuré" → "capital"
  // - "Durée Cotisation" → "Durée de cotisation"
  // L'API attend maintenant les noms exacts sans transformation.

  Map<String, String> _maskHeaders(Map<String, String> input) {
    final Map<String, String> masked = Map<String, String>.from(input);
    if (masked.containsKey('Authorization')) {
      masked['Authorization'] = 'Bearer ***';
    }
    return masked;
  }

  String _prettyJson(dynamic data) {
    try {
      final encoder = const JsonEncoder.withIndent('  ');
      if (data is String) {
        final decoded = json.decode(data);
        return encoder.convert(decoded);
      }
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  dynamic _tryDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }

  String _prettyResponseBody(String body) {
    final decoded = _tryDecode(body);
    return _prettyJson(decoded);
  }

  void _logRequestChecklist(Map<String, dynamic> payload) {
    final missing = <String>[];
    if (!payload.containsKey('produit_id') || (payload['produit_id']?.toString().isEmpty ?? true)) {
      missing.add('produit_id');
    }
    if (!payload.containsKey('assure_est_souscripteur')) {
      missing.add('assure_est_souscripteur');
    }
    if (!payload.containsKey('criteres_utilisateur')) {
      missing.add('criteres_utilisateur');
    }
    final hasInfosAssure = payload['informations_assure'] != null;
    final checklist = {
      'present_fields': payload.keys.toList(),
      'missing_required_fields': missing,
      'has_informations_assure': hasInfosAssure,
      'criteres_keys': (payload['criteres_utilisateur'] is Map)
          ? (payload['criteres_utilisateur'] as Map).keys.toList()
          : [],
    };
    AppLogger.debug('[SIMULATION][REQUEST][CHECKLIST] ${_prettyJson(checklist)}');
  }

  Future<List<CritereTarification>> getCriteresProduit(
    String produitId, {
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/produits/$produitId/criteres')
          .replace(
            queryParameters: {
              'page': page.toString(),
              'limit': limit.toString(),
            },
          );

      final headers = {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> criteresJson = data['criteres'] ?? [];

        return criteresJson
            .map((json) => CritereTarification.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      AppLogger.errorWithStack(
        '''\n================= GET CRITERES PRODUIT - EXCEPTION ===========
PRODUIT_ID : $produitId
MESSAGE    : Erreur lors de la récupération des critères
DETAILS    : $e
TYPE       : ${e.runtimeType}
---------------------------------------------------------------''',
        e,
        stackTrace,
      );
      throw Exception(_getUserFriendlyError(e));
    }
  }

  Future<String?> getGrilleTarifaireForProduit(String produitId) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/grilles-tarifaires/produit/$produitId',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List grilles = data is List ? data : [];

        for (final grille in grilles) {
          final statut = grille['statut']?.toString().toLowerCase();
          if (statut == 'actif') {
            return grille['id']?.toString();
          }
        }

        if (grilles.isNotEmpty) {
          return grilles.first['id']?.toString();
        }

        return null;
      } else {
        throw Exception('Impossible de récupérer la grille tarifaire');
      }
    } catch (e, stackTrace) {
      AppLogger.errorWithStack(
        '''\n================= GET GRILLE TARIFAIRE - EXCEPTION ============
PRODUIT_ID : $produitId
MESSAGE    : Erreur lors de la récupération de la grille tarifaire
DETAILS    : $e
TYPE       : ${e.runtimeType}
---------------------------------------------------------------''',
        e,
        stackTrace,
      );
      throw Exception(_getUserFriendlyError(e));
    }
  }

  Future<void> sauvegarderDevis(SauvegardeDevisRequest request) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final url = '${ApiConfig.baseUrl}/devis-sauvegardes';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la sauvegarde');
      }
    } catch (e, stackTrace) {
      AppLogger.errorWithStack(
        '''\n================= SAUVEGARDER DEVIS - EXCEPTION ===============
DEVIS_ID : ${request.devisId}
MESSAGE  : Erreur lors de la sauvegarde du devis
DETAILS  : $e
TYPE     : ${e.runtimeType}
---------------------------------------------------------------''',
        e,
        stackTrace,
      );
      throw Exception(_getUserFriendlyError(e));
    }
  }

  Future<List<SimulationResponse>> getMesDevis({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}$_basePath/mes-devis?page=$page&limit=$limit',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> devisJson = data['devis'] ?? [];

        return devisJson
            .map((json) => SimulationResponse.fromJson(json))
            .toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors du chargement des devis',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.errorWithStack(
        '''\n================= GET MES DEVIS - EXCEPTION =================
PAGE     : $page
LIMIT    : $limit
MESSAGE  : Erreur lors du chargement des devis
DETAILS  : $e
TYPE     : ${e.runtimeType}
---------------------------------------------------------------''',
        e,
        stackTrace,
      );
      throw Exception(_getUserFriendlyError(e));
    }
  }

  Future<void> supprimerDevis(String devisId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_basePath/mes-devis/$devisId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors de la suppression',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.errorWithStack(
        '''\n================= SUPPRIMER DEVIS - EXCEPTION ===============
DEVIS_ID : $devisId
MESSAGE  : Erreur lors de la suppression du devis
DETAILS  : $e
TYPE     : ${e.runtimeType}
---------------------------------------------------------------''',
        e,
        stackTrace,
      );
      throw Exception(_getUserFriendlyError(e));
    }
  }

  String _getUserFriendlyError(dynamic error) {
    if (error is SocketException) {
      return 'Problème de connexion internet';
    } else if (error is FormatException) {
      return 'Erreur de format des données';
    } else if (error is HttpException) {
      return 'Erreur de communication avec le serveur';
    } else if (error is String) {
      if (error.contains('400')) return 'Données invalides';
      if (error.contains('401')) return 'Authentification requise';
      if (error.contains('404')) return 'Ressource non trouvée';
      if (error.contains('500')) return 'Erreur interne du serveur';
      return 'Une erreur est survenue';
    }
    return 'Une erreur inattendue est survenue';
  }
}
