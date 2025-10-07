import 'package:flutter/material.dart';
import 'package:saarflex_app/constants/colors.dart';

class ProfileHelpers {
  /// Formate une date au format DD/MM/YYYY
  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  /// Obtient le label pour le type de pièce d'identité
  static String getTypePieceIdentiteLabel(String? type) {
    switch (type?.toLowerCase()) {
      case 'cni':
        return 'Carte Nationale d\'Identité';
      case 'passport':
        return 'Passeport';
      case 'permis':
        return 'Permis de conduire';
      case 'carte_sejour':
        return 'Carte de séjour';
      default:
        return type ?? 'Non renseigné';
    }
  }

  /// Détermine la couleur selon l'état d'expiration d'une date
  static Color? getExpirationDateColor(String value) {
    if (value == "Non renseignée") return null;

    try {
      final parts = value.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final expirationDate = DateTime(year, month, day);
        final now = DateTime.now();
        final daysUntilExpiration = expirationDate.difference(now).inDays;

        if (daysUntilExpiration < 0) {
          return AppColors.error;
        } else if (daysUntilExpiration <= 30) {
          return AppColors.warning;
        } else {
          return AppColors.success;
        }
      }
    } catch (e) {
      // En cas d'erreur de parsing, retourner null pour utiliser la couleur par défaut
    }
    return null;
  }

  /// Construit l'URL complète d'une image
  static String buildImageUrl(String imageUrl, String baseUrl) {
    return imageUrl.startsWith('http') ? imageUrl : '$baseUrl/$imageUrl';
  }

  /// Vérifie si une image est valide
  static bool isValidImage(String? imageUrl) {
    return imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl != 'null' &&
        imageUrl != 'undefined';
  }
}
