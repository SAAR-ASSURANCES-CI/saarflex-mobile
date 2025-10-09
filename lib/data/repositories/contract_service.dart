import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/data/models/saved_quote_model.dart';
import 'package:saarflex_app/data/models/contract_model.dart';
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';
import 'package:saarflex_app/core/utils/logger.dart';

class ContractService {
  static final ContractService _instance = ContractService._internal();
  factory ContractService() => _instance;
  ContractService._internal();

  static String get baseUrl => ApiConstants.baseUrl;

  Future<Map<String, String>> get _authHeaders async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Récupère la liste des devis sauvegardés
  Future<List<SavedQuote>> getSavedQuotes({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('Récupération des devis sauvegardés...');

      final response = await http.get(
        Uri.parse('$baseUrl/devis-sauvegardes?page=$page&limit=$limit'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> quotesJson = data['data'] ?? data['devis'] ?? [];

        final quotes = quotesJson
            .map((json) => SavedQuote.fromJson(json))
            .toList();

        AppLogger.info('${quotes.length} devis sauvegardés récupérés');
        return quotes;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Erreur lors du chargement des devis sauvegardés',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Erreur lors de la récupération des devis sauvegardés: $e',
      );
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// Récupère la liste des contrats (quand l'endpoint sera disponible)
  Future<List<Contract>> getContracts({int page = 1, int limit = 20}) async {
    try {
      AppLogger.info('Récupération des contrats...');

      // Endpoint sera remplacé quand disponible
      // final response = await http.get(
      //   Uri.parse('$baseUrl/contrats?page=$page&limit=$limit'),
      //   headers: await _authHeaders,
      // );

      // Pour l'instant, retourner une liste vide
      AppLogger.info('Endpoint des contrats pas encore disponible');
      return [];
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des contrats: $e');
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  /// Supprime un devis sauvegardé
  Future<void> deleteSavedQuote(String quoteId) async {
    try {
      AppLogger.info('Suppression du devis $quoteId...');

      final response = await http.delete(
        Uri.parse('$baseUrl/devis-sauvegardes/$quoteId'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('Devis $quoteId supprimé avec succès');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors de la suppression du devis',
        );
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression du devis: $e');
      throw Exception('Erreur lors de la suppression: ${e.toString()}');
    }
  }

  /// Souscrit un devis (le transforme en contrat)
  Future<Contract> subscribeQuote(String quoteId) async {
    try {
      AppLogger.info('Souscription du devis $quoteId...');

      // Endpoint sera remplacé quand disponible
      // final response = await http.post(
      //   Uri.parse('$baseUrl/devis/$quoteId/souscrire'),
      //   headers: await _authHeaders,
      // );

      // Pour l'instant, simuler une souscription
      throw Exception('Fonctionnalité de souscription pas encore disponible');
    } catch (e) {
      AppLogger.error('Erreur lors de la souscription du devis: $e');
      throw Exception('Erreur lors de la souscription: ${e.toString()}');
    }
  }

  /// Met à jour un devis sauvegardé
  Future<SavedQuote> updateSavedQuote({
    required String quoteId,
    String? nomPersonnalise,
    String? notes,
  }) async {
    try {
      AppLogger.info('Mise à jour du devis $quoteId...');

      final response = await http.patch(
        Uri.parse('$baseUrl/devis-sauvegardes/$quoteId'),
        headers: await _authHeaders,
        body: json.encode({
          if (nomPersonnalise != null) 'nom_personnalise': nomPersonnalise,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quote = SavedQuote.fromJson(data['data'] ?? data);
        AppLogger.info('Devis $quoteId mis à jour avec succès');
        return quote;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors de la mise à jour du devis',
        );
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la mise à jour du devis: $e');
      throw Exception('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  /// Récupère les détails d'un devis sauvegardé
  Future<SavedQuote> getSavedQuoteDetails(String quoteId) async {
    try {
      AppLogger.info('Récupération des détails du devis $quoteId...');

      final response = await http.get(
        Uri.parse('$baseUrl/devis-sauvegardes/$quoteId'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quote = SavedQuote.fromJson(data['data'] ?? data);
        AppLogger.info('Détails du devis $quoteId récupérés');
        return quote;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors du chargement des détails',
        );
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des détails: $e');
      throw Exception('Erreur lors du chargement: ${e.toString()}');
    }
  }
}
