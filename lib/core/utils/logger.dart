class AppLogger {
  static void debug(String message) {}

  static void info(String message) {}

  static void error(String message, [dynamic error]) {}

  static void errorWithStack(String message, dynamic error, [StackTrace? stackTrace]) {
  }

  static void api(String message) {}

  static void auth(String message) {}

  static void performance(String message) {}

  static void navigation(String message) {}
}
