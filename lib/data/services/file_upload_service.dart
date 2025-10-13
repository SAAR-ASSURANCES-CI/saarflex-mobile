import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:saarflex_app/core/constants/api_constants.dart';
import 'package:saarflex_app/core/utils/logger.dart';

/// Service d'upload de fichiers - Logique métier pour les uploads
/// Responsabilité : Gestion des uploads de fichiers (images, documents)
class FileUploadService {
  /// Upload d'un document d'identité
  /// Upload un fichier image (recto ou verso) pour l'identité
  Future<String> uploadIdentityDocument({
    required File imageFile,
    required String type,
    required String authToken,
  }) async {
    try {
      AppLogger.info('📤 Upload document identité: $type');

      // Validation du fichier
      _validateImageFile(imageFile);

      // Création de la requête
      final request = await _createUploadRequest(
        imageFile: imageFile,
        type: type,
        authToken: authToken,
      );

      // Envoi de la requête
      final response = await _sendUploadRequest(request);

      // Extraction de l'URL
      final imageUrl = await _extractImageUrl(response);

      AppLogger.info('✅ Document uploadé: $imageUrl');
      return imageUrl;
    } catch (e) {
      AppLogger.error('❌ Erreur upload document: $e');
      rethrow;
    }
  }

  /// Upload de deux images (recto et verso)
  /// Upload simultané de deux fichiers images
  Future<Map<String, String>> uploadBothImages({
    required String rectoPath,
    required String versoPath,
    required String authToken,
  }) async {
    try {
      AppLogger.info('📤 Upload images recto/verso');

      final rectoFile = File(rectoPath);
      final versoFile = File(versoPath);

      // Validation des fichiers
      _validateImageFile(rectoFile);
      _validateImageFile(versoFile);

      // Création de la requête multipart
      final request = await _createMultiUploadRequest(
        rectoFile: rectoFile,
        versoFile: versoFile,
        authToken: authToken,
      );

      // Envoi de la requête
      final response = await _sendUploadRequest(request);

      // Extraction des URLs
      final urls = await _extractImageUrls(response);

      AppLogger.info('✅ Images uploadées: ${urls.keys.join(', ')}');
      return urls;
    } catch (e) {
      AppLogger.error('❌ Erreur upload images: $e');
      rethrow;
    }
  }

  /// Upload d'images pour un devis spécifique
  /// Upload d'images liées à un devis d'assurance
  Future<Map<String, String>> uploadAssureImages({
    required String devisId,
    required String rectoPath,
    required String versoPath,
    required String authToken,
  }) async {
    try {
      AppLogger.info('📤 Upload images devis: $devisId');

      final rectoFile = File(rectoPath);
      final versoFile = File(versoPath);

      // Validation des fichiers
      _validateImageFile(rectoFile);
      _validateImageFile(versoFile);

      // Création de la requête pour devis
      final request = await _createDevisUploadRequest(
        devisId: devisId,
        rectoFile: rectoFile,
        versoFile: versoFile,
        authToken: authToken,
      );

      // Envoi de la requête
      final response = await _sendUploadRequest(request);

      // Extraction des URLs
      final urls = await _extractImageUrls(response);

      AppLogger.info('✅ Images devis uploadées: ${urls.keys.join(', ')}');
      return urls;
    } catch (e) {
      AppLogger.error('❌ Erreur upload images devis: $e');
      rethrow;
    }
  }

  /// Validation d'un fichier image
  /// Vérifie que le fichier est valide pour l'upload
  void _validateImageFile(File imageFile) {
    if (!imageFile.existsSync()) {
      throw Exception('Fichier introuvable: ${imageFile.path}');
    }

    final fileSize = imageFile.lengthSync();
    const maxSize = 10 * 1024 * 1024; // 10MB

    if (fileSize > maxSize) {
      throw Exception(
        'Fichier trop volumineux: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB',
      );
    }

    final extension = path.extension(imageFile.path).toLowerCase();
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

    if (!allowedExtensions.contains(extension)) {
      throw Exception('Format de fichier non supporté: $extension');
    }
  }

  /// Création d'une requête d'upload simple
  /// Crée une requête multipart pour un seul fichier
  Future<http.MultipartRequest> _createUploadRequest({
    required File imageFile,
    required String type,
    required String authToken,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadDocument}'),
    );

    // Headers
    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Accept': 'application/json',
    });

    // Ajout du fichier
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: path.basename(imageFile.path),
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    // Paramètres
    request.fields['type'] = type;

    return request;
  }

  /// Création d'une requête d'upload multiple
  /// Crée une requête multipart pour deux fichiers
  Future<http.MultipartRequest> _createMultiUploadRequest({
    required File rectoFile,
    required File versoFile,
    required String authToken,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadImages}'),
    );

    // Headers
    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Accept': 'application/json',
    });

    // Ajout des fichiers
    request.files.add(
      await http.MultipartFile.fromPath(
        'files',
        rectoFile.path,
        filename: 'recto.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'files',
        versoFile.path,
        filename: 'verso.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    return request;
  }

  /// Création d'une requête d'upload pour devis
  /// Crée une requête multipart pour les images de devis
  Future<http.MultipartRequest> _createDevisUploadRequest({
    required String devisId,
    required File rectoFile,
    required File versoFile,
    required String authToken,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConstants.baseUrl}/profiles/devis/$devisId/upload/assure-images',
      ),
    );

    // Headers
    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Accept': 'application/json',
    });

    // Ajout des fichiers
    request.files.add(
      await http.MultipartFile.fromPath(
        'files',
        rectoFile.path,
        filename: 'recto.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'files',
        versoFile.path,
        filename: 'verso.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    return request;
  }

  /// Envoi d'une requête d'upload
  /// Envoie la requête et retourne la réponse
  Future<http.StreamedResponse> _sendUploadRequest(
    http.MultipartRequest request,
  ) async {
    final streamedResponse = await request.send();

    if (streamedResponse.statusCode != 200 &&
        streamedResponse.statusCode != 201) {
      final responseBody = await streamedResponse.stream.bytesToString();
      final errorData = json.decode(responseBody);
      final errorMessage = errorData['message'] ?? 'Erreur lors de l\'upload';
      throw Exception('$errorMessage (${streamedResponse.statusCode})');
    }

    return streamedResponse;
  }

  /// Extraction de l'URL d'image d'une réponse
  /// Extrait l'URL de l'image depuis la réponse serveur
  Future<String> _extractImageUrl(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    final imageUrl = responseData['data']?['url'] ?? responseData['url'];

    if (imageUrl == null) {
      throw Exception('URL de l\'image non reçue du serveur');
    }

    return imageUrl;
  }

  /// Extraction des URLs d'images d'une réponse
  /// Extrait les URLs des images depuis la réponse serveur
  Future<Map<String, String>> _extractImageUrls(
    http.StreamedResponse response,
  ) async {
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    final rectoPath = responseData['recto_path'];
    final versoPath = responseData['verso_path'];

    if (rectoPath == null || versoPath == null) {
      throw Exception('Chemins des images manquants dans la réponse');
    }

    return {'recto_path': rectoPath, 'verso_path': versoPath};
  }
}
