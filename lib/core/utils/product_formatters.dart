import 'package:saarciflex_app/data/models/product_model.dart';

class ProductFormatters {
  static String formatProductName(String name) {
    return name.trim().toUpperCase();
  }

  static String formatProductDescription(String description) {
    return description.trim();
  }

  static String formatProductType(ProductType type) {
    return type.label;
  }

  static String formatProductTypeShort(ProductType type) {
    return type.shortLabel;
  }

  static String formatProductId(String id) {
    return id.trim().toUpperCase();
  }

  static String formatSearchQuery(String query) {
    return query.trim().toLowerCase();
  }

  static String formatProductStatus(String? status) {
    if (status == null || status.isEmpty) {
      return 'Non défini';
    }

    switch (status.toLowerCase()) {
      case 'actif':
        return 'Actif';
      case 'inactif':
        return 'Inactif';
      case 'en_attente':
        return 'En attente';
      default:
        return status.toUpperCase();
    }
  }

  static String formatProductBranch(Map<String, dynamic>? branche) {
    if (branche == null || branche.isEmpty) {
      return 'Non définie';
    }

    return branche['nom']?.toString() ?? 'Non définie';
  }

  static String formatProductCreatedAt(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Date inconnue';
    }

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }

  static String formatProductCount(int count) {
    if (count == 0) {
      return 'Aucun produit';
    } else if (count == 1) {
      return '1 produit';
    } else {
      return '$count produits';
    }
  }

  static String formatProductTypeCount(ProductType type, int count) {
    final typeLabel = formatProductTypeShort(type);
    return '$typeLabel: ${formatProductCount(count)}';
  }

  static String formatProductSummary(Product product) {
    final name = formatProductName(product.nom);
    final type = formatProductTypeShort(product.type);
    final status = formatProductStatus(product.statut);

    return '$name ($type) - $status';
  }

  static String formatProductDetails(Product product) {
    final name = formatProductName(product.nom);
    final description = formatProductDescription(product.description);
    final type = formatProductType(product.type);
    final status = formatProductStatus(product.statut);
    final branch = formatProductBranch(product.branche);
    final createdAt = formatProductCreatedAt(product.createdAt);

    return '''
Nom: $name
Description: $description
Type: $type
Statut: $status
Branche: $branch
Créé: $createdAt
''';
  }

  static String formatProductSearchResult(Product product, String query) {
    final name = product.nom.toLowerCase();
    final description = product.description.toLowerCase();
    final typeLabel = product.typeLabel.toLowerCase();
    final searchQuery = query.toLowerCase();

    if (name.contains(searchQuery)) {
      return 'Correspondance dans le nom';
    } else if (description.contains(searchQuery)) {
      return 'Correspondance dans la description';
    } else if (typeLabel.contains(searchQuery)) {
      return 'Correspondance dans le type';
    } else {
      return 'Correspondance trouvée';
    }
  }
}
