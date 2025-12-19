import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:saarciflex_app/data/models/saved_quote_model.dart';
import 'package:saarciflex_app/data/models/contract_model.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/core/utils/storage_helper.dart';

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
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.contrats}?page=$page&limit=$limit'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // Handle different response structures
        List<dynamic> contractsJson;
        if (decodedData is List) {
          // Response is directly a list
          contractsJson = decodedData;
        } else if (decodedData is Map) {
          // Response is an object with data/contrats key
          final dataValue = decodedData['data'] ?? decodedData['contrats'];
          if (dataValue is List) {
            contractsJson = dataValue;
          } else {
            contractsJson = [];
          }
        } else {
          contractsJson = [];
        }

        final contracts = contractsJson
            .map((json) => Contract.fromJson(json as Map<String, dynamic>))
            .toList();

        return contracts;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Erreur lors du chargement des contrats',
        );
      }
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

  /// Get the Downloads directory on the phone (accessible externally)
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // For Android, use external storage Downloads directory
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Navigate to Downloads folder
        final downloadsPath = path.join(
          externalDir.path.split('Android')[0],
          'Download',
        );
        final directory = Directory(downloadsPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return directory;
      } else {
        // Fallback to external storage root
        return await getExternalStorageDirectory() ?? 
               await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      // For iOS, use Documents directory (accessible via Files app)
      return await getApplicationDocumentsDirectory();
    } else {
      // Fallback for other platforms
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Download a file and save it to the phone's Downloads directory
  Future<File> _downloadAndSaveFile({
    required String url,
    required String fileName,
    Map<String, String>? headers,
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: headers ?? {},
    );

    if (response.statusCode == 200) {
      final directory = await _getDownloadsDirectory();
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ?? 'Erreur lors du téléchargement',
      );
    }
  }

  Future<File> downloadContractDocument(String contractId, String numeroContrat) async {
    try {
      final token = await StorageHelper.getToken();
      final headers = {
        'Accept': 'application/pdf, application/octet-stream, */*',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final fileName = 'contrat_${numeroContrat.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';
      
      return await _downloadAndSaveFile(
        url: '$baseUrl${ApiConstants.contratDocument(contractId)}',
        fileName: fileName,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Erreur lors du téléchargement du contrat: ${e.toString()}');
    }
  }

  Future<File> downloadAttestationSouscription(String contractId, String numeroContrat) async {
    try {
      final token = await StorageHelper.getToken();
      final headers = {
        'Accept': 'application/pdf, application/octet-stream, */*',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final fileName = 'attestation_souscription_${numeroContrat.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';
      
      // TODO: Remplacer par le bon endpoint quand vous l'aurez
      return await _downloadAndSaveFile(
        url: '$baseUrl${ApiConstants.contratAttestation(contractId)}',
        fileName: fileName,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de l\'attestation: ${e.toString()}');
    }
  }
}
