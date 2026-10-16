import 'dart:convert';

import 'package:texflow/services/api_client.dart' as http;
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

  static Future<Operacao> buscarPorId(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/operacoes/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar a produção'));
    }

    return Operacao.fromMap(decodificar(response));
  }

  static Future<void> criar({
    required int clienteId,
    required int referenciaId,
    required String numero,
    String? dataEntrega,
    required double valorPeca,
    required int quantidadeSolicitada,
    required List<Map<String, dynamic>> gradePedido,
    required List<Map<String, dynamic>> processos,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/operacoes'),
      headers: cabecalhosJson,
      body: jsonEncode({
        'cliente': {'id': clienteId},
        'numero': numero,
        'referencia': {'id': referenciaId},
        'dataEntrega': dataEntrega,
        'valorPeca': valorPeca,
        'quantidadeSolicitada': quantidadeSolicitada,
        'status': Status.naoIniciado.name,
        'gradePedido': gradePedido,
        'processos': processos,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao criar o pedido'));
    }
  }

  static Future<Operacao> finalizar({
    required int operacaoId,
    required int quantidadeProduzida,
    DateTime? dataEntrega,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/operacoes/$operacaoId/finalizar'),
      headers: cabecalhosJson,
      body: jsonEncode({
        'quantidadeProduzida': quantidadeProduzida,
        if (dataEntrega != null)
          'dataEntrega':
              '${dataEntrega.year}-${dataEntrega.month.toString().padLeft(2, '0')}-${dataEntrega.day.toString().padLeft(2, '0')}',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao finalizar a produção'));
    }

    return Operacao.fromMap(decodificar(response));
  }

  static Future<Operacao> adicionarEtapa({
    required int operacaoId,
    int? etapaId,
    String? nome,
    required double valorComissao,
    required int funcionarioId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/operacoes/$operacaoId/etapas'),
      headers: cabecalhosJson,
      body: jsonEncode({
        'etapaId': etapaId,
        'nome': nome,
        'valorComissao': valorComissao,
        'funcionarioId': funcionarioId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao adicionar a etapa'));
    }

    return Operacao.fromMap(decodificar(response));
  }

  static Future<Operacao> alterarStatus({
    required int operacaoId,
    required Status status,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/operacoes/$operacaoId/status'),
      headers: cabecalhosJson,
      body: jsonEncode({'status': status.name}),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao alterar o status'));
    }

    return Operacao.fromMap(decodificar(response));
  }

  static Future<Operacao> atualizarStatusDasEtapas({
    required int operacaoId,
    required List<int> processoIds,
    required Status status,
    int? usuarioId,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/operacoes/$operacaoId/etapas/status'),
      headers: cabecalhosJson,
      body: jsonEncode({
        'processoIds': processoIds,
        'status': status.name,
        'usuarioId': usuarioId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao atualizar as etapas'));
    }

    return Operacao.fromMap(decodificar(response));
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
