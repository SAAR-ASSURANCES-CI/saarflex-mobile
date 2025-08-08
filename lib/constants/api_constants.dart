class ApiConstants {
  static const String _devBaseUrl = 'http://localhost:8000/api';
  static const String _stagingBaseUrl = 'https://staging-api.saar-assurance.com/api';
  static const String _prodBaseUrl = 'https://api.saar-assurance.com/api';

  static const Environment environment = Environment.dev;

  static String get baseUrl {
    switch (environment) {
      case Environment.dev:
        return _devBaseUrl;
      case Environment.staging:
        return _stagingBaseUrl;
      case Environment.prod:
        return _prodBaseUrl;
    }
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String resetPassword = '/auth/reset-password';
  static const String userProfile = '/user/profile';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusUnprocessableEntity = 422;
  static const int statusInternalServerError = 500;
}

enum Environment { dev, staging, prod }