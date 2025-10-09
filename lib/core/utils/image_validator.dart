import 'dart:io';
import 'package:saarflex_app/core/constants/api_constants.dart';

class ImageValidator {
  static Future<bool> validateImage(String imagePath) async {
    try {
      final file = File(imagePath);

      // Vérifier que le fichier existe
      if (!await file.exists()) {
        return false;
      }

      // Vérifier uniquement la taille du fichier
      final fileSize = await file.length();
      if (fileSize > ApiConstants.maxImageSizeBytes) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getValidationError(String imagePath) async {
    try {
      final file = File(imagePath);

      if (!await file.exists()) {
        return 'Fichier introuvable';
      }

      final fileSize = await file.length();
      if (fileSize > ApiConstants.maxImageSizeBytes) {
        return 'Fichier trop volumineux (max ${ApiConstants.maxImageSizeBytes ~/ (1024 * 1024)}MB)';
      }

      return null;
    } catch (e) {
      return 'Erreur lors de la validation de l\'image';
    }
  }
}
