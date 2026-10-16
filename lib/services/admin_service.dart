import 'dart:convert';

import 'package:texflow/models/empresa_cliente.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class AdminService {
  static Map<String, String> _cabecalhos(String token) => {
    ...cabecalhosJson,
    'Authorization': 'Bearer $token',
  };

  static Future<String> entrar(String usuario, String codigo) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/admin/login'),
      headers: cabecalhosJson,
      body: jsonEncode({'usuario': usuario, 'codigo': codigo}),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao entrar no painel'));
    }

    return decodificar(response)['token'] as String;
  }

  static Future<List<EmpresaCliente>> listar(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/admin/empresas'),
      headers: _cabecalhos(token),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar as empresas'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => EmpresaCliente.fromMap(item)).toList();
  }

  static Future<void> criar(
    String token, {
    required String nomeFantasia,
    String? cnpj,
    required String usuarioNome,
    required String usuarioEmail,
    required String usuarioSenha,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/admin/empresas'),
      headers: _cabecalhos(token),
      body: jsonEncode({
        'nomeFantasia': nomeFantasia,
        'cnpj': cnpj,
        'usuarioNome': usuarioNome,
        'usuarioEmail': usuarioEmail,
        'usuarioSenha': usuarioSenha,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao cadastrar a empresa'));
    }
  }

  static Future<void> alterarAtiva(String token, int id, bool ativa) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/admin/empresas/$id/ativa'),
      headers: _cabecalhos(token),
      body: jsonEncode({'ativa': ativa}),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao alterar a empresa'));
    }
  }

  static Future<void> redefinirSenhaDoDono(
    String token,
    int id,
    String novaSenha,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/admin/empresas/$id/senha-do-dono'),
      headers: _cabecalhos(token),
      body: jsonEncode({'novaSenha': novaSenha}),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao redefinir a senha'));
    }
  }

  static Future<void> alterarModulos(
    String token,
    int id,
    Set<Modulo> modulos,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/admin/empresas/$id/modulos'),
      headers: _cabecalhos(token),
      body: jsonEncode({'modulos': Modulo.paraJson(modulos)}),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao salvar o pacote'));
    }
  }
}
