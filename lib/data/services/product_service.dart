import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/data/models/critere_tarification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:saarciflex_app/data/models/product_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();
  static const Uuid _uuid = Uuid();

  static final String baseUrl = ApiConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Product>> fetchProductsFromApi() async {
    try {
      final url = '$baseUrl/produits';

      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final products = jsonData
            .map((json) => Product.fromJson(json))
            .where((product) => product.isActive)
            .toList();
        return products;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      throw Exception('Erreur lors de la récupération: ${e.toString()}');
    }
  }

  Future<List<Product>> getAllProducts() async {
    return await fetchProductsFromApi();
  }

  Future<List<Product>> getProductsByType(ProductType type) async {
    final products = await fetchProductsFromApi();
    return products.where((product) => product.type == type).toList();
  }

  Future<Product?> getProductById(String id) async {
    final products = await fetchProductsFromApi();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return getAllProducts();

    final products = await fetchProductsFromApi();
    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      return product.nom.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery) ||
          product.typeLabel.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<Product>> filterProducts({
    ProductType? type,
    String? searchQuery,
  }) async {
    List<Product> filteredProducts = await fetchProductsFromApi();

    if (type != null) {
      filteredProducts = filteredProducts
          .where((product) => product.type == type)
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      filteredProducts = filteredProducts.where((product) {
        return product.nom.toLowerCase().contains(lowerQuery) ||
            product.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return filteredProducts;
  }

  Future<Map<ProductType, int>> getProductCountByType() async {
    final products = await fetchProductsFromApi();
    final Map<ProductType, int> count = {};
    for (ProductType type in ProductType.values) {
      count[type] = products.where((product) => product.type == type).length;
    }
    return count;
  }

  Future<bool> productExists(String id) async {
    final products = await fetchProductsFromApi();
    return products.any((product) => product.id == id);
  }

  Future<List<Product>> getFeaturedProducts({int limit = 3}) async {
    final products = await fetchProductsFromApi();
    return products.take(limit).toList();
  }

  Future<List<CritereTarification>> getProductCriteres(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsBasePath}/$productId${ApiConstants.productCriteres}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> criteresJson = data['criteres'] ?? [];

        return criteresJson
            .map((json) => CritereTarification.fromJson(json))
            .toList();
      } else {
        throw Exception('Produit non trouvé ou critères indisponibles');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des critères: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGrillesTarifaires(
    String productId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.productsBasePath}/$productId/${ApiConstants.grillesTarifaires}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['grilles'] ?? []);
      } else {
        return _generateDefaultGrille(productId);
      }
    } catch (e) {
      return _generateDefaultGrille(productId);
    }
  }

  List<Map<String, dynamic>> _generateDefaultGrille(String productId) {
    return [
      {
        'id': _uuid.v4(),
        'nom': 'Grille Standard',
        'produit_id': productId,
        'statut': 'actif',
        'date_debut': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'nombre_tarifs': 0,
      },
    ];
  }
}
