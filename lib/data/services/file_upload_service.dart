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
    try {
      _validateImageFile(imageFile);

      final request = await _createUploadRequest(
        imageFile: imageFile,
        type: type,
        authToken: authToken,
      );

      final response = await _sendUploadRequest(request);

      final imageUrl = await _extractImageUrl(response);

      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> uploadBothImages({
    required String rectoPath,
    required String versoPath,
    required String authToken,
  }) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> uploadAssureImages({
    required String devisId,
    required String rectoPath,
    required String versoPath,
    required String authToken,
  }) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  void _validateImageFile(File imageFile) {
    if (!imageFile.existsSync()) {
      throw Exception('Fichier introuvable: ${imageFile.path}');
    }

    final fileSize = imageFile.lengthSync();
    const maxSize = 10 * 1024 * 1024;

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
        contentType: MediaType('image', 'jpeg'),
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

  Future<String> _extractImageUrl(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    final imageUrl = responseData['data']?['url'] ?? responseData['url'];

    if (imageUrl == null) {
      throw Exception('URL de l\'image non reçue du serveur');
    }

    return imageUrl;
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
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        throw Exception('Authentification requise');
      }

      final imageFile = File(imagePath);
      _validateImageFile(imageFile);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadBasePath}/avatar'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          imagePath,
          filename: path.basename(imagePath),
        ),
      );

      final response = await _sendUploadRequest(request);
      final imageUrl = await _extractImageUrl(response);

      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadIdentityDocumentFromPath(
    String imagePath,
    String documentType,
  ) async {
    try {
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
    } catch (e) {
      rethrow;
    }
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
