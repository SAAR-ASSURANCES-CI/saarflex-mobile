import 'package:saarflex_app/data/models/simulation_model.dart';

class SimulationFormatters {
  static String formatCalculationText(String text) {
    return text.replaceAllMapped(RegExp(r'\b\d{1,3}(?:\s\d{3})*\b'), (match) {
      final number = match.group(0)?.replaceAll(' ', '') ?? '';
      return _formatNumberWithSpaces(int.tryParse(number) ?? 0);
    });
  }

  static String _formatNumberWithSpaces(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  static String formatPrimeWithPeriodicity(double prime, String periodicite) {
    final formattedPrime = _formatNumberWithSpaces(prime.toInt());
    final periodiciteFormatee = _formatPeriodicity(periodicite);
    return '$formattedPrime FCFA ($periodiciteFormatee)';
  }

  static String formatFranchise(double? franchise) {
    if (franchise == null || franchise == 0) {
      return 'Non applicable';
    }
    return '${_formatNumberWithSpaces(franchise.toInt())} FCFA';
  }

  static String? formatPlafond(double? plafond) {
    if (plafond == null) return null;
    return '${_formatNumberWithSpaces(plafond.toInt())} FCFA';
  }

  static String _formatPeriodicity(String periodicite) {
    switch (periodicite.toLowerCase()) {
      case 'mensuel':
        return 'mensuelle';
      case 'annuel':
        return 'annuelle';
      case 'trimestriel':
        return 'trimestrielle';
      case 'semestriel':
        return 'semestrielle';
      default:
        return periodicite;
    }
  }

  static String formatAssureInfo(Map<String, dynamic> informations) {
    final nom = informations['nom_complet']?.toString() ?? 'Non renseigné';
    final telephone = informations['telephone']?.toString() ?? 'Non renseigné';
    final piece =
        informations['type_piece_identite']?.toString() ?? 'Non renseigné';

    return '$nom - $telephone ($piece)';
  }

  static String formatBeneficiaireInfo(Map<String, dynamic> beneficiaire) {
    final nom = beneficiaire['nom_complet']?.toString() ?? 'Non renseigné';
    final lien =
        beneficiaire['lien_souscripteur']?.toString() ?? 'Non renseigné';

    return '$nom ($lien)';
  }

  static String formatExpirationDate(DateTime? expiresAt) {
    if (expiresAt == null) return 'Non définie';

    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return 'Expiré';
    }

    final days = difference.inDays;
    if (days == 0) {
      return 'Expire aujourd\'hui';
    } else if (days == 1) {
      return 'Expire demain';
    } else if (days <= 7) {
      return 'Expire dans $days jours';
    } else {
      return 'Expire le ${expiresAt.formatDate()}';
    }
  }

  static String formatStatutDevis(StatutDevis statut) {
    switch (statut) {
      case StatutDevis.simulation:
        return 'Simulation en cours';
      case StatutDevis.sauvegarde:
        return 'Sauvegardé';
      case StatutDevis.expire:
        return 'Expiré';
    }
  }

  static String formatCriteresUtilisateur(Map<String, dynamic> criteres) {
    final List<String> criteresFormates = [];

    criteres.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        final keyFormatted = _formatCritereKey(key);
        final valueFormatted = _formatCritereValue(value);
        criteresFormates.add('$keyFormatted: $valueFormatted');
      }
    });

    return criteresFormates.join('\n');
  }

  static String _formatCritereKey(String key) {
    return key
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  static String _formatCritereValue(dynamic value) {
    if (value is num) {
      return _formatNumberWithSpaces(value.toInt());
    }
    return value.toString();
  }
}
