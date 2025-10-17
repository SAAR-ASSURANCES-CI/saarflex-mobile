import 'package:saarflex_app/data/models/beneficiaire_model.dart';

class SouscriptionRequest {
  final String devisId;
  final String methodePaiement;
  final String numeroTelephone;
  final List<Beneficiaire> beneficiaires;

  SouscriptionRequest({
    required this.devisId,
    required this.methodePaiement,
    required this.numeroTelephone,
    required this.beneficiaires,
  });

  Map<String, dynamic> toJson() {
    return {
      'methode_paiement': methodePaiement,
      'numero_telephone': numeroTelephone,
      'beneficiaires': beneficiaires.map((b) => b.toJson()).toList(),
    };
  }
}

class SouscriptionResponse {
  final String id;
  final String statut;
  final String message;
  final DateTime createdAt;
  final String? numeroContrat;
  final Map<String, dynamic>? detailsPaiement;

  SouscriptionResponse({
    required this.id,
    required this.statut,
    required this.message,
    required this.createdAt,
    this.numeroContrat,
    this.detailsPaiement,
  });

  factory SouscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SouscriptionResponse(
      id: json['id']?.toString() ?? '',
      statut: json['statut']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      numeroContrat: json['numero_contrat']?.toString(),
      detailsPaiement: json['details_paiement'] != null
          ? Map<String, dynamic>.from(json['details_paiement'])
          : null,
    );
  }
}

enum MethodePaiement { wave, orangeMoney, mtn, moov }

extension MethodePaiementExtension on MethodePaiement {
  String get displayName {
    switch (this) {
      case MethodePaiement.wave:
        return 'WAVE';
      case MethodePaiement.orangeMoney:
        return 'ORANGE';
      case MethodePaiement.mtn:
        return 'MTN';
      case MethodePaiement.moov:
        return 'MOOV';
    }
  }

  String get apiValue {
    switch (this) {
      case MethodePaiement.wave:
        return 'wave';
      case MethodePaiement.orangeMoney:
        return 'orange_money';
      case MethodePaiement.mtn:
        return 'mtn_money';
      case MethodePaiement.moov:
        return 'moov_money';
    }
  }

  String get description {
    switch (this) {
      case MethodePaiement.wave:
        return 'Paiement via Wave';
      case MethodePaiement.orangeMoney:
        return 'Paiement via Orange Money';
      case MethodePaiement.mtn:
        return 'Paiement via MTN Money';
      case MethodePaiement.moov:
        return 'Paiement via Moov Money';
    }
  }
}

enum StatutSouscription { enAttente, confirmee, annulee, echouee }

extension StatutSouscriptionExtension on StatutSouscription {
  String get displayName {
    switch (this) {
      case StatutSouscription.enAttente:
        return 'En attente';
      case StatutSouscription.confirmee:
        return 'Confirmée';
      case StatutSouscription.annulee:
        return 'Annulée';
      case StatutSouscription.echouee:
        return 'Échouée';
    }
  }

  String get apiValue {
    switch (this) {
      case StatutSouscription.enAttente:
        return 'en_attente';
      case StatutSouscription.confirmee:
        return 'confirmee';
      case StatutSouscription.annulee:
        return 'annulee';
      case StatutSouscription.echouee:
        return 'echouee';
    }
  }

  bool get isSuccess {
    return this == StatutSouscription.confirmee;
  }

  bool get isPending {
    return this == StatutSouscription.enAttente;
  }

  bool get isFailed {
    return this == StatutSouscription.echouee ||
        this == StatutSouscription.annulee;
  }
}
