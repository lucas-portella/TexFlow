import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class OperacaoService {
  static Future<List<Operacao>> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/operacoes'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar operacoes'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => Operacao.fromMap(item)).toList();
  }

  static Future<void> criar({
    required int clienteId,
    required String dataEntrega,
    required List<Map<String, dynamic>> gradePedido,
    required List<Map<String, dynamic>> processos,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/operacoes'),
      headers: cabecalhosJson,
      body: jsonEncode({
        'cliente': {'id': clienteId},
        'dataEntrega': dataEntrega,
        'status': Status.naoIniciado.name,
        'gradePedido': gradePedido,
        'processos': processos,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao criar o pedido'));
    }
  }

  static Future<Operacao> atualizarStatusProcesso({
    required int processoId,
    required Status status,
    int? usuarioId,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/processos/$processoId/status'),
      headers: cabecalhosJson,
      body: jsonEncode({'status': status.name, 'usuarioId': usuarioId}),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao atualizar o processo'));
    }

    return Operacao.fromMap(decodificar(response));
  }
}
