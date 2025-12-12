class Beneficiaire {
  final String? id; // null pour les nouveaux bénéficiaires
  final String nomComplet;
  final String lienSouscripteur;
  final int ordre;

  Beneficiaire({
    this.id,
    required this.nomComplet,
    required this.lienSouscripteur,
    required this.ordre,
  });

  factory Beneficiaire.fromJson(Map<String, dynamic> json) {
    return Beneficiaire(
      id: json['id']?.toString(),
      nomComplet: json['nom_complet'] ?? '',
      lienSouscripteur: json['lien_souscripteur'] ?? '',
      ordre: json['ordre'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom_complet': nomComplet,
      'lien_souscripteur': lienSouscripteur,
      'ordre': ordre,
    };
  }

  Map<String, dynamic> toCreateDto() {
    return {
      'nom_complet': nomComplet,
      'lien_souscripteur': lienSouscripteur,
      'ordre': ordre,
    };
  }

  Beneficiaire copyWith({
    String? id,
    String? nomComplet,
    String? lienSouscripteur,
    int? ordre,
  }) {
    return Beneficiaire(
      id: id ?? this.id,
      nomComplet: nomComplet ?? this.nomComplet,
      lienSouscripteur: lienSouscripteur ?? this.lienSouscripteur,
      ordre: ordre ?? this.ordre,
    );
  }

  bool get isValid {
    return nomComplet.trim().isNotEmpty &&
        nomComplet.length <= 255 &&
        lienSouscripteur.trim().isNotEmpty &&
        lienSouscripteur.length <= 100 &&
        ordre >= 1;
  }

  List<String> get validationErrors {
    final errors = <String>[];

    if (nomComplet.trim().isEmpty) {
      errors.add('Le nom complet est obligatoire');
    } else if (nomComplet.length > 255) {
      errors.add('Le nom complet ne peut pas dépasser 255 caractères');
    }

    if (lienSouscripteur.trim().isEmpty) {
      errors.add('Le lien avec le souscripteur est obligatoire');
    } else if (lienSouscripteur.length > 100) {
      errors.add('Le lien ne peut pas dépasser 100 caractères');
    }

    if (ordre < 1) {
      errors.add('L\'ordre doit être supérieur ou égal à 1');
    }

    return errors;
  }

  bool isValidForMax(int maxBeneficiaires) {
    return isValid && ordre <= maxBeneficiaires;
  }

  List<String> validationErrorsForMax(int maxBeneficiaires) {
    final errors = validationErrors;
    if (ordre > maxBeneficiaires) {
      errors.add('L\'ordre doit être entre 1 et $maxBeneficiaires');
    }
    return errors;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Beneficiaire &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nomComplet == other.nomComplet &&
          lienSouscripteur == other.lienSouscripteur &&
          ordre == other.ordre;

  @override
  int get hashCode =>
      id.hashCode ^
      nomComplet.hashCode ^
      lienSouscripteur.hashCode ^
      ordre.hashCode;

  @override
  String toString() {
    return 'Beneficiaire{id: $id, nomComplet: $nomComplet, lienSouscripteur: $lienSouscripteur, ordre: $ordre}';
  }
}

class BeneficiairesList {
  final List<Beneficiaire> _beneficiaires = [];
  final int maxBeneficiaires;

  BeneficiairesList({this.maxBeneficiaires = 3});

  List<Beneficiaire> get beneficiaires => List.unmodifiable(_beneficiaires);

  int get count => _beneficiaires.length;
  bool get isEmpty => _beneficiaires.isEmpty;
  bool get isNotEmpty => _beneficiaires.isNotEmpty;
  bool get isFull => _beneficiaires.length >= maxBeneficiaires;

  void addBeneficiaire(Beneficiaire beneficiaire) {
    if (_beneficiaires.length < maxBeneficiaires) {
      _beneficiaires.add(beneficiaire);
      _sortByOrdre();
    }
  }

  void removeBeneficiaire(Beneficiaire beneficiaire) {
    _beneficiaires.remove(beneficiaire);
    _sortByOrdre();
  }

  void removeBeneficiaireAt(int index) {
    if (index >= 0 && index < _beneficiaires.length) {
      _beneficiaires.removeAt(index);
      _sortByOrdre();
    }
  }

  void updateBeneficiaire(int index, Beneficiaire beneficiaire) {
    if (index >= 0 && index < _beneficiaires.length) {
      _beneficiaires[index] = beneficiaire;
      _sortByOrdre();
    }
  }

  void clear() {
    _beneficiaires.clear();
  }

  bool isValid() {
    return _beneficiaires.every((b) => b.isValidForMax(maxBeneficiaires)) && 
           _beneficiaires.length <= maxBeneficiaires;
  }

  List<String> validationErrors() {
    final errors = <String>[];

    if (_beneficiaires.length > maxBeneficiaires) {
      errors.add('Le nombre maximum de bénéficiaires est de $maxBeneficiaires');
    }

    for (int i = 0; i < _beneficiaires.length; i++) {
      final beneficiaire = _beneficiaires[i];
      final beneficiaireErrors = beneficiaire.validationErrorsForMax(maxBeneficiaires);
      for (final error in beneficiaireErrors) {
        errors.add('Bénéficiaire ${i + 1}: $error');
      }
    }

    return errors;
  }

  List<Map<String, dynamic>> toCreateDtoList() {
    return _beneficiaires.map((b) => b.toCreateDto()).toList();
  }

  void _sortByOrdre() {
    _beneficiaires.sort((a, b) => a.ordre.compareTo(b.ordre));
  }

  List<int> get availableOrdres {
    final usedOrdres = _beneficiaires.map((b) => b.ordre).toSet();
    return List.generate(maxBeneficiaires, (index) => index + 1)
        .where((ordre) => !usedOrdres.contains(ordre))
        .toList();
  }

  int get nextAvailableOrdre {
    final usedOrdres = _beneficiaires.map((b) => b.ordre).toSet();
    for (int i = 1; i <= maxBeneficiaires; i++) {
      if (!usedOrdres.contains(i)) {
        return i;
      }
    }
    return 1; // Par défaut
  }
}
