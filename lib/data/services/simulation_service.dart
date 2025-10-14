import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/core/utils/api_config.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';

class SimulationService {
  static const String _basePath = '/simulation-devis-simplifie';

  Future<SimulationResponse> simulerDevisSimplifie({
    required String produitId,
    required Map<String, dynamic> criteres,
    required bool assureEstSouscripteur,
    Map<String, dynamic>? informationsAssure,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/simulation-devis-simplifie');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final payload = {
        'produit_id': produitId,
        'assure_est_souscripteur': assureEstSouscripteur,
        'criteres_utilisateur': _normaliserCriteres(criteres),
      };

      if (!assureEstSouscripteur && informationsAssure != null) {
        payload['informations_assure'] = informationsAssure;
      }

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return SimulationResponse.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ??
            'Erreur de simulation (${response.statusCode})';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  Map<String, dynamic> _normaliserCriteres(
    Map<String, dynamic> criteresOriginaux,
  ) {
    final Map<String, dynamic> criteresNormalises = {};

    for (final entry in criteresOriginaux.entries) {
      final String key = entry.key;
      final dynamic value = entry.value;

      String cleNormalisee = key;

      if (key.toLowerCase().contains('capital')) {
        cleNormalisee = 'capital';
      } else if (key.toLowerCase().contains('durée') ||
          key.toLowerCase().contains('duree')) {
        cleNormalisee = 'Durée de cotisation';
      }

      dynamic valeurNormalisee = value;

      if (value is num) {
        valeurNormalisee = value.toString();
      } else if (value is String) {
        if (key.toLowerCase().contains('capital')) {
          valeurNormalisee = value.replaceAll(' ', '');
        }
      }

      criteresNormalises[cleNormalisee] = valeurNormalisee;
    }

    return criteresNormalises;
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
