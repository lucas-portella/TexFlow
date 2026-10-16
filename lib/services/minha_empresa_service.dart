import 'dart:convert';

import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/models/minha_empresa.dart';
import 'package:texflow/models/modo_operacao.dart';
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class MinhaEmpresaService {
  static Future<MinhaEmpresa> buscar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/minha-empresa'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar sua empresa'));
    }

    return MinhaEmpresa.fromMap(decodificar(response));
  }

  static Future<MinhaEmpresa> salvar(MinhaEmpresa empresa) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/minha-empresa'),
      headers: cabecalhosJson,
      body: jsonEncode(empresa.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao salvar sua empresa'));
    }

    return MinhaEmpresa.fromMap(decodificar(response));
  }

  static Future<MinhaEmpresa> alterarModoOperacao(ModoOperacao modo) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/minha-empresa/modo-operacao'),
      headers: cabecalhosJson,
      body: jsonEncode({'modoOperacao': modo.json}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        mensagemDeErro(response, 'Erro ao alterar o modo de operação'),
      );
    }

    return MinhaEmpresa.fromMap(decodificar(response));
  }
}
