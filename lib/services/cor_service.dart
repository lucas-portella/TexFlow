import 'dart:convert';

import 'package:texflow/models/cor.dart';
import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class CorService {
  static Future<List<Cor>> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/cores'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar as cores'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => Cor.fromMap(item)).toList();
  }

  static Future<Cor> salvar({
    int? id,
    required String nome,
    required String hex,
  }) async {
    final url = '${ApiConfig.baseUrl}/api/cores${id == null ? '' : '/$id'}';
    final corpo = jsonEncode({'nome': nome, 'hex': hex});

    final response = id == null
        ? await http.post(Uri.parse(url), headers: cabecalhosJson, body: corpo)
        : await http.put(Uri.parse(url), headers: cabecalhosJson, body: corpo);

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao salvar a cor'));
    }

    return Cor.fromMap(decodificar(response));
  }

  static Future<void> excluir(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/cores/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao excluir a cor'));
    }
  }
}
