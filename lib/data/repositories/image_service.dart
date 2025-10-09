import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:saarflex_app/data/repositories/api_service.dart';
import 'package:saarflex_app/core/utils/error_handler.dart';
import 'package:saarflex_app/core/utils/image_validator.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );
    } catch (e) {
      throw Exception(
        'Erreur lors de la sélection de l\'image: ${e.toString()}',
      );
    }
  }

  static Future<String?> processImage(String imagePath) async {
    try {
      String finalImagePath = imagePath;

      // Conversion HEIC → JPEG si nécessaire
      if (imagePath.toLowerCase().endsWith('.heic')) {
        try {
          final File heicFile = File(imagePath);
          final Uint8List heicBytes = await heicFile.readAsBytes();

          final img.Image? decodedImage = img.decodeImage(heicBytes);
          if (decodedImage != null) {
            final Uint8List jpegBytes = img.encodeJpg(
              decodedImage,
              quality: 95,
            );
            final String jpegPath = imagePath.replaceAll('.heic', '.jpg');
            final File jpegFile = File(jpegPath);
            await jpegFile.writeAsBytes(jpegBytes);
            finalImagePath = jpegPath;
          }
        } catch (e) {
          // Continuer avec le fichier original
        }
      }

      // Validation de l'image
      final validationError = await ImageValidator.getValidationError(
        finalImagePath,
      );
      if (validationError != null) {
        throw Exception(validationError);
      }

      return finalImagePath;
    } catch (e) {
      throw Exception('Erreur lors du traitement de l\'image: ${e.toString()}');
    }
  }

  static Future<Map<String, String>> uploadBothImages({
    required String rectoPath,
    required String versoPath,
  }) async {
    try {
      final apiService = ApiService();
      return await apiService.uploadBothImages(
        rectoPath: rectoPath,
        versoPath: versoPath,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'upload des images: ${e.toString()}');
    }
  }

  static void showImageSelectionMessage(BuildContext context, bool isRecto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Image ${isRecto ? 'recto' : 'verso'} sélectionnée. Sélectionnez l\'autre image pour uploader automatiquement.',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  static void showUploadSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Images uploadées avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  static void showUploadErrorMessage(BuildContext context, String error) {
    ErrorHandler.showErrorSnackBar(context, 'Erreur lors de l\'upload: $error');
  }
}
