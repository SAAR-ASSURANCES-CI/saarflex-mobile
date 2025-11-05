class ApiConfig {
  static const String baseUrl = 'https://c04093492725.ngrok-free.app';
  static const Duration timeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
