import 'dart:convert';

import 'package:texflow/models/custo.dart';
import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class CustoService {
  static Future<List<Custo>> listar(String mes) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/custos?mes=$mes'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar os custos'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => Custo.fromMap(item)).toList();
  }

  static Future<void> salvar({
    int? id,
    required String descricao,
    required CategoriaCusto categoria,
    required double valor,
    required String data,
    int? intervaloDias,
    String? dataFim,
  }) async {
    final url = '${ApiConfig.baseUrl}/api/custos${id == null ? '' : '/$id'}';
    final corpo = jsonEncode({
      'descricao': descricao,
      'categoria': categoria.json,
      'valor': valor,
      'data': data,
      'intervaloDias': intervaloDias,
      'dataFim': dataFim,
    });

    final response = id == null
        ? await http.post(Uri.parse(url), headers: cabecalhosJson, body: corpo)
        : await http.put(Uri.parse(url), headers: cabecalhosJson, body: corpo);

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao salvar o custo'));
    }
  }

  static Future<void> excluir(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/custos/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao excluir o custo'));
    }
  }
}
