import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class FuncionarioService {
  static Future<List<Funcionario>> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/funcionarios'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        mensagemDeErro(response, 'Erro ao buscar os funcionários'),
      );
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => Funcionario.fromMap(item)).toList();
  }

  static Future<Funcionario> salvar({
    int? id,
    required String nome,
    required bool ativo,
  }) async {
    final url =
        '${ApiConfig.baseUrl}/api/funcionarios${id == null ? '' : '/$id'}';
    final corpo = jsonEncode({'nome': nome, 'ativo': ativo});

    final response = id == null
        ? await http.post(Uri.parse(url), headers: cabecalhosJson, body: corpo)
        : await http.put(Uri.parse(url), headers: cabecalhosJson, body: corpo);

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao salvar o funcionário'));
    }

    return Funcionario.fromMap(decodificar(response));
  }

  static Future<void> excluir(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/funcionarios/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        mensagemDeErro(response, 'Erro ao excluir o funcionário'),
      );
    }
  }
}
