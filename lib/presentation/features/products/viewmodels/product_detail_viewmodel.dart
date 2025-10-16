import 'package:flutter/material.dart';
import 'package:saarflex_app/data/models/product_model.dart';
import 'package:saarflex_app/data/repositories/product_repository.dart';
import 'package:saarflex_app/core/utils/product_cache.dart';
import 'package:saarflex_app/core/utils/product_validators.dart';
import 'package:saarflex_app/core/utils/product_formatters.dart';
import 'package:saarflex_app/core/utils/product_error_handler.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  Product? _product;
  bool _isLoading = false;
  String? _error;
  String? _productId;

  ProductDetailViewModel({ProductRepository? productRepository})
    : _productRepository = productRepository ?? ProductRepository();

  Product? get product => _product;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get productId => _productId;

  bool get hasProduct => _product != null;
  bool get isProductActive => _product?.isActive ?? false;
  bool get hasProductConditions => _product?.hasConditions ?? false;
  bool get requiresBeneficiaires => _product?.requiresBeneficiaires ?? false;
  bool get supportsBeneficiaires => _product?.supportsBeneficiaires ?? false;

  String get productName => _product?.nom ?? '';
  String get productDescription => _product?.description ?? '';
  String get productType => _product?.typeLabel ?? '';
  String get productStatus =>
      ProductFormatters.formatProductStatus(_product?.statut);
  String get productBranch =>
      ProductFormatters.formatProductBranch(_product?.branche);
  String get productCreatedAt =>
      ProductFormatters.formatProductCreatedAt(_product?.createdAt);

  Future<void> loadProduct(String productId) async {
    final validation = ProductValidators.validateProductId(productId);
    if (validation.hasError) {
      _setError(validation.errorMessage!);
      return;
    }

    _productId = productId;
    _setLoading(true);
    _clearError();

    try {
      _product = await _productRepository.getProductById(productId);

      if (_product == null) {
        _setError('Produit introuvable');
        return;
      }

      await ProductCache.cacheProduct(_product!);
    } catch (e) {
      _setError(ProductErrorHandler.handleProductDetailError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshProduct() async {
    if (_productId == null) return;

    _setLoading(true);
    _clearError();

    try {
      await ProductCache.clearCache();
      await loadProduct(_productId!);
    } catch (e) {
      _setError(ProductErrorHandler.handleProductDetailError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> validateProductForSimulation() async {
    if (_product == null) {
      _setError('Produit non chargé');
      return false;
    }

    final validation = ProductValidators.validateProductForSimulation(
      _product!,
    );
    if (validation.hasError) {
      _setError(validation.errorMessage!);
      return false;
    }

    return true;
  }

  String getProductSummary() {
    if (_product == null) return '';
    return ProductFormatters.formatProductSummary(_product!);
  }

  String getProductDetails() {
    if (_product == null) return '';
    return ProductFormatters.formatProductDetails(_product!);
  }

  String getProductSearchResult(String query) {
    if (_product == null) return '';
    return ProductFormatters.formatProductSearchResult(_product!, query);
  }

  bool canStartSimulation() {
    if (_product == null) return false;
    return _product!.isActive &&
        _product!.nom.isNotEmpty &&
        _product!.description.isNotEmpty;
  }

  List<String> getProductFeatures() {
    if (_product == null) return [];

    final features = <String>[];

    if (_product!.isActive) {
      features.add('Produit actif');
    }

    if (_product!.hasConditions) {
      features.add('Conditions disponibles');
    }

    if (_product!.supportsBeneficiaires) {
      features.add('Support des bénéficiaires');
    }

    if (_product!.requiresBeneficiaires) {
      features.add('Bénéficiaires requis');
    }

    return features;
  }

  Map<String, dynamic> getProductMetadata() {
    if (_product == null) return {};

    return {
      'id': _product!.id,
      'nom': _product!.nom,
      'type': _product!.type.toString(),
      'statut': _product!.statut,
      'branche': _product!.branche,
      'created_at': _product!.createdAt?.toIso8601String(),
      'necessite_beneficiaires': _product!.necessiteBeneficiaires,
      'max_beneficiaires': _product!.maxBeneficiaires,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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

  void clearProduct() {
    _product = null;
    _productId = null;
    _clearError();
    notifyListeners();
  }

  void reset() {
    clearProduct();
    _setLoading(false);
  }
}
