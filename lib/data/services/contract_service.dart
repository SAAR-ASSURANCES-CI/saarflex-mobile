import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/data/models/saved_quote_model.dart';
import 'package:saarflex_app/data/models/contract_model.dart';
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';

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

  Future<List<SavedQuote>> getSavedQuotes({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.savedQuotes}?page=$page&limit=$limit'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> quotesJson = data['data'] ?? data['devis'] ?? [];

        final quotes = quotesJson
            .map((json) => SavedQuote.fromJson(json))
            .toList();

        return quotes;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Erreur lors du chargement des devis sauvegardés',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  Future<List<Contract>> getContracts({int page = 1, int limit = 20}) async {
    try {
      return [];
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  Future<void> deleteSavedQuote(String quoteId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiConstants.savedQuotes}/$quoteId'),
        headers: await _authHeaders,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors de la suppression du devis',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression: ${e.toString()}');
    }
  }

  Future<Contract> subscribeQuote(String quoteId) async {
    try {
      throw Exception('Fonctionnalité de souscription pas encore disponible');
    } catch (e) {
      throw Exception('Erreur lors de la souscription: ${e.toString()}');
    }
  }

  Future<SavedQuote> updateSavedQuote({
    required String quoteId,
    String? nomPersonnalise,
    String? notes,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${ApiConstants.savedQuotes}/$quoteId'),
        headers: await _authHeaders,
        body: json.encode({
          if (nomPersonnalise != null) 'nom_personnalise': nomPersonnalise,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quote = SavedQuote.fromJson(data['data'] ?? data);
        return quote;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors de la mise à jour du devis',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  Future<SavedQuote> getSavedQuoteDetails(String quoteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.savedQuotes}/$quoteId'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quote = SavedQuote.fromJson(data['data'] ?? data);
        return quote;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors du chargement des détails',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement: ${e.toString()}');
    }
  }
}
