import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/simulation_model.dart';
import '../models/critere_tarification_model.dart';
import '../utils/api_config.dart';
import '../utils/storage_helper.dart';

class SimulationService {
  static const String _basePath = '/simulation-devis';

  Future<List<CritereTarification>> getCriteresProduit(
  String produitId, {
  int page = 1,
  int limit = 100,
}) async {
  try {
    final token = await StorageHelper.getToken();
    
    final url = Uri.parse('${ApiConfig.baseUrl}/produits/$produitId/criteres')
        .replace(queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        });
    
    
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
        
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
  final Map<String, dynamic> data = json.decode(response.body);
  final List<dynamic> criteresJson = data['criteres'] ?? [];
  
  return criteresJson
      .map((json) => CritereTarification.fromJson(json))
      .toList();
} else if (response.statusCode == 400) {
      throw Exception('Requête incorrecte: ${response.body}');
    } else if (response.statusCode == 401) {
      throw Exception('Authentification requise');
    } else if (response.statusCode == 404) {
      throw Exception('Produit non trouvé');
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  } on SocketException {
    throw Exception('Pas de connexion internet');
  } on FormatException {
    throw Exception('Format de réponse invalide');
  } catch (e) {
    throw Exception('Erreur lors du chargement des critères: $e');
  }
}

  Future<SimulationResponse> simulerDevis(SimulationRequest request) async {
    try {
         json.encode(request.toJson());

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_basePath/simuler'),

        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SimulationResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la simulation');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception('Erreur lors de la simulation: $e');
    }
  }

  Future<SimulationResponse> simulerDevisConnecte(SimulationRequest request) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_basePath/simuler-connecte'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SimulationResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la simulation');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception('Erreur lors de la simulation: $e');
    }
  }

  Future<void> sauvegarderDevis(SauvegardeDevisRequest request) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Vous devez être connecté pour sauvegarder un devis');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_basePath/sauvegarder'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la sauvegarde');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde: $e');
    }
  }

  Future<List<SimulationResponse>> getMesDevis({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Vous devez être connecté pour voir vos devis');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$_basePath/mes-devis?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> devisJson = data['devis'] ?? [];
        
        return devisJson
            .map((json) => SimulationResponse.fromJson(json))
            .toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors du chargement des devis');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception('Erreur lors du chargement des devis: $e');
    }
  }

  Future<void> supprimerDevis(String devisId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Vous devez être connecté');
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
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la suppression');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}