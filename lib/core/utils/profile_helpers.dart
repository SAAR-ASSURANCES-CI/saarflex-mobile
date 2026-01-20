import 'package:flutter/material.dart';
import 'package:saarciflex_app/core/constants/colors.dart';

class ProfileHelpers {

  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

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
      // ignore: empty_catches
    }
    return null;
  }

  static String buildImageUrl(String imageUrl, String baseUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      if (imageUrl.contains('localhost') || imageUrl.contains('127.0.0.1')) {
        try {
          final uri = Uri.parse(imageUrl);
          final path = uri.path;
          final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
          final out = '$baseUrl/$normalizedPath';
          return out;
        } catch (e) {
          return imageUrl;
        }
      }
      return imageUrl;
    }
    
    final normalizedPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    final out = '$baseUrl/$normalizedPath';
    return out;
  }



  static bool isValidImage(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty;
  }
}
