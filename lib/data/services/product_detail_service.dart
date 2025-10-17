import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/core/utils/api_config.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';
import 'package:saarflex_app/data/models/product_model.dart';

/// Service pour récupérer les détails d'un produit spécifique
class ProductDetailService {
  static const String _basePath = '/produits';

  /// Récupère les détails d'un produit par son ID
  Future<Product?> getProductById(String productId) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/$productId');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Product.fromJson(responseData);
      } else if (response.statusCode == 404) {
        return null; // Produit non trouvé
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du produit: ${e.toString()}',
      );
    }
  }

  /// Récupère les détails d'un produit par son nom
  Future<Product?> getProductByName(String productName) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath?nom=$productName');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List && responseData.isNotEmpty) {
          return Product.fromJson(responseData.first);
        }
        return null; // Aucun produit trouvé
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du produit: ${e.toString()}',
      );
    }
  }

  /// Récupère les détails d'un produit par son type
  Future<List<Product>> getProductsByType(String productType) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath?type=$productType');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List) {
          return responseData
              .map((json) => Product.fromJson(json))
              .where((product) => product.isActive)
              .toList();
        }
        return [];
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des produits: ${e.toString()}',
      );
    }
  }
}
