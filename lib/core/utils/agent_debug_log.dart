/// Debug logger (disabled for production)
/// This class is kept for API compatibility but logging is disabled
class AgentDebugLog {

  static Future<void> log({
    required String hypothesisId,
    required String location,
    required String message,
    Map<String, Object?> data = const {},
    String runId = 'pre-fix',
  }) async {
    // Debug logging disabled for production
    // This method is kept for API compatibility but does nothing
  }
}


