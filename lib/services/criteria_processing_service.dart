import '../models/critere_tarification_model.dart';

class CriteriaProcessingService {
  /// Nettoie les critères pour l'envoi à l'API
  static Map<String, dynamic> cleanCriteriaForApi(
    List<CritereTarification> criteres,
    Map<String, dynamic> reponses,
  ) {
    final Map<String, dynamic> cleanedCriteria = {};

    for (final critere in criteres) {
      final valeur = reponses[critere.nom];
      if (valeur == null) continue;

      // Traitement spécial pour les critères numériques
      if (critere.type == TypeCritere.numerique) {
        final cleanedValue = _processNumericValue(critere, valeur);
        if (cleanedValue != null) {
          cleanedCriteria[critere.nom] = cleanedValue;
        }
      } else {
        // Pour les autres types, utiliser la valeur telle quelle
        cleanedCriteria[critere.nom] = valeur;
      }
    }

    return cleanedCriteria;
  }

  /// Traite une valeur numérique
  static dynamic _processNumericValue(
    CritereTarification critere,
    dynamic valeur,
  ) {
    if (valeur == null) return null;

    String valeurString = valeur.toString();

    // Nettoyer les séparateurs si nécessaire
    if (_critereNecessiteFormatage(critere)) {
      valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
    }

    // Convertir en nombre
    final numericValue = num.tryParse(valeurString);
    return numericValue;
  }

  /// Initialise les valeurs par défaut pour les critères
  static Map<String, dynamic> initializeDefaultValues(
    List<CritereTarification> criteres,
  ) {
    final Map<String, dynamic> defaultValues = {};

    for (final critere in criteres) {
      switch (critere.type) {
        case TypeCritere.booleen:
          defaultValues[critere.nom] = false;
          break;
        case TypeCritere.categoriel:
          if (critere.hasValeurs) {
            defaultValues[critere.nom] = null;
          }
          break;
        case TypeCritere.numerique:
          defaultValues[critere.nom] = null;
          break;
      }
    }

    return defaultValues;
  }

  /// Détermine si un critère nécessite un formatage spécial
  static bool _critereNecessiteFormatage(CritereTarification critere) {
    const List<String> fieldsWithSeparators = [
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

    return fieldsWithSeparators.any(
      (field) => nomCritereLower.contains(field.toLowerCase()),
    );
  }

  /// Formate une valeur pour l'affichage
  static String formatValueForDisplay(
    CritereTarification critere,
    dynamic valeur,
  ) {
    if (valeur == null) return '';

    switch (critere.type) {
      case TypeCritere.numerique:
        if (_critereNecessiteFormatage(critere)) {
          return _formatNumericWithSeparators(valeur);
        }
        return valeur.toString();
      case TypeCritere.categoriel:
      case TypeCritere.booleen:
        return valeur.toString();
    }
  }

  /// Formate un nombre avec des séparateurs de milliers
  static String _formatNumericWithSeparators(dynamic valeur) {
    if (valeur == null) return '';

    final numValue = num.tryParse(valeur.toString());
    if (numValue == null) return valeur.toString();

    // Formater avec des séparateurs de milliers
    final formatter = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return numValue.toString().replaceAllMapped(
      formatter,
      (match) => '${match.group(1)} ',
    );
  }

  /// Vérifie si un critère a des valeurs valides
  static bool hasValidValues(CritereTarification critere) {
    switch (critere.type) {
      case TypeCritere.booleen:
        return true; // Les booléens n'ont pas besoin de valeurs prédéfinies
      case TypeCritere.categoriel:
        return critere.hasValeurs;
      case TypeCritere.numerique:
        return critere.valeurs.isNotEmpty;
    }
  }

  /// Obtient les options pour un critère catégoriel
  static List<String> getCategoricalOptions(CritereTarification critere) {
    if (critere.type != TypeCritere.categoriel || !critere.hasValeurs) {
      return [];
    }
    return critere.valeursString;
  }

  /// Obtient les contraintes pour un critère numérique
  static Map<String, num?> getNumericConstraints(CritereTarification critere) {
    if (critere.type != TypeCritere.numerique || critere.valeurs.isEmpty) {
      return {'min': null, 'max': null};
    }

    num? minValue;
    num? maxValue;

    for (final valeur in critere.valeurs) {
      if (valeur.valeurMin != null) {
        minValue = minValue == null
            ? valeur.valeurMin
            : (minValue < valeur.valeurMin! ? minValue : valeur.valeurMin);
      }
      if (valeur.valeurMax != null) {
        maxValue = maxValue == null
            ? valeur.valeurMax
            : (maxValue > valeur.valeurMax! ? maxValue : valeur.valeurMax);
      }
    }

    return {'min': minValue, 'max': maxValue};
  }
}
