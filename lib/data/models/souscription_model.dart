import 'package:saarflex_app/data/models/beneficiaire_model.dart';

class SouscriptionRequest {
  final String devisId;
  final String methodePaiement;
  final String numeroTelephone;
  final List<Beneficiaire> beneficiaires;
  final String currency;

  SouscriptionRequest({
    required this.devisId,
    required this.methodePaiement,
    required this.numeroTelephone,
    required this.beneficiaires,
    this.currency = 'XOF',
  });

  Map<String, dynamic> toJson() {
    return {
      'methode_paiement': methodePaiement,
      'numero_telephone': numeroTelephone,
      'currency': currency,
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
  final String? paiementId;
  final String? referencePaiement;
  final String? statutPaiement;
  final double? montant;
  final String? paymentUrl;
  final String? currency;

  SouscriptionResponse({
    required this.id,
    required this.statut,
    required this.message,
    required this.createdAt,
    this.numeroContrat,
    this.detailsPaiement,
    this.paiementId,
    this.referencePaiement,
    this.statutPaiement,
    this.montant,
    this.paymentUrl,
    this.currency,
  });

  factory SouscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SouscriptionResponse(
      id: json['id']?.toString() ?? json['paiement_id']?.toString() ?? '',
      statut: json['statut']?.toString() ?? json['statut_paiement']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      numeroContrat: json['numero_contrat']?.toString(),
      detailsPaiement: json['details_paiement'] != null
          ? Map<String, dynamic>.from(json['details_paiement'])
          : null,
      paiementId: json['paiement_id']?.toString(),
      referencePaiement: json['reference_paiement']?.toString(),
      statutPaiement: json['statut_paiement']?.toString(),
      montant: json['montant'] != null
          ? (json['montant'] is int
              ? (json['montant'] as int).toDouble()
              : json['montant'] as double?)
          : null,
      paymentUrl: json['payment_url']?.toString(),
      currency: json['currency']?.toString(),
    );
  }
}

enum MethodePaiement { wave, mobileMoney }

extension MethodePaiementExtension on MethodePaiement {
  String get displayName {
    switch (this) {
      case MethodePaiement.wave:
        return 'WAVE';
      case MethodePaiement.mobileMoney:
        return 'Mobile Money';
    }
  }

  String get apiValue {
    switch (this) {
      case MethodePaiement.wave:
        return 'wave';
      case MethodePaiement.mobileMoney:
        return 'orange_money';
    }
  }

  String get description {
    switch (this) {
      case MethodePaiement.wave:
        return 'Paiement via Wave';
      case MethodePaiement.mobileMoney:
        return 'Paiement via Mobile Money (Orange, MTN, Moov)';
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
