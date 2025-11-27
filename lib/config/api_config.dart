/// API Configuration for ProxiMate
/// 
/// This file handles environment-specific API URLs.
/// The API URL can be set via environment variable API_BASE_URL
/// or defaults to localhost for development.
class ApiConfig {
  /// Get the API base URL from environment or use default
  static String get baseUrl {
    // In Flutter web, you can access environment variables via String.fromEnvironment
    const apiUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000',
    );
    return apiUrl;
  }

  /// Check if running in production mode
  static bool get isProduction {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    return env == 'production';
  }
}
