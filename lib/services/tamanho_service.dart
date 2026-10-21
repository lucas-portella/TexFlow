import 'dart:convert';

import 'package:texflow/models/tamanho.dart';
import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class TamanhoService {
  static Future<List<Tamanho>> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/tamanhos'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar os tamanhos'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => Tamanho.fromMap(item)).toList();
  }

  static Future<Tamanho> salvar({int? id, required String nome}) async {
    final url = '${ApiConfig.baseUrl}/api/tamanhos${id == null ? '' : '/$id'}';
    final corpo = jsonEncode({'nome': nome});

    final response = id == null
        ? await http.post(Uri.parse(url), headers: cabecalhosJson, body: corpo)
        : await http.put(Uri.parse(url), headers: cabecalhosJson, body: corpo);

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao salvar o tamanho'));
    }

    return Tamanho.fromMap(decodificar(response));
  }

  static Future<void> excluir(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/tamanhos/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao excluir o tamanho'));
    }
  }
}
