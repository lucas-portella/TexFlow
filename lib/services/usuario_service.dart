import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:texflow/models/usuario.dart';
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class UsuarioService {
  static Future<Usuario> criar({
    required String nome,
    required String email,
    required String senha,
    required UserType tipo,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios'),
      headers: cabecalhosJson,
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
        'tipo': tipo.name,
      }),
    );

    if (response.statusCode == 200) {
      return Usuario.fromMap(decodificar(response));
    }

    throw Exception(mensagemDeErro(response, 'Erro ao cadastrar usuario'));
  }

  static Future<void> alterarSenha({
    required int usuarioId,
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/$usuarioId/senha'),
      headers: cabecalhosJson,
      body: jsonEncode({'senhaAtual': senhaAtual, 'novaSenha': novaSenha}),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao alterar a senha'));
    }
  }
}
