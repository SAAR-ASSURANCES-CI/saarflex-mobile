import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:saarciflex_app/data/models/saved_quote_model.dart';
import 'package:saarciflex_app/data/models/contract_model.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/core/utils/storage_helper.dart';

class ContractNotAvailableException implements Exception {
  final String message;
  ContractNotAvailableException(this.message);
  
  @override
  String toString() => message;
}

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

        List<dynamic> contractsJson;
        if (decodedData is List) {
          contractsJson = decodedData;
        } else if (decodedData is Map) {
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

  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
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
        return await getExternalStorageDirectory() ?? 
               await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  Future<File> _downloadAndSaveFile({
    required String url,
    required String fileName,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers ?? {},
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type']?.toLowerCase() ?? '';
        
        if (contentType.contains('application/json')) {
          String errorMessage = 'Le serveur a retourné une erreur au lieu du fichier PDF';
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? 
                          errorData['error'] ?? 
                          errorData['detail'] ??
                          errorMessage;
          } catch (e) {
            if (response.body.length < 200) {
              errorMessage = response.body;
            }
          }
          throw Exception(errorMessage);
        }
        
        if (response.bodyBytes.isNotEmpty && response.bodyBytes[0] == 123) {
          final firstChars = String.fromCharCodes(response.bodyBytes.take(10));
          if (firstChars.trim().startsWith('{')) {
            String errorMessage = 'Le serveur a retourné une erreur au lieu du fichier PDF';
            try {
              final errorData = json.decode(response.body);
              errorMessage = errorData['message'] ?? 
                            errorData['error'] ?? 
                            errorData['detail'] ??
                            errorMessage;
            } catch (e) {
              if (response.body.length < 200) {
                errorMessage = response.body;
              }
            }
            throw Exception(errorMessage);
          }
        }
        
        final directory = await _getDownloadsDirectory();
        final filePath = path.join(directory.path, fileName);
        final file = File(filePath);
        
        await file.writeAsBytes(response.bodyBytes);
        
        return file;
      } else {
        if (response.statusCode == 404) {
          try {
            if (response.body.isNotEmpty) {
              final errorData = json.decode(response.body);
              final message = errorData['message']?.toString().toLowerCase() ?? '';
              final errorText = errorData['error']?.toString().toLowerCase() ?? '';
              
              if (message.contains('non disponible') ||
                  message.contains('pas encore') ||
                  message.contains('not available') ||
                  message.contains('not found') ||
                  errorText.contains('not found') ||
                  errorText.contains('non disponible')) {
                throw ContractNotAvailableException(
                  'Ce contrat n\'est pas encore disponible. Vous recevrez un email lorsqu\'il sera prêt.'
                );
              }
            }
          } catch (e) {
            if (e is ContractNotAvailableException) {
              rethrow;
            }
            throw ContractNotAvailableException(
              'Ce contrat n\'est pas encore disponible. Vous recevrez un email lorsqu\'il sera prêt.'
            );
          }
        }
        
        String errorMessage = 'Erreur lors du téléchargement (Status: ${response.statusCode})';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            final message = errorData['message']?.toString().toLowerCase() ?? '';
            final errorText = errorData['error']?.toString().toLowerCase() ?? '';
            
            if (message.contains('non disponible') ||
                message.contains('pas encore') ||
                message.contains('not available') ||
                message.contains('en cours') ||
                message.contains('pending') ||
                errorText.contains('not available') ||
                errorText.contains('non disponible')) {
              throw ContractNotAvailableException(
                'Ce contrat n\'est pas encore disponible. Vous recevrez un email lorsqu\'il sera prêt.'
              );
            }
            
            errorMessage = errorData['message'] ?? 
                          errorData['error'] ?? 
                          errorMessage;
          }
        } catch (e) {
          if (e is ContractNotAvailableException) {
            rethrow;
          }
          if (response.body.isNotEmpty && response.body.length < 200) {
            errorMessage = response.body;
          }
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
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
      final url = '$baseUrl${ApiConstants.contratDocument(contractId)}';
      
      return await _downloadAndSaveFile(
        url: url,
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
      final url = '$baseUrl${ApiConstants.contratAttestation(contractId)}';
      
      return await _downloadAndSaveFile(
        url: url,
        fileName: fileName,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de l\'attestation: ${e.toString()}');
    }
  }

  Future<int> getActiveContractsCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.contratsCount}'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        int count = 0;
        if (data is int) {
          count = data;
        } else if (data is Map) {
          count = data['count'] ?? 
                  data['active_contracts'] ?? 
                  data['total'] ?? 
                  data['nombre'] ??
                  data['data'] ??
                  0;
          
          if (count == 0 && data['data'] is Map) {
            final innerData = data['data'] as Map;
            count = innerData['count'] ?? 
                   innerData['active_contracts'] ?? 
                   innerData['total'] ?? 
                   0;
          }
        } else if (data is String) {
          count = int.tryParse(data) ?? 0;
        }
        
        return count;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors du chargement du nombre de contrats actifs',
        );
      }
    } catch (e) {
      return 0;
    }
  }
}
