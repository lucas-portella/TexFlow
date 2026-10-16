import 'dart:convert';

import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/models/etapa.dart';
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class EtapaService {
  static Future<List<Etapa>> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/etapas'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar as etapas'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => Etapa.fromMap(item)).toList();
  }

  static Future<Etapa> salvar({
    int? id,
    required String nome,
    required double valorComissao,
  }) async {
    final url = '${ApiConfig.baseUrl}/api/etapas${id == null ? '' : '/$id'}';
    final corpo = jsonEncode({'nome': nome, 'valorComissao': valorComissao});

    final response = id == null
        ? await http.post(Uri.parse(url), headers: cabecalhosJson, body: corpo)
        : await http.put(Uri.parse(url), headers: cabecalhosJson, body: corpo);

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao salvar a etapa'));
    }

    return Etapa.fromMap(decodificar(response));
  }

  static Future<void> excluir(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/etapas/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao excluir a etapa'));
    }
  }
}
