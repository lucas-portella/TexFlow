import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:texflow/models/empresa.dart';
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class EmpresaService {
  static Future<List<Empresa>> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/empresas'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar empresas'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => Empresa.fromMap(item)).toList();
  }

  static Future<Empresa> criar({
    required String nomeFantasia,
    required String cnpj,
    required String contatoNome,
    required String contatoTelefone,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/empresas'),
      headers: cabecalhosJson,
      body: jsonEncode({
        'nomeFantasia': nomeFantasia,
        'cnpj': cnpj,
        'contato': {'nome': contatoNome, 'telefone': contatoTelefone},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao cadastrar empresa'));
    }

    return Empresa.fromMap(decodificar(response));
  }
}
