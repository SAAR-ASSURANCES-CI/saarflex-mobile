import 'package:saarflex_app/data/models/critere_tarification_model.dart';

/// Utilitaires de validation pour la simulation
class SimulationValidators {
  /// Valide un critère individuel
  static String? validateCritere(CritereTarification critere, dynamic valeur) {
    // Validation des champs obligatoires
    if (critere.obligatoire &&
        (valeur == null || valeur.toString().trim().isEmpty)) {
      return 'Ce champ est obligatoire';
    }

    // Validation selon le type de critère
    switch (critere.type) {
      case TypeCritere.numerique:
        return _validateNumerique(critere, valeur);
      case TypeCritere.categoriel:
        return _validateCategoriel(critere, valeur);
      case TypeCritere.booleen:
        return null; // Les booléens sont toujours valides
    }
  }

  /// Valide un critère numérique
  static String? _validateNumerique(
    CritereTarification critere,
    dynamic valeur,
  ) {
    if (valeur == null || valeur.toString().isEmpty) return null;

    // Nettoyer la valeur des séparateurs si nécessaire
    String valeurString = valeur.toString();
    if (critereNecessiteFormatage(critere)) {
      valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
    }

    final numericValue = num.tryParse(valeurString);
    if (numericValue == null) {
      return 'Veuillez entrer un nombre valide';
    }

    // Vérifier les limites min/max
    for (final valeurCritere in critere.valeurs) {
      if (valeurCritere.valeurMin != null &&
          numericValue < valeurCritere.valeurMin!) {
        return 'Valeur minimum: ${valeurCritere.valeurMin}';
      }
      if (valeurCritere.valeurMax != null &&
          numericValue > valeurCritere.valeurMax!) {
        return 'Valeur maximum: ${valeurCritere.valeurMax}';
      }
    }

    return null;
  }

  /// Valide un critère catégoriel
  static String? _validateCategoriel(
    CritereTarification critere,
    dynamic valeur,
  ) {
    if (valeur == null || !critere.hasValeurs) return null;

    if (!critere.valeursString.contains(valeur.toString())) {
      return 'Valeur non autorisée';
    }

    return null;
  }

  /// Valide l'ensemble du formulaire
  static bool validateForm(
    Map<String, dynamic> criteres,
    List<CritereTarification> criteresProduit,
  ) {
    for (final critere in criteresProduit) {
      final valeur = criteres[critere.nom];
      final error = validateCritere(critere, valeur);
      if (error != null) return false;
    }
    return true;
  }

  /// Retourne toutes les erreurs de validation
  static Map<String, String> getValidationErrors(
    Map<String, dynamic> criteres,
    List<CritereTarification> criteresProduit,
  ) {
    final errors = <String, String>{};

    for (final critere in criteresProduit) {
      final valeur = criteres[critere.nom];
      final error = validateCritere(critere, valeur);
      if (error != null) {
        errors[critere.nom] = error;
      }
    }

    return errors;
  }

  /// Détermine si un critère nécessite un formatage spécial
  static bool critereNecessiteFormatage(CritereTarification critere) {
    const champsAvecSeparateurs = [
      'capital',
      'capital_assure',
      'montant',
      'prime',
      'franchise',
      'plafond',
      'souscription',
      'assurance',
    ];

    final nomCritereLower = critere.nom.toLowerCase();

    for (final motCle in champsAvecSeparateurs) {
      if (nomCritereLower.contains(motCle)) {
        return true;
      }
    }

    return false;
  }

  /// Valide les bénéficiaires
  static bool validateBeneficiaires(
    List<Map<String, dynamic>> beneficiaires,
    int maxBeneficiaires,
  ) {
    if (beneficiaires.length != maxBeneficiaires) return false;

    for (final beneficiaire in beneficiaires) {
      if (beneficiaire['nom_complet']?.toString().trim().isEmpty ?? true) {
        return false;
      }
      if (beneficiaire['lien_souscripteur']?.toString().trim().isEmpty ??
          true) {
        return false;
      }
    }

    return true;
  }
}
