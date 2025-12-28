import 'package:saarciflex_app/core/config/environment.dart';

class ApiConstants {
  static Environment get environment => EnvironmentConfig.current;

  static String get baseUrl => EnvironmentConfig.baseUrl;

  static const String login = '/users/login';
  static const String register = '/users/register';
  static const String logout = '/users/logout';
  static const String forgotPassword = '/users/forgot-password';
  static const String verifyOtp = '/users/verify-otp';
  static const String resetPassword = '/users/reset-password';
  static const String updateProfile = '/users/me';
  static const String uploadDocument = '/users/upload-piece-identite';
  static const String uploadImages = '/profiles/upload/images';

  static const String simulationBasePath = '/simulation-devis-simplifie';
  static const String souscriptionBasePath = '/devis';
  static const String profileBasePath = '/profile';
  static const String productsBasePath = '/produits';
  static const String uploadBasePath = '/upload';

  static const String savedQuotes = '/devis-sauvegardes';
  static const String contrats = '/contrats';
  static String contratDocument(String contractId) => '/contrats/$contractId/document';
  static String contratAttestation(String contractId) => '/contrats/$contractId/attestation';
  static const String grillesTarifaires = '/grilles-tarifaires';
  static const String productCriteres = '/criteres';
  static const String uploadAssureImages = '/profiles/devis';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int maxImageSizeBytes = 5 * 1024 * 1024;
  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  static const List<String> allowedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
