import 'package:flutter/foundation.dart';

class ApiLogger {
  static void logCall({
    required String method,
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) {
    if (kDebugMode) {
      print("--------------------------------------------------");
      print("🚀 [API CALL] $method $endpoint");
      if (queryParameters != null && queryParameters.isNotEmpty) {
        print("   Params: $queryParameters");
      }
      if (body != null) {
        print("   Body: $body");
      }
      print("--------------------------------------------------");
    }
  }
}
