import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/data/models/beneficiaire_model.dart';
import 'package:saarflex_app/core/utils/api_config.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';
import 'package:saarflex_app/core/utils/logger.dart';

class BeneficiaireService {
  static const String _basePath = '/beneficiaires';

  Future<String?> _getToken() async {
    return await StorageHelper.getToken();
  }

  Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Créer un nouveau bénéficiaire
  Future<Beneficiaire> createBeneficiaire({
    required String nomComplet,
    required String lienSouscripteur,
    required int ordre,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath');

      final payload = {
        'nom_complet': nomComplet,
        'lien_souscripteur': lienSouscripteur,
        'ordre': ordre,
      };

      AppLogger.api('Création bénéficiaire - URL: $url');
      AppLogger.api('Payload: ${json.encode(payload)}');

      final response = await http.post(
        url,
        headers: await _authHeaders,
        body: json.encode(payload),
      );

      AppLogger.api(
        'Réponse création bénéficiaire - Status: ${response.statusCode}',
      );
      AppLogger.api('Réponse création bénéficiaire - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Beneficiaire.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors de la création du bénéficiaire',
        );
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      AppLogger.error('Erreur création bénéficiaire: $e');
      throw Exception(
        'Erreur lors de la création du bénéficiaire: ${e.toString()}',
      );
    }
  }

  /// Créer plusieurs bénéficiaires un par un
  Future<List<Beneficiaire>> createBeneficiaires({
    required List<Map<String, dynamic>> beneficiairesData,
  }) async {
    try {
      final List<Beneficiaire> createdBeneficiaires = [];

      for (final beneficiaireData in beneficiairesData) {
        final beneficiaire = await createBeneficiaire(
          nomComplet: beneficiaireData['nom_complet'],
          lienSouscripteur: beneficiaireData['lien_souscripteur'],
          ordre: beneficiaireData['ordre'],
        );
        createdBeneficiaires.add(beneficiaire);
      }

      AppLogger.info(
        'Bénéficiaires créés individuellement: ${createdBeneficiaires.length}',
      );
      return createdBeneficiaires;
    } catch (e) {
      AppLogger.error('Erreur création multiple bénéficiaires: $e');
      throw Exception(
        'Erreur lors de la création des bénéficiaires: ${e.toString()}',
      );
    }
  }

  /// Récupérer tous les bénéficiaires d'un contrat/simulation
  Future<List<Beneficiaire>> getBeneficiaires({
    String? contratId,
    String? simulationId,
  }) async {
    try {
      String url = '${ApiConfig.baseUrl}$_basePath';

      if (contratId != null) {
        url += '?contrat_id=$contratId';
      } else if (simulationId != null) {
        url += '?simulation_id=$simulationId';
      }

      AppLogger.api('Récupération bénéficiaires - URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders,
      );

      AppLogger.api('Réponse récupération - Status: ${response.statusCode}');
      AppLogger.api('Réponse récupération - Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> beneficiairesJson = responseData['data'] ?? [];
        return beneficiairesJson
            .map((json) => Beneficiaire.fromJson(json))
            .toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Erreur lors de la récupération des bénéficiaires',
        );
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      AppLogger.error('Erreur récupération bénéficiaires: $e');
      throw Exception(
        'Erreur lors de la récupération des bénéficiaires: ${e.toString()}',
      );
    }
  }

  /// Mettre à jour un bénéficiaire
  Future<Beneficiaire> updateBeneficiaire({
    required String beneficiaireId,
    required String nomComplet,
    required String lienSouscripteur,
    required int ordre,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/$beneficiaireId');

      final payload = {
        'nom_complet': nomComplet,
        'lien_souscripteur': lienSouscripteur,
        'ordre': ordre,
      };

      AppLogger.api('Mise à jour bénéficiaire - URL: $url');
      AppLogger.api('Payload: ${json.encode(payload)}');

      final response = await http.put(
        url,
        headers: await _authHeaders,
        body: json.encode(payload),
      );

      AppLogger.api('Réponse mise à jour - Status: ${response.statusCode}');
      AppLogger.api('Réponse mise à jour - Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Beneficiaire.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Erreur lors de la mise à jour du bénéficiaire',
        );
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      AppLogger.error('Erreur mise à jour bénéficiaire: $e');
      throw Exception(
        'Erreur lors de la mise à jour du bénéficiaire: ${e.toString()}',
      );
    }
  }

  /// Supprimer un bénéficiaire
  Future<void> deleteBeneficiaire(String beneficiaireId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/$beneficiaireId');

      AppLogger.api('Suppression bénéficiaire - URL: $url');

      final response = await http.delete(url, headers: await _authHeaders);

      AppLogger.api('Réponse suppression - Status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Erreur lors de la suppression du bénéficiaire',
        );
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      AppLogger.error('Erreur suppression bénéficiaire: $e');
      throw Exception(
        'Erreur lors de la suppression du bénéficiaire: ${e.toString()}',
      );
    }
  }

  /// Valider les données d'un bénéficiaire côté client
  List<String> validateBeneficiaire({
    required String nomComplet,
    required String lienSouscripteur,
    required int ordre,
  }) {
    final errors = <String>[];

    if (nomComplet.trim().isEmpty) {
      errors.add('Le nom complet est obligatoire');
    } else if (nomComplet.length > 255) {
      errors.add('Le nom complet ne peut pas dépasser 255 caractères');
    }

    if (lienSouscripteur.trim().isEmpty) {
      errors.add('Le lien avec le souscripteur est obligatoire');
    } else if (lienSouscripteur.length > 100) {
      errors.add('Le lien ne peut pas dépasser 100 caractères');
    }

    if (ordre < 1 || ordre > 3) {
      errors.add('L\'ordre doit être entre 1 et 3');
    }

    return errors;
  }

  /// Valider une liste de bénéficiaires
  List<String> validateBeneficiairesList(List<Beneficiaire> beneficiaires) {
    final errors = <String>[];

    if (beneficiaires.length > 3) {
      errors.add('Le nombre maximum de bénéficiaires est de 3');
    }

    for (int i = 0; i < beneficiaires.length; i++) {
      final beneficiaire = beneficiaires[i];
      final beneficiaireErrors = beneficiaire.validationErrors;
      for (final error in beneficiaireErrors) {
        errors.add('Bénéficiaire ${i + 1}: $error');
      }
    }

    // Vérifier les ordres uniques
    final ordres = beneficiaires.map((b) => b.ordre).toList();
    final ordresUniques = ordres.toSet();
    if (ordres.length != ordresUniques.length) {
      errors.add('Les ordres des bénéficiaires doivent être uniques');
    }

    return errors;
  }
}
