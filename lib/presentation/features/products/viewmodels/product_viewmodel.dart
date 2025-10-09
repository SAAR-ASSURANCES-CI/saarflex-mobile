import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/data/services/product_service.dart';

class ProductViewModel extends ChangeNotifier {
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

  Future<Map<ProductType, int>> get productCountByType async {
    return await _productService.getProductCountByType();
  }

  List<Product> get vieProducts =>
      _allProducts.where((p) => p.type == ProductType.vie).toList();

  List<Product> get nonVieProducts =>
      _allProducts.where((p) => p.type == ProductType.nonVie).toList();

  bool get hasProducts => _allProducts.isNotEmpty;
  bool get hasFilteredProducts => _filteredProducts.isNotEmpty;
  bool get isFiltered => _selectedFilter != null || _searchQuery.isNotEmpty;

  List<CritereTarification> _criteresProduit = [];
  final Map<String, dynamic> _grillesTarifaires = {};
  bool _isLoadingCriteres = false;

  List<CritereTarification> get criteresProduit =>
      List.unmodifiable(_criteresProduit);
  Map<String, dynamic> get grillesTarifaires => _grillesTarifaires;
  bool get isLoadingCriteres => _isLoadingCriteres;

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

  Future<void> refresh() async {
    await loadProducts();
  }

  void filterByType(ProductType? type) {
    _selectedFilter = type;
    _applyCurrentFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyCurrentFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedFilter = null;
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
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        return product.nom.toLowerCase().contains(lowerQuery) ||
            product.description.toLowerCase().contains(lowerQuery) ||
            product.typeLabel.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    _filteredProducts = filtered;
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
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadProductCriteres(String productId) async {
    _setLoadingCriteres(true);
    _clearError();

    try {
      _criteresProduit = await _productService.getProductCriteres(productId);
    } catch (e) {
      _setError('Erreur lors du chargement des critères: ${e.toString()}');
    } finally {
      _setLoadingCriteres(false);
    }
  }

  Future<String?> getDefaultGrilleTarifaireId(String productId) async {
    try {
      final grilles = await _productService.getGrillesTarifaires(productId);

      if (grilles.isNotEmpty) {
        final grilleActive = grilles.firstWhere(
          (grille) => grille['statut'] == 'actif',
          orElse: () => grilles.first,
        );

        final grilleId = grilleActive['id']?.toString();
        return grilleId;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _setLoadingCriteres(bool loading) {
    _isLoadingCriteres = loading;
    notifyListeners();
  }
}
