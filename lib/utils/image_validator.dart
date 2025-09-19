import 'dart:io';
import 'package:image/image.dart' as img;
import '../constants/api_constants.dart';

class ImageValidator {
  static Future<bool> validateImage(String imagePath) async {
    try {
      final file = File(imagePath);

      // Vérifier que le fichier existe
      if (!await file.exists()) {
        return false;
      }

      // Vérifier la taille du fichier
      final fileSize = await file.length();
      if (fileSize > ApiConstants.maxImageSizeBytes) {
        return false;
      }

      // Vérifier l'extension du fichier
      final extension = imagePath.split('.').last.toLowerCase();
      if (!ApiConstants.allowedImageTypes.contains(extension)) {
        return false;
      }

      // Vérifier les dimensions de l'image
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return false;
      }

      if (image.width > ApiConstants.maxImageWidth ||
          image.height > ApiConstants.maxImageHeight) {
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

      final extension = imagePath.split('.').last.toLowerCase();
      if (!ApiConstants.allowedImageTypes.contains(extension)) {
        return 'Format non supporté. Utilisez JPG ou PNG';
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return 'Image corrompue ou format non supporté';
      }

      if (image.width > ApiConstants.maxImageWidth ||
          image.height > ApiConstants.maxImageHeight) {
        return 'Image trop grande (max ${ApiConstants.maxImageWidth}x${ApiConstants.maxImageHeight}px)';
      }

      return null;
    } catch (e) {
      return 'Erreur lors de la validation de l\'image';
    }
  }
}
