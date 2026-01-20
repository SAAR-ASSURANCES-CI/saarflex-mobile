import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:saarciflex_app/core/constants/api_constants.dart';
import 'package:saarciflex_app/core/utils/storage_helper.dart';

class FileUploadService {
  Future<String> uploadIdentityDocument({
    required File imageFile,
    required String type,
    required String authToken,
  }) async {
    _validateImageFile(imageFile);

    final request = await _createUploadRequest(
      imageFile: imageFile,
      type: type,
      authToken: authToken,
    );

    final response = await _sendUploadRequest(request);

    final imageUrl = await _extractImageUrl(response);

    return imageUrl;
  }

  Future<Map<String, String>> uploadBothImages({
    required String rectoPath,
    required String versoPath,
    required String authToken,
  }) async {
    final rectoFile = File(rectoPath);
    final versoFile = File(versoPath);

    _validateImageFile(rectoFile);
    _validateImageFile(versoFile);

    final request = await _createMultiUploadRequest(
      rectoFile: rectoFile,
      versoFile: versoFile,
      authToken: authToken,
    );

    final response = await _sendUploadRequest(request);

    final urls = await _extractImageUrls(response);

    return urls;
  }

  Future<Map<String, String>> uploadAssureImages({
    required String devisId,
    required String rectoPath,
    required String versoPath,
    required String authToken,
  }) async {
    final rectoFile = File(rectoPath);
    final versoFile = File(versoPath);

    _validateImageFile(rectoFile);
    _validateImageFile(versoFile);

    final request = await _createDevisUploadRequest(
      devisId: devisId,
      rectoFile: rectoFile,
      versoFile: versoFile,
      authToken: authToken,
    );

    final response = await _sendUploadRequest(request);

    final urls = await _extractImageUrls(response);

    return urls;
  }

  void _validateImageFile(File imageFile) {
    if (!imageFile.existsSync()) {
      throw Exception('Fichier introuvable: ${imageFile.path}');
    }

    final fileSize = imageFile.lengthSync();
    if (fileSize > ApiConstants.maxFileSizeBytes) {
      throw Exception(
        'Fichier trop volumineux: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB (max ${ApiConstants.maxFileSizeBytes ~/ (1024 * 1024)}MB)',
      );
    }

    final extension = path.extension(imageFile.path).toLowerCase();
    if (!ApiConstants.allowedImageExtensions.contains(extension)) {
      throw Exception('Format de fichier non supporté: $extension');
    }
  }

  MediaType _getContentTypeFromExtension(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    if (extension == '.png') {
      return MediaType('image', 'png');
    } else if (extension == '.webp') {
      return MediaType('image', 'webp');
    } else {
      return MediaType('image', 'jpeg');
    }
  }

  Future<http.MultipartRequest> _createUploadRequest({
    required File imageFile,
    required String type,
    required String authToken,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadDocument}'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Accept': 'application/json',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: path.basename(imageFile.path),
        contentType: _getContentTypeFromExtension(imageFile.path),
      ),
    );

    request.fields['type'] = type;

    return request;
  }

  Future<http.MultipartRequest> _createMultiUploadRequest({
    required File rectoFile,
    required File versoFile,
    required String authToken,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadImages}'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Accept': 'application/json',
    });

    final rectoExtension = path.extension(rectoFile.path);
    final versoExtension = path.extension(versoFile.path);

    request.files.add(
      await http.MultipartFile.fromPath(
        'files',
        rectoFile.path,
        filename: 'recto$rectoExtension',
        contentType: _getContentTypeFromExtension(rectoFile.path),
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'files',
        versoFile.path,
        filename: 'verso$versoExtension',
        contentType: _getContentTypeFromExtension(versoFile.path),
      ),
    );

    return request;
  }

  Future<http.MultipartRequest> _createDevisUploadRequest({
    required String devisId,
    required File rectoFile,
    required File versoFile,
    required String authToken,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.uploadAssureImages}/$devisId/upload/assure-images',
      ),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Accept': 'application/json',
    });

    final rectoExtension = path.extension(rectoFile.path);
    final versoExtension = path.extension(versoFile.path);

    request.files.add(
      await http.MultipartFile.fromPath(
        'files',
        rectoFile.path,
        filename: 'recto$rectoExtension',
        contentType: _getContentTypeFromExtension(rectoFile.path),
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'files',
        versoFile.path,
        filename: 'verso$versoExtension',
        contentType: _getContentTypeFromExtension(versoFile.path),
      ),
    );

    return request;
  }

  Future<http.StreamedResponse> _sendUploadRequest(
    http.MultipartRequest request,
  ) async {
    final streamedResponse = await request.send();

    if (streamedResponse.statusCode != 200 &&
        streamedResponse.statusCode != 201) {
      final responseBody = await streamedResponse.stream.bytesToString();
      
      try {
        final errorData = json.decode(responseBody);
        final errorMessage = errorData['message'] ?? 'Erreur lors de l\'upload';
        throw Exception('$errorMessage (${streamedResponse.statusCode})');
      } catch (e) {
        throw Exception('Erreur serveur (${streamedResponse.statusCode}): $responseBody');
      }
    }

    return streamedResponse;
  }

  Future<String> _extractImageUrl(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    String? imagePath = responseData['data']?['url'] ?? responseData['url'];

    if (imagePath == null) {
      throw Exception('URL de l\'image non reçue du serveur. Réponse: $responseBody');
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    final baseUri = Uri.parse(ApiConstants.baseUrl);
    final normalizedPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return baseUri.resolve(normalizedPath).toString();
  }

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

  Future<String> uploadAvatar(String imagePath) async {
    final token = await StorageHelper.getToken();
    if (token == null) {
      throw Exception('Authentification requise');
    }

    final imageFile = File(imagePath);
    _validateImageFile(imageFile);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadAvatar}'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagePath,
        filename: path.basename(imagePath),
        contentType: _getContentTypeFromExtension(imagePath),
      ),
    );

    final response = await _sendUploadRequest(request);
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    final avatarPath = responseData['avatar_path'];
    
    if (avatarPath == null) {
      throw Exception('Chemin de l\'avatar non reçu du serveur');
    }

    return avatarPath;
  }

  Future<String> uploadIdentityDocumentFromPath(
    String imagePath,
    String documentType,
  ) async {
    final token = await StorageHelper.getToken();
    if (token == null) {
      throw Exception('Authentification requise');
    }

    final imageFile = File(imagePath);
    return await uploadIdentityDocument(
      imageFile: imageFile,
      type: documentType,
      authToken: token,
    );
  }

  Future<void> validateXFile(XFile xFile) async {
    final fileSize = await xFile.length();
    if (fileSize > ApiConstants.maxFileSizeBytes) {
      throw Exception(
        'Le fichier est trop volumineux. Taille maximum: ${ApiConstants.maxFileSizeBytes ~/ (1024 * 1024)}MB',
      );
    }

    final extension = path.extension(xFile.path).toLowerCase();
    if (!ApiConstants.allowedImageExtensions.contains(extension)) {
      throw Exception(
        'Format de fichier non supporté. Formats autorisés: ${ApiConstants.allowedImageExtensions.join(', ')}',
      );
    }
  }
}
