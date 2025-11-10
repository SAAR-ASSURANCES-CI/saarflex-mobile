import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/data/models/simulation_model.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';

class SimulationService {

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
      url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.simulationBasePath}');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      payload = {
        'produit_id': produitId,
        'assure_est_souscripteur': assureEstSouscripteur,
        'criteres_utilisateur': criteres,
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
        final errorData = _tryDecode(response.body);
        final errorMessage =
            (errorData is Map && errorData['message'] != null)
                ? errorData['message']
                : 'Erreur de simulation (${response.statusCode})';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  dynamic _tryDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }

  Future<List<CritereTarification>> getCriteresProduit(
    String produitId, {
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsBasePath}/$produitId${ApiConstants.productCriteres}')
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
        '${ApiConstants.baseUrl}${ApiConstants.grillesTarifaires}/produit/$produitId',
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

      final url = '${ApiConstants.baseUrl}${ApiConstants.savedQuotes}';

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
          '${ApiConstants.baseUrl}${ApiConstants.simulationBasePath}/mes-devis?page=$page&limit=$limit',
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
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.simulationBasePath}/mes-devis/$devisId'),
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

  bool critereNecessiteFormatage(CritereTarification critere) {
    const champsAvecSeparateurs = [
      'capital',
      'capital_assure',
      'montant',
      'prime',
      'franchise',
      'plafond',
      'souscription',
      'assurance',
    ];

    final nomCritereLower = critere.nom.toLowerCase();

    for (final motCle in champsAvecSeparateurs) {
      if (nomCritereLower.contains(motCle)) {
        return true;
      }
    }

    return false;
  }

  Map<String, dynamic> nettoyerCriteres(
    Map<String, dynamic> criteres,
    List<CritereTarification> criteresProduit,
  ) {
    final criteresNettoyes = <String, dynamic>{};

    for (final critere in criteresProduit) {
      final valeur = criteres[critere.nom];
      if (valeur == null) continue;

      if (critere.type == TypeCritere.numerique &&
          critereNecessiteFormatage(critere) &&
          valeur is String) {
        final valeurNettoyee = valeur.toString().replaceAll(RegExp(r'[^\d]'), '');
        criteresNettoyes[critere.nom] = num.tryParse(valeurNettoyee) ?? 0;
      } else {
        criteresNettoyes[critere.nom] = valeur;
      }
    }

    return criteresNettoyes;
  }

  String? validateCritere(
    CritereTarification critere,
    dynamic valeur,
  ) {
    if (critere.obligatoire &&
        (valeur == null || valeur.toString().trim().isEmpty)) {
      return 'Ce champ est obligatoire';
    }

    switch (critere.type) {
      case TypeCritere.numerique:
        if (valeur != null && valeur.toString().isNotEmpty) {
          String valeurString = valeur.toString();

          if (critereNecessiteFormatage(critere)) {
            valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
          }

          final numericValue = num.tryParse(valeurString);
          if (numericValue == null) {
            return 'Veuillez entrer un nombre valide';
          }

          for (final valeurCritere in critere.valeurs) {
            if (valeurCritere.valeurMin != null &&
                numericValue.toDouble() < valeurCritere.valeurMin!) {
              return 'Valeur minimum: ${valeurCritere.valeurMin}';
            }
            if (valeurCritere.valeurMax != null &&
                numericValue.toDouble() > valeurCritere.valeurMax!) {
              return 'Valeur maximum: ${valeurCritere.valeurMax}';
            }
          }
        }
        break;

      case TypeCritere.categoriel:
        if (valeur != null && critere.hasValeurs) {
          if (!critere.valeursString.contains(valeur.toString())) {
            return 'Valeur non autorisée';
          }
        }
        break;

      case TypeCritere.booleen:
        break;
    }

    return null;
  }

  Map<String, String> validateAllCriteres(
    Map<String, dynamic> criteresReponses,
    List<CritereTarification> criteresProduit,
  ) {
    final errors = <String, String>{};

    for (final critere in criteresProduit) {
      final valeur = criteresReponses[critere.nom];
      final error = validateCritere(critere, valeur);
      if (error != null) {
        errors[critere.nom] = error;
      }
    }

    return errors;
  }

  bool isSaarNansou(String? produitId) {
    const saarNansouId = '5a024ee8-6e8c-4cce-88a4-00b998248604';
    return produitId == saarNansouId;
  }

  int? calculerDureeAuto(int age) {
    if (age >= 40 && age <= 68) return 10;
    if (age >= 69 && age <= 71) return 5;
    if (age >= 72 && age <= 75) return 2;
    return null;
  }

  int calculerAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  DateTime? parseBirthDate(dynamic dateNaissance) {
    if (dateNaissance == null) return null;

    if (dateNaissance is DateTime) {
      return dateNaissance;
    }

    if (dateNaissance is String) {
      DateTime? birthDate = DateTime.tryParse(dateNaissance);
      if (birthDate != null) return birthDate;

      final parts = dateNaissance.split('-');
      if (parts.length == 3) {
        try {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        } catch (e) {
          return null;
        }
      }
    }

    return null;
  }

  String? formatBirthDateForApi(DateTime? birthDate) {
    if (birthDate == null) return null;

    final day = birthDate.day.toString().padLeft(2, '0');
    final month = birthDate.month.toString().padLeft(2, '0');
    return '$day-$month-${birthDate.year}';
  }

  Map<String, dynamic>? nettoyerInformationsAssure(
    Map<String, dynamic>? informationsAssure,
  ) {
    if (informationsAssure == null) return null;

    final informationsNettoyees = Map<String, dynamic>.from(informationsAssure);

    if (informationsNettoyees.containsKey('date_naissance')) {
      final dateNaissance = informationsNettoyees['date_naissance'];
      if (dateNaissance is DateTime) {
        informationsNettoyees['date_naissance'] =
            formatBirthDateForApi(dateNaissance);
      } else if (dateNaissance is String) {
        final parsed = parseBirthDate(dateNaissance);
        if (parsed != null) {
          informationsNettoyees['date_naissance'] =
              formatBirthDateForApi(parsed);
        }
      }
    }

    return informationsNettoyees;
  }
}
