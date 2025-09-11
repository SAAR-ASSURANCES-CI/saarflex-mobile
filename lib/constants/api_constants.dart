class ApiConstants {
  static const String _devBaseUrl = 'http://192.168.3.117:3000';

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
  static const String resetPasswordFinal = '/users/reset-password';
  static const String updateProfile = '/users/me';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

enum Environment { dev, staging, prod }
