// Your ApiConfig class from the prompt
class ApiConfig {
  final String baseUrl;
  final String contentType;
  // final String authToken;

  const ApiConfig({
    required this.baseUrl,
    required this.contentType,
    // required this.authToken,
  });

  @override
  String toString() {
    return 'ApiConfig(baseUrl: $baseUrl, contentType: $contentType)';
  }
}

final myApiConfig = ApiConfig(
  baseUrl: 'https://classmonitor.aucseapp.in/',
  contentType: 'application/json',
  // authToken: 'Bearer secure',
);
