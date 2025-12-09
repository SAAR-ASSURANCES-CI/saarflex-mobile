import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:saarflex_app/data/models/souscription_model.dart';
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';

class souscriptionService {
  String _mapMethodePaiement(String methodePaiement) {
    if (methodePaiement == 'wave') {
      return 'wallet';
    }
    return 'mobile_money';
  }

  Future<SouscriptionResponse> souscrire(SouscriptionRequest request) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.souscriptionBasePath}/${request.devisId}/souscrire',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final requestBody = request.toJson();
      requestBody['methode_paiement'] = _mapMethodePaiement(request.methodePaiement);
      requestBody['currency'] = request.currency;

      // TODO: Retirer les logs quand le diagnostic est terminé.
      final sanitizedHeaders = Map<String, String>.from(headers);
      sanitizedHeaders.remove('Authorization');
      developer.log(
        'Souscription request\nURL: $url\nHeaders: $sanitizedHeaders\nBody: ${json.encode(requestBody)}',
        name: 'SouscriptionService',
      );

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody),
      );

      // TODO: Retirer les logs quand le diagnostic est terminé.
      developer.log(
        'Souscription response\nStatus: ${response.statusCode}\nBody: ${response.body}',
        name: 'SouscriptionService',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return SouscriptionResponse.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ??
            'Erreur lors de la souscription (${response.statusCode})';
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      // TODO: Retirer les logs quand le diagnostic est terminé.
      developer.log(
        'Souscription error',
        name: 'SouscriptionService',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(_getUserFriendlyError(e));
    }
  }

  Future<List<SouscriptionResponse>> getMesSouscriptions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.souscriptionBasePath}?page=$page&limit=$limit',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> souscriptions = responseData['data'] ?? [];

        return souscriptions
            .map((json) => SouscriptionResponse.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des souscriptions');
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  Future<SouscriptionResponse> getSouscriptionById(String id) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.souscriptionBasePath}/$id');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return SouscriptionResponse.fromJson(responseData);
      } else {
        throw Exception('Souscription non trouvée');
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  Future<void> annulerSouscription(String id) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.souscriptionBasePath}/$id/annuler');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.put(url, headers: headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de l\'annulation');
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  bool validatesouscriptionData(SouscriptionRequest request) {
    if (request.devisId.trim().isEmpty) {
      return false;
    }

    if (request.methodePaiement.trim().isEmpty) {
      return false;
    }

    // Numéro de téléphone requis seulement pour mobile_money
    final mappedMethode = _mapMethodePaiement(request.methodePaiement);
    if (mappedMethode == 'mobile_money' && 
        (request.numeroTelephone == null || request.numeroTelephone!.trim().isEmpty)) {
      return false;
    }

    if (request.beneficiaires.isEmpty) {
      return false;
    }

    for (final beneficiaire in request.beneficiaires) {
      if (!beneficiaire.isValid) {
        return false;
      }
    }

    return true;
  }

  String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.startsWith('77') ||
        cleanPhone.startsWith('78') ||
        cleanPhone.startsWith('76') ||
        cleanPhone.startsWith('70')) {
      return '+221$cleanPhone';
    }

    if (cleanPhone.startsWith('221')) {
      return '+$cleanPhone';
    }

    return cleanPhone;
  }

  String _getUserFriendlyError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Pas de connexion internet';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'Délai d\'attente dépassé';
    }

    if (error.toString().contains('FormatException')) {
      return 'Erreur de format des données';
    }

    return error.toString();
  }
}
