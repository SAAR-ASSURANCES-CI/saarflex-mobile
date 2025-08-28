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
        throw Exception('Requête incorrecte');
      } else if (response.statusCode == 401) {
        throw Exception('Authentification requise');
      } else if (response.statusCode == 404) {
        throw Exception('Produit non trouvé');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    }catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

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
        if (grilles.isNotEmpty) {
          return grilles.first['id'];
        }
        return null;
      } else {
        throw Exception('Impossible de récupérer la grille tarifaire');
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

  Future<String?> getGrilleTarifaireByProduitId(String produitId, Map<String, dynamic> criteresUtilisateur) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/grilles-tarifaires/produit/$produitId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> grilles = json.decode(response.body);

        final age = criteresUtilisateur['Age de l\'assuré']?.toString() ?? '';
        final typeAssure = criteresUtilisateur['Type d\'assuré']?.toString() ?? '';

        final grillesActives = grilles.where((grille) {
          final statut = grille['statut']?.toString() ?? '';
          final dateDebut = grille['date_debut'] != null ? DateTime.parse(grille['date_debut']) : null;
          final dateFin = grille['date_fin'] != null ? DateTime.parse(grille['date_fin']) : null;
          final now = DateTime.now();

          return statut == 'actif' &&
                 (dateDebut == null || now.isAfter(dateDebut)) &&
                 (dateFin == null || now.isBefore(dateFin));
        }).toList();

        for (final grille in grillesActives) {
          final nomGrille = grille['nom']?.toString().toLowerCase() ?? '';
          
          if (age.isNotEmpty && typeAssure.isNotEmpty) {
            if (nomGrille.contains(age) && nomGrille.contains(typeAssure.toLowerCase())) {
              return grille['id'];
            }
          }
        }

        for (final grille in grillesActives) {
          final nomGrille = grille['nom']?.toString().toLowerCase() ?? '';
          
          if (typeAssure.isNotEmpty && nomGrille.contains(typeAssure.toLowerCase())) {
            return grille['id'];
          }
          
          if (age.isNotEmpty && nomGrille.contains(age)) {
            return grille['id'];
          }
        }

        for (final grille in grillesActives) {
          final nomGrille = grille['nom']?.toString().toLowerCase() ?? '';
          
          if (nomGrille.contains('complet') || 
              nomGrille.contains('général') || 
              nomGrille.contains('standard')) {
            return grille['id'];
          }
        }

        if (grillesActives.isNotEmpty) {
          return grillesActives[0]['id'];
        }

        return null;
      } else {
        throw Exception('Erreur lors de la récupération des grilles tarifaires');
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

   Future<SimulationResponse> simulerDevis(SimulationRequest request) async {
    try {
      final requeteCorrigee = {
        'produit_id': request.produitId,
        'grille_tarifaire_id': request.produitId,
        'criteres_utilisateur': request.criteresUtilisateur,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/simulation-devis/simuler'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requeteCorrigee),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return SimulationResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Données invalides');
      } else {
        throw Exception('Erreur lors de la simulation');
      }
    }catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  Future<SimulationResponse> simulerDevisConnecte(SimulationRequest request) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final grilleTarifaireId = await getGrilleTarifaireByProduitId(
        request.produitId, 
        request.criteresUtilisateur
      );
      
      if (grilleTarifaireId == null) {
        throw Exception('Aucune grille tarifaire disponible pour ce produit');
      }

      final requete = {
        'produit_id': request.produitId,
        'grille_tarifaire_id': grilleTarifaireId,
        'criteres_utilisateur': request.criteresUtilisateur,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/simulation-devis/simuler-connecte'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requete),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SimulationResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Erreur lors de la simulation';
        
        throw Exception(errorMessage);
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
    }catch (e) {
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
    }catch (e) {
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
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }
}