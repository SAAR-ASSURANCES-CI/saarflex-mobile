class ApiConstants {
  static const String _devBaseUrl = 'https://c04093492725.ngrok-free.app';

  static const Environment environment = Environment.dev;

  static String get baseUrl {
    Environment.dev;
    return _devBaseUrl;
  }

  static const String login = '/users/login';
  static const String register = '/users/register';
  static const String logout = '/users/logout';
  static const String forgotPassword = '/users/forgot-password';
  static const String verifyOtp = '/users/verify-otp';
  static const String resetPassword = '/users/reset-password';
  static const String updateProfile = '/users/me';
  static const String uploadDocument = '/users/upload-piece-identite';
  static const String uploadImages = '/profiles/upload/images';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Image upload constraints - Only size restriction
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  // No other restrictions - all formats and dimensions allowed

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

enum Environment { dev, staging, prod }
