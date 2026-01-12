import 'package:saarciflex_app/data/models/critere_tarification_model.dart';

class CriteriaProcessingService {

  static Map<String, dynamic> cleanCriteriaForApi(
    List<CritereTarification> criteres,
    Map<String, dynamic> reponses,
  ) {
    final Map<String, dynamic> cleanedCriteria = {};

    for (final critere in criteres) {
      final valeur = reponses[critere.nom];
      if (valeur == null) continue;

      if (critere.type == TypeCritere.numerique) {
        final cleanedValue = _processNumericValue(critere, valeur);
        if (cleanedValue != null) {
          cleanedCriteria[critere.nom] = cleanedValue;
        }
      } else {

        cleanedCriteria[critere.nom] = valeur;
      }
    }

    return cleanedCriteria;
  }

  static dynamic _processNumericValue(
    CritereTarification critere,
    dynamic valeur,
  ) {
    if (valeur == null) return null;

    String valeurString = valeur.toString();

    if (_critereNecessiteFormatage(critere)) {
      valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
    }

    final numericValue = num.tryParse(valeurString);
    return numericValue;
  }

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
        case TypeCritere.date:
        case TypeCritere.texte:
          defaultValues[critere.nom] = null;
          break;
      }
    }

    return defaultValues;
  }

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
      case TypeCritere.texte:
        return valeur.toString();
      case TypeCritere.date:
        if (valeur is DateTime) {
          final day = valeur.day.toString().padLeft(2, '0');
          final month = valeur.month.toString().padLeft(2, '0');
          return '$day/$month/${valeur.year}';
        }
        return valeur.toString();
    }
  }

  static String _formatNumericWithSeparators(dynamic valeur) {
    if (valeur == null) return '';

    final numValue = num.tryParse(valeur.toString());
    if (numValue == null) return valeur.toString();

    final formatter = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return numValue.toString().replaceAllMapped(
      formatter,
      (match) => '${match.group(1)} ',
    );
  }

  static bool hasValidValues(CritereTarification critere) {
    switch (critere.type) {
      case TypeCritere.booleen:
        return true; // Les booléens n'ont pas besoin de valeurs prédéfinies
      case TypeCritere.categoriel:
        return critere.hasValeurs;
      case TypeCritere.numerique:
        return critere.valeurs.isNotEmpty;
      case TypeCritere.date:
      case TypeCritere.texte:
        return true; // Les dates et textes n'ont pas besoin de valeurs prédéfinies
    }
  }

  static List<String> getCategoricalOptions(CritereTarification critere) {
    if (critere.type != TypeCritere.categoriel || !critere.hasValeurs) {
      return [];
    }
    return critere.valeursString;
  }

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
