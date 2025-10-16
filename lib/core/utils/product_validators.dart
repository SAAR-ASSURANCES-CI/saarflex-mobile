import 'package:saarflex_app/data/models/product_model.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.success() => const ValidationResult._(true, null);
  factory ValidationResult.error(String message) =>
      ValidationResult._(false, message);

  bool get hasError => !isValid;
}

class ProductValidators {
  static ValidationResult validateProductId(String productId) {
    if (productId.isEmpty) {
      return ValidationResult.error('ID produit requis');
    }

    if (productId.length < 3) {
      return ValidationResult.error('ID produit trop court');
    }

    return ValidationResult.success();
  }

  static ValidationResult validateSearchQuery(String query) {
    if (query.isEmpty) {
      return ValidationResult.error('Recherche vide');
    }

    if (query.length < 2) {
      return ValidationResult.error('Recherche trop courte (min 2 caractères)');
    }

    if (query.length > 50) {
      return ValidationResult.error(
        'Recherche trop longue (max 50 caractères)',
      );
    }

    return ValidationResult.success();
  }

  static ValidationResult validateProductName(String name) {
    if (name.isEmpty) {
      return ValidationResult.error('Nom du produit requis');
    }

    if (name.length < 3) {
      return ValidationResult.error('Nom trop court (min 3 caractères)');
    }

    if (name.length > 100) {
      return ValidationResult.error('Nom trop long (max 100 caractères)');
    }

    return ValidationResult.success();
  }

  static ValidationResult validateProductDescription(String description) {
    if (description.isEmpty) {
      return ValidationResult.error('Description requise');
    }

    if (description.length < 10) {
      return ValidationResult.error(
        'Description trop courte (min 10 caractères)',
      );
    }

    if (description.length > 500) {
      return ValidationResult.error(
        'Description trop longue (max 500 caractères)',
      );
    }

    return ValidationResult.success();
  }

  static ValidationResult validateProductType(ProductType? type) {
    if (type == null) {
      return ValidationResult.error('Type de produit requis');
    }

    return ValidationResult.success();
  }

  static ValidationResult validateProductFilter({
    ProductType? type,
    String? searchQuery,
  }) {
    if (type == null && (searchQuery == null || searchQuery.isEmpty)) {
      return ValidationResult.error('Au moins un critère de filtrage requis');
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchValidation = validateSearchQuery(searchQuery);
      if (searchValidation.hasError) {
        return searchValidation;
      }
    }

    return ValidationResult.success();
  }

  static ValidationResult validateProductForSimulation(Product product) {
    if (!product.isActive) {
      return ValidationResult.error('Produit non disponible');
    }

    if (product.nom.isEmpty) {
      return ValidationResult.error('Nom du produit invalide');
    }

    if (product.description.isEmpty) {
      return ValidationResult.error('Description du produit invalide');
    }

    return ValidationResult.success();
  }
}
