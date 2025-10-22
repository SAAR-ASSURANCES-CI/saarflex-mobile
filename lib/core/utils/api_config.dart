class ApiConfig {
  static const String baseUrl = 'http://192.168.2.2:3000';
  static const Duration timeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
