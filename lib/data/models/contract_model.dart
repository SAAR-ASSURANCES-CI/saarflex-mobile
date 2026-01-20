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
    String nomProduit = '';
    String typeProduit = '';
    if (json['produit'] is Map) {
      final produit = json['produit'] as Map<String, dynamic>;
      nomProduit = produit['nom']?.toString() ?? produit['libelle']?.toString() ?? '';
      typeProduit = produit['type']?.toString() ?? produit['categorie']?.toString() ?? '';
    }
    
    double primeCalculee = 0.0;
    if (json['prime_mensuelle'] != null) {
      if (json['prime_mensuelle'] is String) {
        primeCalculee = double.tryParse(json['prime_mensuelle']) ?? 0.0;
      } else if (json['prime_mensuelle'] is num) {
        primeCalculee = (json['prime_mensuelle'] as num).toDouble();
      }
    }
    
    double franchiseCalculee = 0.0;
    if (json['franchise'] != null) {
      if (json['franchise'] is String) {
        franchiseCalculee = double.tryParse(json['franchise']) ?? 0.0;
      } else if (json['franchise'] is num) {
        franchiseCalculee = (json['franchise'] as num).toDouble();
      }
    }
    
    double? plafondCalcule;
    if (json['plafond'] != null) {
      if (json['plafond'] is String) {
        plafondCalcule = double.tryParse(json['plafond']);
      } else if (json['plafond'] is num) {
        plafondCalcule = (json['plafond'] as num).toDouble();
      }
    }
    
    int nombreBeneficiaires = 0;
    if (json['beneficiaires'] is List) {
      nombreBeneficiaires = (json['beneficiaires'] as List).length;
    }
    
    return Contract(
      id: json['id']?.toString() ?? '',
      nomProduit: nomProduit.isEmpty 
          ? (json['nom_produit']?.toString() ?? '') 
          : nomProduit,
      typeProduit: typeProduit.isEmpty 
          ? (json['type_produit']?.toString() ?? '') 
          : typeProduit,
      primeCalculee: primeCalculee,
      franchiseCalculee: franchiseCalculee,
      plafondCalcule: plafondCalcule,
      statut: json['statut']?.toString() ?? 'actif',
      dateSouscription: json['date_debut_couverture'] != null
          ? DateTime.parse(json['date_debut_couverture'].toString())
          : (json['date_souscription'] != null
              ? DateTime.parse(json['date_souscription'].toString())
              : DateTime.now()),
      dateExpiration: json['date_fin_couverture'] != null
          ? DateTime.parse(json['date_fin_couverture'].toString())
          : (json['date_expiration'] != null
              ? DateTime.parse(json['date_expiration'].toString())
              : null),
      numeroContrat: json['numero_contrat']?.toString() ?? '',
      nomPersonnalise: json['nom_personnalise']?.toString(),
      notes: json['notes']?.toString(),
      nombreBeneficiaires: nombreBeneficiaires,
      nombreDocuments: json['nombre_documents'] is int
          ? json['nombre_documents'] as int
          : (json['nombre_documents'] != null
              ? int.tryParse(json['nombre_documents'].toString()) ?? 0
              : 0),
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
