import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saarciflex_app/data/models/product_model.dart';

class ProductCache {
  static const String _productsKey = 'cached_products';
  static const String _cacheTimestampKey = 'products_cache_timestamp';
  static const String _productCountKey = 'product_count_by_type';
  static const Duration _cacheValidity = Duration(hours: 1);

  static Future<void> cacheProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = products.map((p) => p.toJson()).toList();
    await prefs.setString(_productsKey, json.encode(productsJson));
    await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
  }

  static Future<List<Product>?> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_cacheTimestampKey);

    if (timestampStr == null) return null;

    final timestamp = DateTime.parse(timestampStr);
    if (DateTime.now().difference(timestamp) > _cacheValidity) {
      return null;
    }

    final productsJson = prefs.getString(_productsKey);
    if (productsJson == null) return null;

    final List<dynamic> jsonList = json.decode(productsJson);
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }

  static Future<void> cacheProductCount(Map<ProductType, int> count) async {
    final prefs = await SharedPreferences.getInstance();
    final countMap = count.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString(_productCountKey, json.encode(countMap));
  }

  static Future<Map<ProductType, int>?> getCachedProductCount() async {
    final prefs = await SharedPreferences.getInstance();
    final countJson = prefs.getString(_productCountKey);

    if (countJson == null) return null;

    final Map<String, dynamic> countMap = json.decode(countJson);
    return countMap.map(
      (key, value) => MapEntry(
        ProductType.values.firstWhere((type) => type.toString() == key),
        value as int,
      ),
    );
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productsKey);
    await prefs.remove(_cacheTimestampKey);
    await prefs.remove(_productCountKey);
  }

  static Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_cacheTimestampKey);

    if (timestampStr == null) return false;

    final timestamp = DateTime.parse(timestampStr);
    return DateTime.now().difference(timestamp) <= _cacheValidity;
  }

  static Future<void> cacheProduct(Product product) async {
    final cachedProducts = await getCachedProducts() ?? [];
    final existingIndex = cachedProducts.indexWhere((p) => p.id == product.id);

    if (existingIndex != -1) {
      cachedProducts[existingIndex] = product;
    } else {
      cachedProducts.add(product);
    }

    await cacheProducts(cachedProducts);
  }
}
