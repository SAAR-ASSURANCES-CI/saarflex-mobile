class SavedQuote {
  final String id;
  final String nomProduit;
  final String typeProduit;
  final double primeCalculee;
  final double franchiseCalculee;
  final double? plafondCalcule;
  final String statut;
  final DateTime createdAt;
  final String? nomPersonnalise;
  final String? notes;
  final int nombreBeneficiaires;
  final int nombreDocuments;
  final Map<String, dynamic>? informationsAssure;
  final Map<String, dynamic>? criteresUtilisateur;
  final bool? assureEstSouscripteur;
  final List<Map<String, dynamic>>? beneficiaires;

  SavedQuote({
    required this.id,
    required this.nomProduit,
    required this.typeProduit,
    required this.primeCalculee,
    required this.franchiseCalculee,
    this.plafondCalcule,
    required this.statut,
    required this.createdAt,
    this.nomPersonnalise,
    this.notes,
    required this.nombreBeneficiaires,
    required this.nombreDocuments,
    this.informationsAssure,
    this.criteresUtilisateur,
    this.assureEstSouscripteur,
    this.beneficiaires,
  });

  factory SavedQuote.fromJson(Map<String, dynamic> json) {
    return SavedQuote(
      id: json['id'],
      nomProduit: json['nom_produit'],
      typeProduit: json['type_produit'],
      primeCalculee: (json['prime_calculee'] as num).toDouble(),
      franchiseCalculee: (json['franchise_calculee'] as num).toDouble(),
      plafondCalcule: json['plafond_calcule'] != null
          ? (json['plafond_calcule'] as num).toDouble()
          : null,
      statut: json['statut'],
      createdAt: DateTime.parse(json['created_at']),
      nomPersonnalise: json['nom_personnalise'],
      notes: json['notes'],
      nombreBeneficiaires: json['nombre_beneficiaires'] ?? 0,
      nombreDocuments: json['nombre_documents'] ?? 0,
      informationsAssure: json['informations_assure'],
      criteresUtilisateur: json['criteres_utilisateur'],
      assureEstSouscripteur: json['assure_est_souscripteur'],
      beneficiaires: json['beneficiaires'] != null
          ? List<Map<String, dynamic>>.from(json['beneficiaires'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'devis_id': id,
      if (nomPersonnalise != null) 'nom_personnalise': nomPersonnalise,
      if (notes != null) 'notes': notes,
    };
  }
}
