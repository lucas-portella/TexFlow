import 'dart:convert';

import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/models/usuario.dart';
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class AuthService {
  static Future<Usuario> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: cabecalhosJson,
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      return Usuario.fromMap(decodificar(response));
    }

    throw Exception(mensagemDeErro(response, 'Erro ao fazer login'));
  }
}
