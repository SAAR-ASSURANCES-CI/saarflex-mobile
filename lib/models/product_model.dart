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
        return Icons.favorite_rounded; // Cœur pour Vie
      case ProductType.nonVie:
        return Icons.directions_car_rounded; // Voiture pour Non-Vie
    }
  }

  Color get color {
    switch (this) {
      case ProductType.vie:
        return const Color(0xFF10B981); // Vert pour Vie
      case ProductType.nonVie:
        return const Color(0xFF3B82F6); // Bleu pour Non-Vie
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

  Product({
    required this.id,
    required this.nom,
    required this.type,
    required this.description,
    this.conditionsPdf,
    this.customIcon,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nom: json['nom'],
      type: ProductType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ProductType.nonVie,
      ),
      description: json['description'],
      conditionsPdf: json['conditions_pdf'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'type': type.toString().split('.').last,
      'description': description,
      'conditions_pdf': conditionsPdf,
    };
  }

  Product copyWith({
    String? id,
    String? nom,
    ProductType? type,
    String? description,
    String? conditionsPdf,
    IconData? customIcon,
  }) {
    return Product(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      description: description ?? this.description,
      conditionsPdf: conditionsPdf ?? this.conditionsPdf,
      customIcon: customIcon ?? this.customIcon,
    );
  }

  IconData get displayIcon => customIcon ?? type.icon;
  Color get displayColor => type.color;
  String get typeLabel => type.label;
  String get typeShortLabel => type.shortLabel;

  bool get hasConditions => conditionsPdf != null && conditionsPdf!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product{id: $id, nom: $nom, type: $type}';
  }
}