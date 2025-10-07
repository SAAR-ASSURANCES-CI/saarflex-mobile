enum TypeCritere { numerique, categoriel, booleen }

extension TypeCritereExtension on TypeCritere {
  String get label {
    switch (this) {
      case TypeCritere.numerique:
        return 'Numérique';
      case TypeCritere.categoriel:
        return 'Catégoriel';
      case TypeCritere.booleen:
        return 'Booléen';
    }
  }

  String get apiValue {
    switch (this) {
      case TypeCritere.numerique:
        return 'numerique';
      case TypeCritere.categoriel:
        return 'categoriel';
      case TypeCritere.booleen:
        return 'booleen';
    }
  }
}

class ValeurCritere {
  final String id;
  final String valeur;
  final double? valeurMin;
  final double? valeurMax;
  final int ordre;

  ValeurCritere({
    required this.id,
    required this.valeur,
    this.valeurMin,
    this.valeurMax,
    required this.ordre,
  });

  factory ValeurCritere.fromJson(Map<String, dynamic> json) {
    return ValeurCritere(
      id: json['id']?.toString() ?? '',
      valeur: json['valeur']?.toString() ?? '',
      valeurMin: _parseDouble(json['valeur_min']),
      valeurMax: _parseDouble(json['valeur_max']),

      ordre: (json['ordre'] as num?)?.toInt() ?? 0,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'valeur': valeur,
      'valeur_min': valeurMin,
      'valeur_max': valeurMax,
      'ordre': ordre,
    };
  }
}

class CritereTarification {
  final String id;
  final String produitId;
  final String nom;
  final TypeCritere type;
  final String? unite;
  final int ordre;
  final bool obligatoire;
  final List<ValeurCritere> valeurs;

  CritereTarification({
    required this.id,
    required this.produitId,
    required this.nom,
    required this.type,
    this.unite,
    required this.ordre,
    required this.obligatoire,
    required this.valeurs,
  });

  factory CritereTarification.fromJson(Map<String, dynamic> json) {
    return CritereTarification(
      id: json['id']?.toString() ?? '',
      produitId: json['produit_id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      type: _parseTypeCritere(json['type']?.toString()),
      unite: json['unite']?.toString(),
      ordre: (json['ordre'] as num?)?.toInt() ?? 0,
      obligatoire: (json['obligatoire'] as bool?) ?? true,
      valeurs: (json['valeurs'] as List<dynamic>? ?? [])
          .map((v) => ValeurCritere.fromJson(v))
          .toList(),
    );
  }
  static TypeCritere _parseTypeCritere(String? typeString) {
    if (typeString == null) return TypeCritere.numerique;

    switch (typeString.toLowerCase()) {
      case 'numerique':
        return TypeCritere.numerique;
      case 'categoriel':
        return TypeCritere.categoriel;
      case 'booleen':
        return TypeCritere.booleen;
      default:
        return TypeCritere.numerique;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produit_id': produitId,
      'nom': nom,
      'type': type.apiValue,
      'unite': unite,
      'ordre': ordre,
      'obligatoire': obligatoire,
      'valeurs': valeurs.map((v) => v.toJson()).toList(),
    };
  }

  bool get hasValeurs => valeurs.isNotEmpty;

  List<String> get valeursString => valeurs.map((v) => v.valeur).toList();

  ValeurCritere? get premierValeur => valeurs.isNotEmpty ? valeurs.first : null;
}
