import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/data/models/souscription_model.dart';
import 'package:saarflex_app/core/utils/api_config.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';

class souscriptionService {
  static const String _basePath = '/devis';

  Future<SouscriptionResponse> souscrire(SouscriptionRequest request) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}$_basePath/${request.devisId}/souscrire',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
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
    } catch (e) {
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
        '${ApiConfig.baseUrl}$_basePath?page=$page&limit=$limit',
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

      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/$id');

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

      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/$id/annuler');

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

    if (request.numeroTelephone.trim().isEmpty) {
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
