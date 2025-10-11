import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:saarflex_app/core/utils/api_config.dart';
import 'package:saarflex_app/core/utils/storage_helper.dart';
import 'package:saarflex_app/core/utils/logger.dart';

/// Service de gestion de l'upload d'images
/// Responsabilité : Logique métier pure pour l'upload d'images
class ImageUploadService {
  static const String _basePath = '/upload';
  static const int _maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];

  /// Upload d'un avatar utilisateur
  /// Logique métier : Upload l'avatar et retourne l'URL
  Future<String> uploadAvatar(String imagePath) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ImageUploadException('Authentification requise');
      }

      // Validation du fichier
      _validateImageFile(imagePath);

      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/avatar');
      final headers = {'Authorization': 'Bearer $token'};

      AppLogger.info('📸 Upload de l\'avatar: $imagePath');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // Ajouter le fichier
      final multipartFile = await http.MultipartFile.fromPath(
        'avatar',
        imagePath,
        filename: path.basename(imagePath),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.api('API Upload Avatar - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final imageUrl = data['url'] ?? data['avatar_url'];

        AppLogger.info('✅ Avatar uploadé avec succès: $imageUrl');
        return imageUrl;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de l\'upload de l\'avatar';
        throw ImageUploadException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Erreur upload avatar: $e');
      throw ImageUploadException(_getUserFriendlyError(e));
    }
  }

  /// Upload d'un document d'identité
  /// Logique métier : Upload un document et retourne l'URL
  Future<String> uploadIdentityDocument(
    String imagePath,
    String documentType, // 'recto' ou 'verso'
  ) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ImageUploadException('Authentification requise');
      }

      // Validation du fichier
      _validateImageFile(imagePath);

      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/identity');
      final headers = {'Authorization': 'Bearer $token'};

      AppLogger.info('📄 Upload document $documentType: $imagePath');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // Ajouter le fichier
      final multipartFile = await http.MultipartFile.fromPath(
        'document',
        imagePath,
        filename: path.basename(imagePath),
      );
      request.files.add(multipartFile);

      // Ajouter le type de document
      request.fields['type'] = documentType;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.api('API Upload Document - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final imageUrl = data['url'] ?? data['document_url'];

        AppLogger.info(
          '✅ Document $documentType uploadé avec succès: $imageUrl',
        );
        return imageUrl;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de l\'upload du document';
        throw ImageUploadException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Erreur upload document: $e');
      throw ImageUploadException(_getUserFriendlyError(e));
    }
  }

  /// Upload multiple d'images
  /// Logique métier : Upload plusieurs images en une fois
  Future<List<String>> uploadMultipleImages(
    List<String> imagePaths,
    String category, // 'profile', 'documents', etc.
  ) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ImageUploadException('Authentification requise');
      }

      // Validation de tous les fichiers
      for (final imagePath in imagePaths) {
        _validateImageFile(imagePath);
      }

      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/multiple');
      final headers = {'Authorization': 'Bearer $token'};

      AppLogger.info(
        '📸 Upload multiple ($category): ${imagePaths.length} images',
      );

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // Ajouter toutes les images
      for (int i = 0; i < imagePaths.length; i++) {
        final multipartFile = await http.MultipartFile.fromPath(
          'images',
          imagePaths[i],
          filename: path.basename(imagePaths[i]),
        );
        request.files.add(multipartFile);
      }

      // Ajouter la catégorie
      request.fields['category'] = category;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.api('API Upload Multiple - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final List<dynamic> urls = data['urls'] ?? [];

        AppLogger.info('✅ ${urls.length} images uploadées avec succès');
        return urls.cast<String>();
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de l\'upload des images';
        throw ImageUploadException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Erreur upload multiple: $e');
      throw ImageUploadException(_getUserFriendlyError(e));
    }
  }

  /// Validation d'un fichier image
  /// Logique métier : Valide le fichier selon les règles métier
  void _validateImageFile(String imagePath) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      throw ImageUploadException('Le fichier n\'existe pas');
    }

    // Vérifier la taille du fichier
    final fileSize = file.lengthSync();
    if (fileSize > _maxFileSize) {
      throw ImageUploadException(
        'Le fichier est trop volumineux. Taille maximum: ${_maxFileSize ~/ (1024 * 1024)}MB',
      );
    }

    // Vérifier l'extension
    final extension = path.extension(imagePath).toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw ImageUploadException(
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
      throw ImageUploadException(
        'Le fichier est trop volumineux. Taille maximum: ${_maxFileSize ~/ (1024 * 1024)}MB',
      );
    }

    // Vérifier l'extension
    final extension = path.extension(xFile.path).toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw ImageUploadException(
        'Format de fichier non supporté. Formats autorisés: ${_allowedExtensions.join(', ')}',
      );
    }
  }

  /// Compression d'image (optionnel)
  /// Logique métier : Compresse une image si nécessaire
  Future<String> compressImageIfNeeded(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileSize = file.lengthSync();

      // Si le fichier est déjà assez petit, pas besoin de compression
      if (fileSize <= _maxFileSize) {
        return imagePath;
      }

      AppLogger.info('🗜️ Compression de l\'image nécessaire');

      // Ici vous pourriez ajouter une logique de compression
      // Pour l'instant, on retourne le fichier original
      // Vous pouvez intégrer une bibliothèque comme flutter_image_compress

      return imagePath;
    } catch (e) {
      AppLogger.error('❌ Erreur compression: $e');
      throw ImageUploadException('Erreur lors de la compression de l\'image');
    }
  }

  /// Suppression d'une image
  /// Logique métier : Supprime une image du serveur
  Future<void> deleteImage(String imageUrl) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw ImageUploadException('Authentification requise');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}$_basePath/delete');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final payload = {'url': imageUrl};

      AppLogger.info('🗑️ Suppression de l\'image: $imageUrl');

      final response = await http.delete(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      AppLogger.api('API Suppression - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('✅ Image supprimée avec succès');
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Erreur lors de la suppression';
        throw ImageUploadException(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Erreur suppression image: $e');
      throw ImageUploadException(_getUserFriendlyError(e));
    }
  }

  /// Gestion des erreurs utilisateur
  /// Logique métier : Convertit les erreurs techniques en messages utilisateur
  String _getUserFriendlyError(dynamic error) {
    if (error is SocketException) {
      return 'Problème de connexion internet';
    } else if (error is FormatException) {
      return 'Erreur de format des données';
    } else if (error is HttpException) {
      return 'Erreur de communication avec le serveur';
    } else if (error is String) {
      if (error.contains('400')) return 'Données invalides';
      if (error.contains('401')) return 'Authentification requise';
      if (error.contains('413')) return 'Fichier trop volumineux';
      if (error.contains('415')) return 'Format de fichier non supporté';
      if (error.contains('500')) return 'Erreur interne du serveur';
      return 'Une erreur est survenue';
    }
    return 'Une erreur inattendue est survenue';
  }
}

/// Exception spécialisée pour les erreurs d'upload d'images
class ImageUploadException implements Exception {
  final String message;

  ImageUploadException(this.message);

  @override
  String toString() => message;
}
