import '../models/critere_tarification_model.dart';
import '../utils/logger.dart';

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

  /// Valide un critère selon son type et ses contraintes
  static String? validateCritere(CritereTarification critere, dynamic valeur) {
    // Validation des champs obligatoires
    if (critere.obligatoire && _isEmpty(valeur)) {
      return 'Ce champ est obligatoire';
    }

    // Si le champ est vide et non obligatoire, pas d'erreur
    if (_isEmpty(valeur)) {
      return null;
    }

    // Validation selon le type de critère
    switch (critere.type) {
      case TypeCritere.numerique:
        return _validateNumericCritere(critere, valeur);
      case TypeCritere.categoriel:
        return _validateCategoricalCritere(critere, valeur);
      case TypeCritere.booleen:
        return null; // Les booléens n'ont pas besoin de validation spéciale
    }
  }

  /// Valide un critère numérique
  static String? _validateNumericCritere(
    CritereTarification critere,
    dynamic valeur,
  ) {
    String valeurString = valeur.toString();

    // Nettoyer les séparateurs si nécessaire
    if (_critereNecessiteFormatage(critere)) {
      valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
    }

    final numericValue = num.tryParse(valeurString);
    if (numericValue == null) {
      return 'Veuillez saisir un nombre valide';
    }

    // Vérifier les contraintes min/max
    return _validateNumericConstraints(critere, numericValue);
  }

  /// Valide les contraintes numériques (min/max)
  static String? _validateNumericConstraints(
    CritereTarification critere,
    num valeur,
  ) {
    for (final valeurCritere in critere.valeurs) {
      if (valeurCritere.valeurMin != null &&
          valeur < valeurCritere.valeurMin!) {
        return 'Valeur minimum: ${valeurCritere.valeurMin}';
      }
      if (valeurCritere.valeurMax != null &&
          valeur > valeurCritere.valeurMax!) {
        return 'Valeur maximum: ${valeurCritere.valeurMax}';
      }
    }
    return null;
  }

  /// Valide un critère catégoriel
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

  /// Nettoie une valeur numérique en supprimant les séparateurs
  static num? cleanNumericValue(CritereTarification critere, dynamic valeur) {
    if (valeur == null) return null;

    String valeurString = valeur.toString();

    if (_critereNecessiteFormatage(critere)) {
      valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
    }

    return num.tryParse(valeurString);
  }

  /// Détermine si un critère nécessite un formatage spécial
  static bool _critereNecessiteFormatage(CritereTarification critere) {
    final nomCritereLower = critere.nom.toLowerCase();

    AppLogger.debug(
      'Analyzing: "${critere.nom}" -> lowercase: "$nomCritereLower"',
    );

    return _fieldsWithSeparators.any(
      (field) => nomCritereLower.contains(field.toLowerCase()),
    );
  }

  /// Vérifie si une valeur est vide
  static bool _isEmpty(dynamic valeur) {
    if (valeur == null) return true;
    if (valeur is String) return valeur.trim().isEmpty;
    return false;
  }

  /// Valide un formulaire complet
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

  /// Vérifie si un formulaire est valide
  static bool isFormValid(
    List<CritereTarification> criteres,
    Map<String, dynamic> reponses,
  ) {
    final errors = validateForm(criteres, reponses);
    return errors.isEmpty;
  }
}
