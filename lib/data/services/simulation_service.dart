import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarciflex_app/data/models/simulation_model.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/core/utils/storage_helper.dart';
import 'package:saarciflex_app/data/services/api_service.dart';

class SimulationService {

  Future<SimulationResponse> simulerDevisSimplifie({
    required String produitId,
    required Map<String, dynamic> criteres,
    required bool assureEstSouscripteur,
    Map<String, dynamic>? informationsAssure,
    Map<String, dynamic>? informationsVehicule,
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

      if (informationsVehicule != null && informationsVehicule.isNotEmpty) {
        payload['informations_vehicule'] = informationsVehicule;
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
        final errorMessage = (errorData is Map && errorData['message'] != null)
            ? errorData['message'].toString()
            : 'Erreur de simulation (${response.statusCode})';

        throw ApiException(errorMessage, response.statusCode);
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
    // Connexion réseau absente ou instable
    if (error is SocketException) {
      return 'Connexion impossible. Vérifiez votre connexion internet et réessayez.';
    } else if (error is TimeoutException) {
      return 'Connexion instable ou serveur lent. Réessayez dans un instant.';
    } else if (error is FormatException) {
      return 'Données reçues dans un format inattendu. Réessayez.';
    } else if (error is HttpException) {
      return 'Erreur de communication avec le serveur. Réessayez.';
    } else if (error is ApiException) {
      final status = error.statusCode;
      final message = error.message.toLowerCase();

      if (status != null && status >= 500) {
        return 'Service temporairement indisponible. Réessayez dans quelques instants.';
      }

      if (status == 404) {
        if (message.contains('aucun tarif')) {
          return 'Aucun tarif disponible pour ces paramètres. Ajustez vos choix (âge, capital, durée) puis réessayez.';
        }
        return 'Ressource non trouvée. Réessayez ou contactez le support.';
      }

      if (status == 400 || status == 422) {
        return 'Données invalides. Vérifiez les champs et réessayez.';
      }

      if (status == 401) {
        return 'Session expirée ou non authentifiée. Connectez-vous puis réessayez.';
      }

      if (status == 429) {
        return 'Trop de demandes. Patientez puis réessayez.';
      }

      return error.message;
    } else if (error is String) {
      if (error.contains('400')) return 'Données invalides';
      if (error.contains('401')) {
        return 'Session expirée ou non authentifiée. Connectez-vous puis réessayez.';
      }
      if (error.contains('404')) {
        if (error.toLowerCase().contains('aucun tarif')) {
          return 'Aucun tarif disponible pour ces paramètres. Ajustez vos choix puis réessayez.';
        }
        return 'Ressource non trouvée';
      }
      if (error.contains('500')) {
        return 'Service temporairement indisponible. Réessayez dans quelques instants.';
      }
      return 'Une erreur est survenue. Réessayez.';
    }
    return 'Une erreur inattendue est survenue. Réessayez.';
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

      // Détection automatique : si c'est un texte qui contient "expir", traiter comme date
      final isDateField = critere.type == TypeCritere.date ||
          (critere.type == TypeCritere.texte &&
              (critere.nom.toLowerCase().contains('expir') ||
               critere.nom.toLowerCase().contains('expiration') ||
               critere.nom.toLowerCase().contains('date')));

      if (critere.type == TypeCritere.numerique &&
          critereNecessiteFormatage(critere) &&
          valeur is String) {
        final valeurNettoyee = valeur.toString().replaceAll(RegExp(r'[^\d]'), '');
        criteresNettoyes[critere.nom] = num.tryParse(valeurNettoyee) ?? 0;
      } else if (isDateField) {
        // Formater la date au format DD-MM-YYYY pour l'API
        if (valeur is DateTime) {
          criteresNettoyes[critere.nom] = formatBirthDateForApi(valeur);
        } else if (valeur is String) {
          final parsed = parseBirthDate(valeur);
          if (parsed != null) {
            criteresNettoyes[critere.nom] = formatBirthDateForApi(parsed);
          } else {
            criteresNettoyes[critere.nom] = valeur;
          }
        } else {
          criteresNettoyes[critere.nom] = valeur;
        }
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
            // Pour les champs avec formatage (capital, prime, etc.), on enlève tous les séparateurs
            valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
          } else {
            // Pour les autres critères numériques, on normalise la virgule en point
            // pour accepter les deux formats (1.5 ou 1,5)
            valeurString = valeurString.replaceAll(',', '.').replaceAll(' ', '');
          }

          final numericValue = num.tryParse(valeurString);
          if (numericValue == null) {
            return 'Veuillez entrer un nombre valide';
          }

          num? minGlobal;
          num? maxGlobal;

          for (final valeurCritere in critere.valeurs) {
            if (valeurCritere.valeurMin != null) {
              minGlobal = minGlobal == null
                  ? valeurCritere.valeurMin
                  : (valeurCritere.valeurMin! < minGlobal ? valeurCritere.valeurMin : minGlobal);
            }
            if (valeurCritere.valeurMax != null) {
              maxGlobal = maxGlobal == null
                  ? valeurCritere.valeurMax
                  : (valeurCritere.valeurMax! > maxGlobal ? valeurCritere.valeurMax : maxGlobal);
            }
          }

          if (minGlobal != null && numericValue.toDouble() < minGlobal) {
            return 'Valeur minimum: $minGlobal';
          }
          if (maxGlobal != null && numericValue.toDouble() > maxGlobal) {
            return 'Valeur maximum: $maxGlobal';
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

      case TypeCritere.date:
        if (valeur != null && valeur.toString().isNotEmpty) {
          // Vérifier que c'est une date valide
          final parsedDate = parseBirthDate(valeur);
          if (parsedDate == null) {
            return 'Veuillez entrer une date valide (format: DD-MM-YYYY)';
          }
          // Pour une date d'expiration de passeport, on peut vérifier qu'elle est dans le futur
          // mais on ne le fait que si c'est explicitement demandé
        }
        break;

      case TypeCritere.texte:
        // Détection automatique : si c'est un texte qui contient "expir", valider comme date
        final isDateField = critere.nom.toLowerCase().contains('expir') ||
            critere.nom.toLowerCase().contains('expiration') ||
            critere.nom.toLowerCase().contains('date');
        
        if (isDateField && valeur != null && valeur.toString().isNotEmpty) {
          // Vérifier que c'est une date valide
          final parsedDate = parseBirthDate(valeur);
          if (parsedDate == null) {
            return 'Veuillez entrer une date valide (format: DD-MM-YYYY)';
          }
        }
        // Pour le texte libre normal (comme numéro de passeport), pas de validation spécifique
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

  Future<int?> calculerDureeAutoFromApi(String produitId, int age) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.produitDureeCotisation(produitId, age)}',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('API call timeout after 30 seconds');
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          // Support multiple formats: "duree" or "duree_cotisation"
          final duree = data['duree'] ?? data['duree_cotisation'];
          if (duree != null) {
            return duree is int ? duree : int.tryParse(duree.toString());
          }
          return null;
        } catch (e) {
          // Erreur de parsing JSON
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      // Erreur silencieuse - on utilisera le fallback si disponible
      return null;
    }
  }

  Future<int?> calculerDureeAuto(int age, {String? produitId}) async {
    // Essayer d'abord l'API si produitId est fourni
    if (produitId != null) {
      try {
        final dureeFromApi = await calculerDureeAutoFromApi(produitId, age);
        if (dureeFromApi != null) {
          return dureeFromApi;
        }
      } catch (e) {
        // En cas d'erreur, continuer avec le fallback si disponible
      }
    }
    
    // Fallback vers la logique statique (commenté - l'API est maintenant la source principale)
    // Si l'API échoue ou si produitId n'est pas fourni, on retourne null
    // Pour réactiver le fallback, décommenter le code ci-dessous :
    /*
    if (age >= 18 && age <= 68) return 10;
    if (age >= 69 && age <= 71) return 5;
    if (age >= 72 && age <= 75) return 2;
    */
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
