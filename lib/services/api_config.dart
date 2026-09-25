import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _localUrl = 'http://localhost:8080';
  static const String _renderUrl = 'https://texflow-backend-2ipr.onrender.com';

  static String get baseUrl => kDebugMode ? _localUrl : _renderUrl;
}
