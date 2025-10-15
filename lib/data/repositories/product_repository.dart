import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/data/services/product_service.dart';

class ProductRepository {
  final ProductService _productService;

  ProductRepository({ProductService? productService})
    : _productService = productService ?? ProductService();

  Future<List<Product>> getAllProducts() async {
    try {
      return await _productService.getAllProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      return await _productService.getProductById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _productService.searchProducts(query);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> filterProductsByType(ProductType type) async {
    try {
      return await _productService.getProductsByType(type);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> filterProducts({
    ProductType? type,
    String? searchQuery,
  }) async {
    try {
      return await _productService.filterProducts(
        type: type,
        searchQuery: searchQuery,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<ProductType, int>> getProductCountByType() async {
    try {
      return await _productService.getProductCountByType();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> productExists(String id) async {
    try {
      return await _productService.productExists(id);
    } catch (e) {
      rethrow;
    }
  }
}
