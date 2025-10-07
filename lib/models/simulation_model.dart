import 'package:flutter/material.dart';
import '../utils/format_helper.dart';

class SimulationRequest {
  final String produitId;
  final String grilleTarifaireId;
  final Map<String, dynamic> criteresUtilisateur;
  final bool assureEstSouscripteur;
  final Map<String, dynamic>? informationsAssure;
  final List<Map<String, dynamic>> beneficiaires;

  SimulationRequest({
    required this.produitId,
    required this.grilleTarifaireId,
    required this.criteresUtilisateur,
    required this.assureEstSouscripteur,
    this.informationsAssure,
    this.beneficiaires = const [],
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
      'assure_est_souscripteur': assureEstSouscripteur,
      if (informationsAssure != null) 'informations_assure': informationsAssure,
      'beneficiaires': beneficiaires,
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
      formuleUtilisee: json['formule_utilisee'] ?? 'Formule non spécifiée',
      variablesCalculees: Map<String, dynamic>.from(
        json['variables_calculees'] ?? {},
      ),
      explication: json['explication'] ?? 'Aucune explication disponible',
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

enum StatutDevis { simulation, sauvegarde, expire }

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

  Color get color {
    switch (this) {
      case StatutDevis.simulation:
        return Colors.orange;
      case StatutDevis.sauvegarde:
        return Colors.green;
      case StatutDevis.expire:
        return Colors.red;
    }
  }
}

extension DateTimeExtension on DateTime {
  String formatDate() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year à ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

extension DoubleExtension on double {
  String formatMontant() {
    return toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
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
  final List<Map<String, dynamic>> beneficiaires;
  final DateTime createdAt;

  final double? franchiseCalculee;
  final double? plafondCalcule;
  final DetailsCalcul? detailsCalcul;
  final StatutDevis statut;
  final DateTime? expiresAt;

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
    required this.createdAt,

    this.franchiseCalculee = 0.0,
    this.plafondCalcule,
    this.detailsCalcul,
    this.statut = StatutDevis.simulation,
    this.expiresAt,
  });

  factory SimulationResponse.fromJson(Map<String, dynamic> json) {
    try {
      final periodicitePrime =
          json['periodicite_prime']?.toString() ?? 'mensuel';

      return SimulationResponse(
        id: json['id']?.toString() ?? '',
        nomProduit: json['nom_produit']?.toString() ?? '',
        typeProduit: json['type_produit']?.toString() ?? '',
        periodicitePrime: periodicitePrime,
        criteresUtilisateur: Map<String, dynamic>.from(
          json['criteres_utilisateur'] ?? {},
        ),
        primeCalculee: _parseDouble(json['prime_calculee']),
        assureEstSouscripteur: json['assure_est_souscripteur'] ?? false,
        informationsAssure: json['informations_assure'] != null
            ? Map<String, dynamic>.from(json['informations_assure'])
            : null,
        beneficiaires: (json['beneficiaires'] as List<dynamic>? ?? [])
            .map((b) => Map<String, dynamic>.from(b))
            .toList(),
        createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String(),
        ),

        franchiseCalculee: json['franchise_calculee'] != null
            ? _parseDouble(json['franchise_calculee'])
            : 0.0,
        plafondCalcule: json['plafond_calcule'] != null
            ? _parseDouble(json['plafond_calcule'])
            : null,
        detailsCalcul: json['details_calcul'] != null
            ? DetailsCalcul.fromJson(json['details_calcul'])
            : _createDefaultDetailsCalcul(json, periodicitePrime),
        statut: _parseStatutDevis(json['statut']),
        expiresAt: json['expires_at'] != null
            ? DateTime.tryParse(json['expires_at'])
            : null,
      );
    } catch (e) {
      // Logging sera ajouté via le système de logging
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
      case 'sauvegarde':
        return StatutDevis.sauvegarde;
      case 'expire':
        return StatutDevis.expire;
      default:
        return StatutDevis.simulation;
    }
  }

  static String _getPeriodiciteFormatee(String periodicite) {
    switch (periodicite.toLowerCase()) {
      case 'mensuel':
        return 'mensuelle';
      case 'annuel':
        return 'annuelle';
      case 'trimestriel':
        return 'trimestrielle';
      case 'semestriel':
        return 'semestrielle';
      default:
        return periodicite;
    }
  }

  static DetailsCalcul _createDefaultDetailsCalcul(
    Map<String, dynamic> json,
    String periodicitePrime,
  ) {
    final capital =
        json['criteres_utilisateur']?['capital']?.toString() ?? 'N/A';
    final duree =
        json['criteres_utilisateur']?['Durée de cotisation']?.toString() ??
        'N/A';
    final age =
        json['criteres_utilisateur']?['Age Assuré']?.toString() ?? 'N/A';
    final prime = _parseDouble(json['prime_calculee']);
    final periodiciteFormatee = _getPeriodiciteFormatee(periodicitePrime);

    return DetailsCalcul(
      formuleUtilisee: 'Calcul standard basé sur les tables actuarielles',
      variablesCalculees: {
        'capital': capital,
        'duree_cotisation': duree,
        'age_assure': age,
        'prime_mensuelle': prime,
      },
      explication:
          'Prime calculée sur la base des critères fournis:\n'
          '• Capital: $capital FCFA\n'
          '• Durée de cotisation: $duree ans\n'
          '• Âge de l\'assuré: $age ans\n'
          '• Prime $periodiciteFormatee: ${prime.toStringAsFixed(0)} FCFA',
    );
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
      'details_calcul': detailsCalcul?.toJson(),
      'statut': statut.apiValue,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get periodicitePrimeFormatee {
    return _getPeriodiciteFormatee(periodicitePrime);
  }

  String get primeFormatee {
    return FormatHelper.formatMontant(primeCalculee);
  }

  String get franchiseFormatee {
    return FormatHelper.formatMontantAvecDefaut(franchiseCalculee);
  }

  String? get plafondFormate {
    return FormatHelper.formatMontantOptionnel(plafondCalcule);
  }
}

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
