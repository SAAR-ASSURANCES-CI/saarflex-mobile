import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';

/// Service d'upload d'images pour la simulation
/// Gère l'upload des pièces d'identité de l'assuré dans le contexte d'une simulation
class SimulationImageUploadService {
  static const int _maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];

  /// Upload des images d'identité pour un devis spécifique
  /// Logique métier : Upload des documents d'identité de l'assuré
  Future<Map<String, String>> uploadAssureImages({
    required String devisId,
    required String rectoPath,
    required String versoPath,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw SimulationImageUploadException('Authentification requise');
      }

      // Validation des fichiers
      _validateImageFile(rectoPath);
      _validateImageFile(versoPath);

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/profiles/devis/$devisId/upload/assure-images',
      );

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Ajouter les fichiers avec le bon nom de champ et type MIME
      final rectoFile = await http.MultipartFile.fromPath(
        'files',
        rectoPath,
        filename: 'recto.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      final versoFile = await http.MultipartFile.fromPath(
        'files',
        versoPath,
        filename: 'verso.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(rectoFile);
      request.files.add(versoFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final result = <String, String>{
          'recto_path': data['recto_path'] ?? '',
          'verso_path': data['verso_path'] ?? '',
        };

        return result;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ??
            'Erreur lors de l\'upload des images assuré';
        throw SimulationImageUploadException(errorMessage);
      }
    } catch (e) {
      throw SimulationImageUploadException(_getUserFriendlyError(e));
    }
  }

  /// Validation d'un fichier image
  /// Vérifie que le fichier est valide pour l'upload
  void _validateImageFile(String imagePath) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      throw SimulationImageUploadException('Le fichier image n\'existe pas');
    }

    final fileSize = file.lengthSync();
    if (fileSize > _maxFileSize) {
      throw SimulationImageUploadException(
        'Le fichier est trop volumineux. Taille maximum: ${_maxFileSize ~/ (1024 * 1024)}MB',
      );
    }

    final extension = path.extension(imagePath).toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw SimulationImageUploadException(
        'Format de fichier non supporté. Formats autorisés: ${_allowedExtensions.join(', ')}',
      );
    }
  }

  /// Validation d'une image depuis XFile
  /// Logique métier : Valide une image sélectionnée
  Future<void> validateXFile(XFile xFile) async {
    // Vérifier la taille
    final fileSize = await xFile.length();
    if (fileSize > _maxFileSize) {
      throw SimulationImageUploadException(
        'Le fichier est trop volumineux. Taille maximum: ${_maxFileSize ~/ (1024 * 1024)}MB',
      );
    }

    // Vérifier l'extension
    final extension = path.extension(xFile.path).toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw SimulationImageUploadException(
        'Format de fichier non supporté. Formats autorisés: ${_allowedExtensions.join(', ')}',
      );
    }
  }

  /// Conversion d'erreur technique en message utilisateur
  String _getUserFriendlyError(dynamic error) {
    if (error is SimulationImageUploadException) {
      return error.message;
    }

    if (error.toString().contains('SocketException')) {
      return 'Problème de connexion réseau';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'Délai d\'attente dépassé';
    }

    return 'Erreur lors de l\'upload des images';
  }
}

/// Exception spécifique aux uploads d'images de simulation
class SimulationImageUploadException implements Exception {
  final String message;

  const SimulationImageUploadException(this.message);

  @override
  String toString() => 'SimulationImageUploadException: $message';
}
