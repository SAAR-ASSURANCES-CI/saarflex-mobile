import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';

class SimulationImageUploadService {
  static const int _maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];

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

      final rectoFile = await http.MultipartFile.fromPath(
        'files',
        rectoPath,
        filename: _getFileName(rectoPath),
        contentType: _getMediaType(rectoPath),
      );
      final versoFile = await http.MultipartFile.fromPath(
        'files',
        versoPath,
        filename: _getFileName(versoPath),
        contentType: _getMediaType(versoPath),
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

  Future<void> validateXFile(XFile xFile) async {
    final fileSize = await xFile.length();
    if (fileSize > _maxFileSize) {
      throw SimulationImageUploadException(
        'Le fichier est trop volumineux. Taille maximum: ${_maxFileSize ~/ (1024 * 1024)}MB',
      );
    }

    final extension = path.extension(xFile.path).toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw SimulationImageUploadException(
        'Format de fichier non supporté. Formats autorisés: ${_allowedExtensions.join(', ')}',
      );
    }
  }

  String _getFileName(String imagePath) {
    final extension = path.extension(imagePath).toLowerCase();
    final baseName = path.basenameWithoutExtension(imagePath);
    return '$baseName$extension';
  }

  MediaType _getMediaType(String imagePath) {
    final extension = path.extension(imagePath).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

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

class SimulationImageUploadException implements Exception {
  final String message;

  const SimulationImageUploadException(this.message);

  @override
  String toString() => 'SimulationImageUploadException: $message';
}
