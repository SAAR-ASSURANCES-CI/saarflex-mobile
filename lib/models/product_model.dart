import 'package:flutter/material.dart';

enum ProductType {
  vie,
  nonVie,
}

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
    );
  }

  IconData get displayIcon => customIcon ?? type.icon;
  Color get displayColor => type.color;
  String get typeLabel => type.label;
  String get typeShortLabel => type.shortLabel;

  bool get hasConditions => conditionsPdf != null && conditionsPdf!.isNotEmpty;
  
  bool get isActive => statut?.toLowerCase() == 'actif';
  String get brancheName => branche?['nom'] ?? 'Non définie';

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