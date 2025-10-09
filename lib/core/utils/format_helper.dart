import 'package:intl/intl.dart';

/// Classe utilitaire pour le formatage des montants et nombres
class FormatHelper {
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'fr_FR');

  /// Formate un montant avec séparateurs de milliers et ajoute "FCFA"
  static String formatMontant(double montant) {
    return '${_numberFormat.format(montant)} FCFA';
  }

  /// Formate un montant avec séparateurs de milliers sans "FCFA"
  static String formatNombre(double nombre) {
    return _numberFormat.format(nombre);
  }

  /// Formate un montant optionnel (peut être null)
  static String? formatMontantOptionnel(double? montant) {
    if (montant == null || montant <= 0) return null;
    return formatMontant(montant);
  }

  /// Formate un montant optionnel avec texte par défaut
  static String formatMontantAvecDefaut(
    double? montant, {
    String defaut = 'Non applicable',
  }) {
    if (montant == null || montant <= 0) return defaut;
    return formatMontant(montant);
  }

  /// Formate le texte d'un calcul en ajoutant des séparateurs de milliers aux nombres
  static String formatTexteCalcul(String texte) {
    // Expression régulière pour trouver les nombres de 4 chiffres ou plus
    final RegExp numberRegex = RegExp(r'\b\d{4,}\b');

    return texte.replaceAllMapped(numberRegex, (match) {
      final number = int.tryParse(match.group(0)!);
      if (number != null) {
        return _numberFormat.format(number);
      }
      return match.group(0)!;
    });
  }
}
