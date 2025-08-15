import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _errorMessage;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  ProductType? _selectedFilter;
  String _searchQuery = '';


  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorMessage => _errorMessage;
  List<Product> get allProducts => List.unmodifiable(_allProducts);
  List<Product> get filteredProducts => List.unmodifiable(_filteredProducts);
  Product? get selectedProduct => _selectedProduct;
  ProductType? get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  int get totalProductsCount => _allProducts.length;
  int get filteredProductsCount => _filteredProducts.length;
  
  Map<ProductType, int> get productCountByType {
    return _productService.getProductCountByType();
  }

  List<Product> get vieProducts => 
      _allProducts.where((p) => p.type == ProductType.vie).toList();
  
  List<Product> get nonVieProducts => 
      _allProducts.where((p) => p.type == ProductType.nonVie).toList();

  bool get hasProducts => _allProducts.isNotEmpty;
  bool get hasFilteredProducts => _filteredProducts.isNotEmpty;
  bool get isFiltered => _selectedFilter != null || _searchQuery.isNotEmpty;

  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      _allProducts = await _productService.getAllProducts();
      _applyCurrentFilters();
    } catch (e) {
      _setError('Erreur lors du chargement des produits: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProductById(String id) async {
    _setLoadingDetail(true);
    _clearError();

    try {
      _selectedProduct = await _productService.getProductById(id);
      if (_selectedProduct == null) {
        _setError('Produit introuvable');
      }
    } catch (e) {
      _setError('Erreur lors du chargement du produit: ${e.toString()}');
    } finally {
      _setLoadingDetail(false);
    }
  }

  void filterByType(ProductType? type) {
    _selectedFilter = type;
    _applyCurrentFilters();
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query.trim();
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
      filtered = filtered.where((product) => product.type == _selectedFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        return product.nom.toLowerCase().contains(lowerQuery) ||
               product.description.toLowerCase().contains(lowerQuery) ||
               product.typeLabel.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    _filteredProducts = filtered;
  }

  Future<void> refresh() async {
    await loadProducts();
  }

  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  Future<List<Product>> getFeaturedProducts({int limit = 3}) async {
    try {
      return await _productService.getFeaturedProducts(limit: limit);
    } catch (e) {
      return [];
    }
  }

  bool productExists(String id) {
    return _productService.productExists(id);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingDetail(bool loading) {
    _isLoadingDetail = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();

    Future.delayed(const Duration(seconds: 5), () {
      if (_errorMessage == error) {
        _clearError();
      }
    });
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _allProducts.clear();
    _filteredProducts.clear();
    _selectedProduct = null;
    _selectedFilter = null;
    _searchQuery = '';
    _isLoading = false;
    _isLoadingDetail = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}