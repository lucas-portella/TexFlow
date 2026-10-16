class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://texflow-backend-2ipr.onrender.com',
  );
}
