import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/data/repositories/product_repository.dart';
import 'package:saarflex_app/core/utils/product_cache.dart';
import 'package:saarflex_app/core/utils/product_validators.dart';
import 'package:saarflex_app/core/utils/product_formatters.dart';
import 'package:saarflex_app/core/utils/product_error_handler.dart';

class ProductListViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _searchQuery = '';
  ProductType? _selectedFilter;
  Map<ProductType, int> _productCountByType = {};

  ProductListViewModel({ProductRepository? productRepository})
    : _productRepository = productRepository ?? ProductRepository();

  List<Product> get allProducts => List.unmodifiable(_allProducts);
  List<Product> get filteredProducts => List.unmodifiable(_filteredProducts);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  ProductType? get selectedFilter => _selectedFilter;
  Map<ProductType, int> get productCountByType =>
      Map.unmodifiable(_productCountByType);

  int get totalProductsCount => _allProducts.length;
  int get filteredProductsCount => _filteredProducts.length;
  bool get hasProducts => _allProducts.isNotEmpty;
  bool get hasFilteredProducts => _filteredProducts.isNotEmpty;
  bool get isFiltered => _selectedFilter != null || _searchQuery.isNotEmpty;

  List<Product> get vieProducts =>
      _allProducts.where((p) => p.type == ProductType.vie).toList();

  List<Product> get nonVieProducts =>
      _allProducts.where((p) => p.type == ProductType.nonVie).toList();

  Future<void> loadProducts({bool useCache = true}) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      if (useCache) {
        final cachedProducts = await ProductCache.getCachedProducts();
        if (cachedProducts != null && cachedProducts.isNotEmpty) {
          _allProducts = cachedProducts;
          _applyCurrentFilters();
          _setLoading(false);

          loadProductsFromApi();
          return;
        }
      }

      await loadProductsFromApi();
    } catch (e) {
      _setError(ProductErrorHandler.handleProductLoadError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProductsFromApi() async {
    try {
      _allProducts = await _productRepository.getAllProducts();
      await ProductCache.cacheProducts(_allProducts);
      _applyCurrentFilters();

      await loadProductCountByType();
    } catch (e) {
      _setError(ProductErrorHandler.handleProductLoadError(e));
    }
  }

  Future<void> loadProductCountByType() async {
    try {
      _productCountByType = await _productRepository.getProductCountByType();
      await ProductCache.cacheProductCount(_productCountByType);
    } catch (e) {
      final cachedCount = await ProductCache.getCachedProductCount();
      if (cachedCount != null) {
        _productCountByType = cachedCount;
      }
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;

    _setRefreshing(true);
    _clearError();

    try {
      await ProductCache.clearCache();
      await loadProductsFromApi();
    } catch (e) {
      _setError(ProductErrorHandler.handleProductLoadError(e));
    } finally {
      _setRefreshing(false);
    }
  }

  void search(String query) {
    final validation = ProductValidators.validateSearchQuery(query);
    if (validation.hasError) {
      _setError(validation.errorMessage!);
      return;
    }

    _searchQuery = ProductFormatters.formatSearchQuery(query);
    _applyCurrentFilters();
    notifyListeners();
  }

  void filterByType(ProductType? type) {
    _selectedFilter = type;
    _applyCurrentFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedFilter = null;
    _searchQuery = '';
    _applyCurrentFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyCurrentFilters();
    notifyListeners();
  }

  void _applyCurrentFilters() {
    List<Product> filtered = List.from(_allProducts);

    if (_selectedFilter != null) {
      filtered = filtered
          .where((product) => product.type == _selectedFilter)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.nom.toLowerCase().contains(_searchQuery) ||
            product.description.toLowerCase().contains(_searchQuery) ||
            product.typeLabel.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    _filteredProducts = filtered;
  }

  Future<List<Product>> searchProducts(String query) async {
    final validation = ProductValidators.validateSearchQuery(query);
    if (validation.hasError) {
      throw Exception(validation.errorMessage!);
    }

    try {
      return await _productRepository.searchProducts(query);
    } catch (e) {
      throw Exception(ProductErrorHandler.handleProductSearchError(e));
    }
  }

  Future<List<Product>> filterProducts({
    ProductType? type,
    String? searchQuery,
  }) async {
    final validation = ProductValidators.validateProductFilter(
      type: type,
      searchQuery: searchQuery,
    );
    if (validation.hasError) {
      throw Exception(validation.errorMessage!);
    }

    try {
      return await _productRepository.filterProducts(
        type: type,
        searchQuery: searchQuery,
      );
    } catch (e) {
      throw Exception(ProductErrorHandler.handleProductFilterError(e));
    }
  }

  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByType(ProductType type) {
    return _allProducts.where((product) => product.type == type).toList();
  }

  bool hasProduct(String id) {
    return _allProducts.any((product) => product.id == id);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAll() {
    _allProducts.clear();
    _filteredProducts.clear();
    _searchQuery = '';
    _selectedFilter = null;
    _productCountByType.clear();
    _clearError();
    notifyListeners();
  }
}
