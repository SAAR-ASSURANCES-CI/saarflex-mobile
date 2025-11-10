import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';
import 'package:saarflex_app/data/models/product_model.dart';

class ProductDetailService {
  Future<Product?> getProductById(String productId) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsBasePath}/$productId');

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
        return null;
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

  Future<Product?> getProductByName(String productName) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsBasePath}?nom=$productName');

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
        return null;
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

  Future<List<Product>> getProductsByType(String productType) async {
    try {
      final token = await StorageHelper.getToken();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsBasePath}?type=$productType');

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
