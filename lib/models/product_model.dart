import 'package:flutter/material.dart';

enum ProductType { vie, nonVie }

extension ProductTypeExtension on ProductType {
  String get label {
    switch (this) {
      case ProductType.vie:
        return 'Assurance Vie';
      case ProductType.nonVie:
        return 'Assurance Non-Vie';
    }
  }

  String get shortLabel {
    switch (this) {
      case ProductType.vie:
        return 'Vie';
      case ProductType.nonVie:
        return 'Non-Vie';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductType.vie:
        return Icons.favorite_rounded;
      case ProductType.nonVie:
        return Icons.directions_car_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ProductType.vie:
        return const Color(0xFF10B981);
      case ProductType.nonVie:
        return const Color(0xFF3B82F6);
    }
  }
}

class Product {
  final String id;
  final String nom;
  final ProductType type;
  final String description;
  final String? conditionsPdf;
  final IconData? customIcon;

  final String? iconPath;
  final String? statut;
  final DateTime? createdAt;
  final Map<String, dynamic>? branche;
  final bool hasBeneficiaires;
  final bool necessiteBeneficiaires;
  final int maxBeneficiaires;

  Product({
    required this.id,
    required this.nom,
    required this.type,
    required this.description,
    this.conditionsPdf,
    this.customIcon,
    this.iconPath,
    this.statut,
    this.createdAt,
    this.branche,
    this.hasBeneficiaires = false,
    this.necessiteBeneficiaires = false,
    this.maxBeneficiaires = 3,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nom: json['nom'],
      type: _parseProductType(json['type']),
      description: json['description'],
      conditionsPdf: json['conditions_pdf'],
      iconPath: json['icon'],
      statut: json['statut'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      branche: json['branche'],
      hasBeneficiaires: json['has_beneficiaires'] ?? false,
      necessiteBeneficiaires: json['necessite_beneficiaires'] ?? false,
      maxBeneficiaires: json['max_beneficiaires'] ?? 3,
    );
  }

  static ProductType _parseProductType(String? typeString) {
    switch (typeString?.toLowerCase()) {
      case 'vie':
        return ProductType.vie;
      case 'non-vie':
      case 'nonvie':
        return ProductType.nonVie;
      default:
        return ProductType.nonVie;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'type': type.toString().split('.').last,
      'description': description,
      'conditions_pdf': conditionsPdf,
      'icon': iconPath,
      'statut': statut,
      'created_at': createdAt?.toIso8601String(),
      'branche': branche,
      'has_beneficiaires': hasBeneficiaires,
    };
  }

  Product copyWith({
    String? id,
    String? nom,
    ProductType? type,
    String? description,
    String? conditionsPdf,
    IconData? customIcon,
    String? iconPath,
    String? statut,
    DateTime? createdAt,
    Map<String, dynamic>? branche,
    bool? hasBeneficiaires,
  }) {
    return Product(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      description: description ?? this.description,
      conditionsPdf: conditionsPdf ?? this.conditionsPdf,
      customIcon: customIcon ?? this.customIcon,
      iconPath: iconPath ?? this.iconPath,
      statut: statut ?? this.statut,
      createdAt: createdAt ?? this.createdAt,
      branche: branche ?? this.branche,
      hasBeneficiaires: hasBeneficiaires ?? this.hasBeneficiaires,
    );
  }

  IconData get displayIcon => customIcon ?? type.icon;
  Color get displayColor => type.color;
  String get typeLabel => type.label;
  String get typeShortLabel => type.shortLabel;

  bool get hasConditions => conditionsPdf != null && conditionsPdf!.isNotEmpty;

  bool get isActive => statut?.toLowerCase() == 'actif';
  String get brancheName => branche?['nom'] ?? 'Non définie';

  // Vérifie si le produit nécessite des bénéficiaires
  bool get requiresBeneficiaires {
    // Règle principale : Si max_beneficiaires > 0, le produit supporte les bénéficiaires
    if (maxBeneficiaires > 0) return true;

    // Fallback : Ancienne logique pour compatibilité
    if (necessiteBeneficiaires) return true;
    if (hasBeneficiaires) return true;
    return type == ProductType.vie;
  }

  // Vérifie si les bénéficiaires sont obligatoires (ne peut pas souscrire sans)
  bool get beneficiairesObligatoires {
    // Toujours optionnel : l'utilisateur peut souscrire avec 0 bénéficiaire
    return false;
  }

  // Vérifie si le produit supporte les bénéficiaires
  bool get supportsBeneficiaires {
    return maxBeneficiaires > 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product{id: $id, nom: $nom, type: $type, statut: $statut}';
  }
}
