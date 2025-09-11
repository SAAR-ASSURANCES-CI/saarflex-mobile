class SimulationRequest {
  final String produitId;
  final String grilleTarifaireId;
  final Map<String, dynamic> criteresUtilisateur;

  SimulationRequest({
    required this.produitId,
    required this.grilleTarifaireId,
    required this.criteresUtilisateur,
  });

  Map<String, dynamic> toJson() {
    final convertedCriteres = {};
    criteresUtilisateur.forEach((key, value) {
      if (value is String && double.tryParse(value) != null) {
        convertedCriteres[key] = double.parse(value);
      } else {
        convertedCriteres[key] = value;
      }
    });
    
    return {
      'produit_id': produitId,
      'grille_tarifaire_id': grilleTarifaireId,
      'criteres_utilisateur': convertedCriteres,
    };
  }
}

class DetailsCalcul {
  final String formuleUtilisee;
  final Map<String, dynamic> variablesCalculees;
  final String explication;

  DetailsCalcul({
    required this.formuleUtilisee,
    required this.variablesCalculees,
    required this.explication,
  });

  factory DetailsCalcul.fromJson(Map<String, dynamic> json) {
    return DetailsCalcul(
      formuleUtilisee: json['formule_utilisee'] ?? '',
      variablesCalculees: json['variables_calculees'] ?? {},
      explication: json['explication'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formule_utilisee': formuleUtilisee,
      'variables_calculees': variablesCalculees,
      'explication': explication,
    };
  }
}

enum StatutDevis {
  simulation,
  sauvegarde,
  expire,
}

extension StatutDevisExtension on StatutDevis {
  String get label {
    switch (this) {
      case StatutDevis.simulation:
        return 'Simulation';
      case StatutDevis.sauvegarde:
        return 'Sauvegardé';
      case StatutDevis.expire:
        return 'Expiré';
    }
  }

  String get apiValue {
    switch (this) {
      case StatutDevis.simulation:
        return 'simulation';
      case StatutDevis.sauvegarde:
        return 'sauvegarde';
      case StatutDevis.expire:
        return 'expire';
    }
  }
}



class SimulationResponse {
  final String id;
  final String nomProduit;
  final String typeProduit;
  final String periodicitePrime;
  final Map<String, dynamic> criteresUtilisateur;
  final double primeCalculee;
  final bool assureEstSouscripteur;
  final Map<String, dynamic>? informationsAssure;
  final List<Map<String, dynamic>> beneficiaires; // Changé de Beneficiaire à Map
  final double franchiseCalculee;
  final double? plafondCalcule;
  final DetailsCalcul detailsCalcul;
  final StatutDevis statut;
  final DateTime? expiresAt;
  final DateTime createdAt;

  SimulationResponse({
    required this.id,
    required this.nomProduit,
    required this.typeProduit,
    required this.periodicitePrime,
    required this.criteresUtilisateur,
    required this.primeCalculee,
    required this.assureEstSouscripteur,
    this.informationsAssure,
    required this.beneficiaires,
    required this.franchiseCalculee,
    this.plafondCalcule,
    required this.detailsCalcul,
    required this.statut,
    this.expiresAt,
    required this.createdAt,
  });

  factory SimulationResponse.fromJson(Map<String, dynamic> json) {
    try {
      return SimulationResponse(
        id: json['id']?.toString() ?? '',
        nomProduit: json['nom_produit']?.toString() ?? '',
        typeProduit: json['type_produit']?.toString() ?? '',
        periodicitePrime: json['periodicite_prime']?.toString() ?? '',
        criteresUtilisateur: Map<String, dynamic>.from(json['criteres_utilisateur'] ?? {}),
        primeCalculee: _parseDouble(json['prime_calculee']),
        assureEstSouscripteur: json['assure_est_souscripteur'] ?? false,
        informationsAssure: json['informations_assure'] != null 
            ? Map<String, dynamic>.from(json['informations_assure'])
            : null,
        beneficiaires: (json['beneficiaires'] as List<dynamic>? ?? [])
            .map((b) => Map<String, dynamic>.from(b)) // Conversion en Map
            .toList(),
        franchiseCalculee: _parseDouble(json['franchise_calculee']),
        plafondCalcule: json['plafond_calcule'] != null 
            ? _parseDouble(json['plafond_calcule'])
            : null,
        detailsCalcul: DetailsCalcul.fromJson(json['details_calcul'] ?? {}),
        statut: _parseStatutDevis(json['statut']),
        expiresAt: json['expires_at'] != null 
            ? DateTime.parse(json['expires_at']) 
            : null,
        createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      print('❌ Erreur parsing SimulationResponse: $e');
      print('❌ JSON reçu: $json');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleanedValue = value
          .replaceAll(' ', '')
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'[^\d\.]'), '');
      
      return double.tryParse(cleanedValue) ?? 0.0;
    }
    
    return 0.0;
  }

  static StatutDevis _parseStatutDevis(String? statutString) {
    switch (statutString?.toLowerCase()) {
      case 'simulation':
        return StatutDevis.simulation;
      case 'sauvegarde':
        return StatutDevis.sauvegarde;
      case 'expire':
        return StatutDevis.expire;
      default:
        return StatutDevis.simulation;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_produit': nomProduit,
      'type_produit': typeProduit,
      'periodicite_prime': periodicitePrime,
      'criteres_utilisateur': criteresUtilisateur,
      'prime_calculee': primeCalculee,
      'assure_est_souscripteur': assureEstSouscripteur,
      'informations_assure': informationsAssure,
      'beneficiaires': beneficiaires,
      'franchise_calculee': franchiseCalculee,
      'plafond_calcule': plafondCalcule,
      'details_calcul': detailsCalcul.toJson(),
      'statut': statut.toString().split('.').last, // Utilisation de toString au lieu de apiValue
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get primeFormatee {
    return '${primeCalculee.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    )} FCFA';
  }

  String get franchiseFormatee {
    return '${franchiseCalculee.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    )} FCFA';
  }

  String? get plafondFormate {
    if (plafondCalcule == null) return null;
    return '${plafondCalcule!.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    )} FCFA';
  }
}


// class SimulationResponse {
//   final String id;
//   final double primeCalculee;
//   final double franchiseCalculee;
//   final double? plafondCalcule;
//   final DetailsCalcul detailsCalcul;
//   final StatutDevis statut;
//   final DateTime? expiresAt;
//   final DateTime createdAt;

//   SimulationResponse({
//     required this.id,
//     required this.primeCalculee,
//     required this.franchiseCalculee,
//     this.plafondCalcule,
//     required this.detailsCalcul,
//     required this.statut,
//     this.expiresAt,
//     required this.createdAt,
//   });

//   factory SimulationResponse.fromJson(Map<String, dynamic> json) {
//     return SimulationResponse(
//       id: json['id'],
//       primeCalculee: _parseDouble(json['prime_calculee']),
//       franchiseCalculee: _parseDouble(json['franchise_calculee']),
//       plafondCalcule: json['plafond_calcule'] != null 
//           ? _parseDouble(json['plafond_calcule'])
//           : null,
//       detailsCalcul: DetailsCalcul.fromJson(json['details_calcul'] ?? {}),
//       statut: _parseStatutDevis(json['statut']),
//       expiresAt: json['expires_at'] != null 
//           ? DateTime.parse(json['expires_at']) 
//           : null,
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }

//   static double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
    
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) {
//       final cleanedValue = value
//           .replaceAll(' ', '')
//           .replaceAll(',', '.')
//           .replaceAll(RegExp(r'[^\d\.]'), '');
      
//       return double.tryParse(cleanedValue) ?? 0.0;
//     }
    
//     return 0.0;
//   }

//   static StatutDevis _parseStatutDevis(String? statutString) {
//     switch (statutString?.toLowerCase()) {
//       case 'simulation':
//         return StatutDevis.simulation;
//       case 'sauvegarde':
//         return StatutDevis.sauvegarde;
//       case 'expire':
//         return StatutDevis.expire;
//       default:
//         return StatutDevis.simulation;
//     }
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'prime_calculee': primeCalculee,
//       'franchise_calculee': franchiseCalculee,
//       'plafond_calcule': plafondCalcule,
//       'details_calcul': detailsCalcul.toJson(),
//       'statut': statut.apiValue,
//       'expires_at': expiresAt?.toIso8601String(),
//       'created_at': createdAt.toIso8601String(),
//     };
//   }

//   bool get isExpired {
//     if (expiresAt == null) return false;
//     return DateTime.now().isAfter(expiresAt!);
//   }

//   String get primeFormatee {
//     return '${primeCalculee.toStringAsFixed(0).replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]} ',
//     )} FCFA';
//   }

//   String get franchiseFormatee {
//     return '${franchiseCalculee.toStringAsFixed(0).replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]} ',
//     )} FCFA';
//   }

//   String? get plafondFormate {
//     if (plafondCalcule == null) return null;
//     return '${plafondCalcule!.toStringAsFixed(0).replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (Match m) => '${m[1]} ',
//     )} FCFA';
//   }
// }

class SauvegardeDevisRequest {
  final String devisId;
  final String? nomPersonnalise;
  final String? notes;

  SauvegardeDevisRequest({
    required this.devisId,
    this.nomPersonnalise,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'devis_id': devisId,
      'nom_personnalise': nomPersonnalise,
      'notes': notes,
    };
  }
}