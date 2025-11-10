import 'package:intl/intl.dart';

class FormatHelper {
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'fr_FR');

  static String formatMontant(double montant) {
    return '${_numberFormat.format(montant)} FCFA';
  }

  static String formatNombre(double nombre) {
    return _numberFormat.format(nombre);
  }

  static String? formatMontantOptionnel(double? montant) {
    if (montant == null || montant <= 0) return null;
    return formatMontant(montant);
  }

  static String formatMontantAvecDefaut(
    double? montant, {
    String defaut = 'Non applicable',
  }) {
    if (montant == null || montant <= 0) return defaut;
    return formatMontant(montant);
  }

  static String formatTexteCalcul(String texte) {
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
