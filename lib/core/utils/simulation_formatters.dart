import 'package:saarflex_app/data/models/critere_tarification_model.dart';
import 'package:saarflex_app/core/utils/format_helper.dart';
import 'package:saarflex_app/core/utils/simulation_validators.dart';

/// Utilitaires de formatage pour la simulation
class SimulationFormatters {
  /// Formate une valeur de critère selon son type
  static String formatCritereValue(
    CritereTarification critere,
    dynamic valeur,
  ) {
    if (valeur == null) return '';

    switch (critere.type) {
      case TypeCritere.numerique:
        return _formatNumerique(critere, valeur);
      case TypeCritere.categoriel:
        return valeur.toString();
      case TypeCritere.booleen:
        return valeur ? 'Oui' : 'Non';
    }
  }

  /// Formate une valeur numérique
  static String _formatNumerique(CritereTarification critere, dynamic valeur) {
    if (valeur == null) return '';

    // Nettoyer la valeur des séparateurs si nécessaire
    String valeurString = valeur.toString();
    if (SimulationValidators.critereNecessiteFormatage(critere)) {
      valeurString = valeurString.replaceAll(RegExp(r'[^\d]'), '');
    }

    final numericValue = num.tryParse(valeurString);
    if (numericValue == null) return valeur.toString();

    // Formater avec séparateurs de milliers si nécessaire
    if (SimulationValidators.critereNecessiteFormatage(critere)) {
      return FormatHelper.formatNombre(numericValue.toDouble());
    }

    return numericValue.toString();
  }

  /// Nettoie les critères en supprimant les séparateurs des champs numériques
  static Map<String, dynamic> nettoyerCriteres(Map<String, dynamic> criteres) {
    final criteresNettoyes = <String, dynamic>{};

    for (final entry in criteres.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String && _isNumericField(key)) {
        // Nettoyer la valeur des séparateurs
        final valeurNettoyee = value.replaceAll(RegExp(r'[^\d]'), '');
        final numericValue = num.tryParse(valeurNettoyee);
        criteresNettoyes[key] = numericValue ?? 0;
      } else {
        criteresNettoyes[key] = value;
      }
    }

    return criteresNettoyes;
  }

  /// Détermine si un champ est numérique et nécessite un nettoyage
  static bool _isNumericField(String fieldName) {
    const champsNumeriques = [
      'capital',
      'capital_assure',
      'montant',
      'prime',
      'franchise',
      'plafond',
      'souscription',
      'assurance',
    ];

    final nomFieldLower = fieldName.toLowerCase();

    for (final motCle in champsNumeriques) {
      if (nomFieldLower.contains(motCle)) {
        return true;
      }
    }

    return false;
  }

  /// Formate un montant avec la devise
  static String formatMontant(double montant) {
    return FormatHelper.formatMontant(montant);
  }

  /// Formate un montant optionnel
  static String? formatMontantOptionnel(double? montant) {
    return FormatHelper.formatMontantOptionnel(montant);
  }

  /// Formate le texte de calcul en ajoutant des séparateurs de milliers
  static String formatTexteCalcul(String texte) {
    return FormatHelper.formatTexteCalcul(texte);
  }

  /// Formate une date au format DD-MM-YYYY
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  /// Formate une date depuis un string DD-MM-YYYY
  static DateTime? parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Retourner null en cas d'erreur de parsing
    }
    return null;
  }
}
