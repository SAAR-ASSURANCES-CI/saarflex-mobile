import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/simulation_model.dart';
import '../models/critere_tarification_model.dart';
import '../utils/api_config.dart';
import '../utils/storage_helper.dart';

class SimulationService {
  static const String _basePath = '/simulation-devis';

  // MÉTHODE UNIFIÉE POUR TOUS LES UTILISATEURS
Future<SimulationResponse> simulerDevis(SimulationRequest request) async {
  try {
    final token = await StorageHelper.getToken();
    
    final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/simuler-connecte');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final requete = {
      'produit_id': request.produitId,
      'grille_tarifaire_id': request.grilleTarifaireId,
      'criteres_utilisateur': request.criteresUtilisateur,
    };

    // LOGS DE DEBUG
    print('=== DEBUG SIMULATION ===');
    print('URL: $url');
    print('Headers: $headers');
    print('Produit ID: ${request.produitId}');
    print('Grille ID: ${request.grilleTarifaireId}');
    print('Critères: ${request.criteresUtilisateur}');
    print('Token présent: ${token != null}');
    print('=======================');

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(requete),
    );

    // LOG DE LA RÉPONSE
    print('=== RÉPONSE SERVEUR ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('=======================');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SimulationResponse.fromJson(data);
    } else {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Erreur lors de la simulation';
      throw Exception(errorMessage);
    }
  } catch (e) {
    // LOG DES ERREURS
    print('=== ERREUR SIMULATION ===');
    print('Erreur: $e');
    print('Stack: ${e is Error ? (e).stackTrace : ''}');
    print('=======================');
    throw Exception(_getUserFriendlyError(e));
  }
}

  // Future<SimulationResponse> simulerDevis(SimulationRequest request) async {
  //   try {
  //     final token = await StorageHelper.getToken();
      
  //     final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/simuler');
      
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       if (token != null) 'Authorization': 'Bearer $token',
  //     };

  //     final requete = {
  //       'produit_id': request.produitId,
  //       'grille_tarifaire_id': request.grilleTarifaireId,
  //       'criteres_utilisateur': request.criteresUtilisateur,
  //     };

  //     final response = await http.post(
  //       url,
  //       headers: headers,
  //       body: json.encode(requete),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return SimulationResponse.fromJson(data);
  //     } else {
  //       final errorData = json.decode(response.body);
  //       final errorMessage = errorData['message'] ?? 'Erreur lors de la simulation';
  //       throw Exception(errorMessage);
  //     }
  //   } catch (e) {
  //     throw Exception(_getUserFriendlyError(e));
  //   }
  // }

  // MÉTHODE DE SAUVEGARDE
  Future<void> sauvegarderDevis(SauvegardeDevisRequest request) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
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
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  // RÉCUPÉRATION DES CRITÈRES
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
        throw Exception('Requête incorrecte');
      } else if (response.statusCode == 401) {
        throw Exception('Authentification requise');
      } else if (response.statusCode == 404) {
        throw Exception('Produit non trouvé');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  // RÉCUPÉRATION SIMPLIFIÉE DES GRILLES TARIFAIRES
  Future<String?> getGrilleTarifaireForProduit(String produitId) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/produits/$produitId/grilles');
      
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List grilles = data['grilles'] ?? [];
        
        // SIMPLIFICATION : Retourne la première grille active, ou la première tout court
        for (final grille in grilles) {
          final statut = grille['statut']?.toString().toLowerCase();
          if (statut == 'actif') {
            return grille['id']?.toString();
          }
        }
        
        // Fallback : première grille si aucune active
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

  // RÉCUPÉRATION DES DEVIS SAUVEGARDÉS
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
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  // SUPPRESSION DE DEVIS
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
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  // MÉTHODE UTILITAIRE POUR LES MESSAGES D'ERREUR
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