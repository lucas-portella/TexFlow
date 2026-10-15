import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:texflow/models/referencia.dart';
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class ReferenciaService {
  static Future<List<Referencia>> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/referencias'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar os modelos'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => Referencia.fromMap(item)).toList();
  }

  static Future<Referencia> salvar({
    int? id,
    required String nome,
    required List<int> etapaIds,
    bool ativo = true,
  }) async {
    final url =
        '${ApiConfig.baseUrl}/api/referencias${id == null ? '' : '/$id'}';
    final corpo = jsonEncode({
      'nome': nome,
      'etapaIds': etapaIds,
      'ativo': ativo,
    });

    final response = id == null
        ? await http.post(Uri.parse(url), headers: cabecalhosJson, body: corpo)
        : await http.put(Uri.parse(url), headers: cabecalhosJson, body: corpo);

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao salvar o modelo'));
    }

    return Referencia.fromMap(decodificar(response));
  }

  static Future<void> excluir(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/referencias/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao excluir o modelo'));
    }
  }
}
