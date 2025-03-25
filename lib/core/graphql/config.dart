class GraphQLConfig {
  static const String apiUrl = String.fromEnvironment("API_URL");

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

  static Map<String, String> getAuthHeaders(String token) => {
        ...defaultHeaders,
      };
}
