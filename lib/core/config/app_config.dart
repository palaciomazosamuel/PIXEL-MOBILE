abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'PIXEL_API_URL',
    defaultValue: 'http://10.0.2.2:3000/',
  );

  static bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;
}
