class ApiConfig {
  static const String baseUrl = 'http://10.235.91.176:3000';
  static const Duration timeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
