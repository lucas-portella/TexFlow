import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:texflow/models/usuario.dart';
import 'package:texflow/services/api_config.dart';

class AuthService {
  static Future<Usuario> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      return Usuario.fromMap(jsonDecode(response.body));
    }

    final erro = jsonDecode(response.body);
    throw Exception(erro['message'] ?? 'Erro ao fazer login');
  }

  static Future<Usuario> cadastro(
    String nome,
    String email,
    String senha,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/cadastro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      return Usuario.fromMap(jsonDecode(response.body));
    }

    final erro = jsonDecode(response.body);
    throw Exception(erro['message'] ?? 'Erro ao cadastrar');
  }
}
