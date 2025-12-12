import 'package:saarflex_app/data/models/critere_tarification_model.dart';

class ValidationService {
  static const List<String> _fieldsWithSeparators = [
    'capital',
    'capital_assure',
    'montant',
    'prime',
    'franchise',
    'plafond',
    'souscription',
    'assurance',
  ];

  static String? validateCritere(CritereTarification critere, dynamic valeur) {
    if (critere.obligatoire && _isEmpty(valeur)) {
      return 'Ce champ est obligatoire';
    }

    if (_isEmpty(valeur)) {
      return null;
    }
    switch (critere.type) {
      case TypeCritere.numerique:
        return _validateNumericCritere(critere, valeur);
      case TypeCritere.categoriel:
        return _validateCategoricalCritere(critere, valeur);
      case TypeCritere.booleen:
        return null;
    }
  }

  static String? _validateNumericCritere(
    CritereTarification critere,
    dynamic valeur,
  ) {
    String valeurString = valeur.toString();
    if (_critereNecessiteFormatage(critere)) {
      // Pour les champs avec formatage (capital, prime, etc.), on enlève tous les séparateurs
      valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
    } else {
      // Pour les autres critères numériques, on normalise la virgule en point
      // pour accepter les deux formats (1.5 ou 1,5)
      valeurString = valeurString.replaceAll(',', '.').replaceAll(' ', '');
    }

    final numericValue = num.tryParse(valeurString);
    if (numericValue == null) {
      return 'Veuillez saisir un nombre valide';
    }

    return _validateNumericConstraints(critere, numericValue);
  }

  static String? _validateNumericConstraints(
    CritereTarification critere,
    num valeur,
  ) {
    num? minGlobal;
    num? maxGlobal;

    for (final valeurCritere in critere.valeurs) {
      if (valeurCritere.valeurMin != null) {
        minGlobal = minGlobal == null
            ? valeurCritere.valeurMin
            : (valeurCritere.valeurMin! < minGlobal ? valeurCritere.valeurMin : minGlobal);
      }
      if (valeurCritere.valeurMax != null) {
        maxGlobal = maxGlobal == null
            ? valeurCritere.valeurMax
            : (valeurCritere.valeurMax! > maxGlobal ? valeurCritere.valeurMax : maxGlobal);
      }
    }

    if (minGlobal != null && valeur < minGlobal) {
      return 'Valeur minimum: $minGlobal';
    }
    if (maxGlobal != null && valeur > maxGlobal) {
      return 'Valeur maximum: $maxGlobal';
    }
    return null;
  }

  static String? _validateCategoricalCritere(
    CritereTarification critere,
    dynamic valeur,
  ) {
    if (!critere.hasValeurs) {
      return null;
    }

    final valeurString = valeur.toString();
    if (!critere.valeursString.contains(valeurString)) {
      return 'Valeur non autorisée';
    }

    return null;
  }

  static num? cleanNumericValue(CritereTarification critere, dynamic valeur) {
    if (valeur == null) return null;

    String valeurString = valeur.toString();

    if (_critereNecessiteFormatage(critere)) {
      valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
    }

    return num.tryParse(valeurString);
  }

  static bool _critereNecessiteFormatage(CritereTarification critere) {
    final nomCritereLower = critere.nom.toLowerCase();

    return _fieldsWithSeparators.any(
      (field) => nomCritereLower.contains(field.toLowerCase()),
    );
  }

  static bool _isEmpty(dynamic valeur) {
    if (valeur == null) return true;
    if (valeur is String) return valeur.trim().isEmpty;
    return false;
  }

  static Map<String, String> validateForm(
    List<CritereTarification> criteres,
    Map<String, dynamic> reponses,
  ) {
    final Map<String, String> errors = {};

    for (final critere in criteres) {
      final valeur = reponses[critere.nom];
      final error = validateCritere(critere, valeur);

      if (error != null) {
        errors[critere.nom] = error;
      }
    }

    return errors;
  }

  static bool isFormValid(
    List<CritereTarification> criteres,
    Map<String, dynamic> reponses,
  ) {
    final errors = validateForm(criteres, reponses);
    return errors.isEmpty;
  }
}
