class Contract {
  final String id;
  final String nomProduit;
  final String typeProduit;
  final double primeCalculee;
  final double franchiseCalculee;
  final double? plafondCalcule;
  final String statut; // "actif", "expire", "suspendu"
  final DateTime dateSouscription;
  final DateTime? dateExpiration;
  final String numeroContrat;
  final String? nomPersonnalise;
  final String? notes;
  final int nombreBeneficiaires;
  final int nombreDocuments;

  Contract({
    required this.id,
    required this.nomProduit,
    required this.typeProduit,
    required this.primeCalculee,
    required this.franchiseCalculee,
    this.plafondCalcule,
    required this.statut,
    required this.dateSouscription,
    this.dateExpiration,
    required this.numeroContrat,
    this.nomPersonnalise,
    this.notes,
    required this.nombreBeneficiaires,
    required this.nombreDocuments,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      nomProduit: json['nom_produit'],
      typeProduit: json['type_produit'],
      primeCalculee: (json['prime_calculee'] as num).toDouble(),
      franchiseCalculee: (json['franchise_calculee'] as num).toDouble(),
      plafondCalcule: json['plafond_calcule'] != null
          ? (json['plafond_calcule'] as num).toDouble()
          : null,
      statut: json['statut'],
      dateSouscription: DateTime.parse(json['date_souscription']),
      dateExpiration: json['date_expiration'] != null
          ? DateTime.parse(json['date_expiration'])
          : null,
      numeroContrat: json['numero_contrat'],
      nomPersonnalise: json['nom_personnalise'],
      notes: json['notes'],
      nombreBeneficiaires: json['nombre_beneficiaires'] ?? 0,
      nombreDocuments: json['nombre_documents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_produit': nomProduit,
      'type_produit': typeProduit,
      'prime_calculee': primeCalculee,
      'franchise_calculee': franchiseCalculee,
      if (plafondCalcule != null) 'plafond_calcule': plafondCalcule,
      'statut': statut,
      'date_souscription': dateSouscription.toIso8601String(),
      if (dateExpiration != null)
        'date_expiration': dateExpiration!.toIso8601String(),
      'numero_contrat': numeroContrat,
      if (nomPersonnalise != null) 'nom_personnalise': nomPersonnalise,
      if (notes != null) 'notes': notes,
      'nombre_beneficiaires': nombreBeneficiaires,
      'nombre_documents': nombreDocuments,
    };
  }

  bool get isActive => statut == 'actif';
  bool get isExpired => statut == 'expire';
  bool get isSuspended => statut == 'suspendu';

  String get statusDisplayName {
    switch (statut) {
      case 'actif':
        return 'Actif';
      case 'expire':
        return 'Expiré';
      case 'suspendu':
        return 'Suspendu';
      default:
        return 'Inconnu';
    }
  }
}
