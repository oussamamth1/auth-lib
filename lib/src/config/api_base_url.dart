// lib/src/config/api_base_url.dart
library api_base_url;

/// A global place to store and access your base URL.
class ApiBaseUrl {
  static String _baseUrl = "";

  /// Initialize with your API base URL
  static void initialize(String url) {
    _baseUrl = url;
  }

  /// Get the API base URL
  static String get baseUrl => _baseUrl;
}
