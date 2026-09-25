import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:texflow/models/operacao.dart';
import 'package:texflow/services/api_config.dart';

class OperacaoService {
  static Future<List<Operacao>> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/operacoes'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar operacoes');
    }

    final lista = jsonDecode(response.body) as List<dynamic>;
    return lista.map((item) => Operacao.fromMap(item)).toList();
  }
}
