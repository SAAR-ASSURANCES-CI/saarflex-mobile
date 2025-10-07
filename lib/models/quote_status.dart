enum QuoteStatus {
  saved, // Devis sauvegardé
  subscribed, // Devis souscrit (devient contrat)
  expired, // Devis expiré
}

extension QuoteStatusExtension on QuoteStatus {
  String get displayName {
    switch (this) {
      case QuoteStatus.saved:
        return 'Sauvegardé';
      case QuoteStatus.subscribed:
        return 'Souscrit';
      case QuoteStatus.expired:
        return 'Expiré';
    }
  }

  String get description {
    switch (this) {
      case QuoteStatus.saved:
        return 'Devis sauvegardé, prêt pour souscription';
      case QuoteStatus.subscribed:
        return 'Devis souscrit, contrat actif';
      case QuoteStatus.expired:
        return 'Devis expiré, non valide';
    }
  }

  bool get canSubscribe {
    return this == QuoteStatus.saved;
  }

  bool get canDelete {
    return this == QuoteStatus.saved || this == QuoteStatus.expired;
  }

  bool get isActive {
    return this == QuoteStatus.subscribed;
  }
}
