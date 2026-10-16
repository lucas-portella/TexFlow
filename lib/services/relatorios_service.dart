import 'package:texflow/models/relatorio.dart';
import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class RelatoriosService {
  static String _data(DateTime data) {
    return '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  }

  static Uri _url(String caminho, DateTime inicio, DateTime fim) {
    return Uri.parse('${ApiConfig.baseUrl}/api/relatorios/$caminho').replace(
      queryParameters: {
        'inicio': _data(inicio),
        'fim': _data(fim),
        'hoje': _data(DateTime.now()),
      },
    );
  }

  static Future<RelatorioEmpresa> empresa(DateTime inicio, DateTime fim) async {
    final response = await http.get(_url('empresa', inicio, fim));

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar o relatório'));
    }

    return RelatorioEmpresa.fromMap(decodificar(response));
  }

  static Future<RelatorioFuncionarios> funcionarios(
    DateTime inicio,
    DateTime fim,
  ) async {
    final response = await http.get(_url('funcionarios', inicio, fim));

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar o relatório'));
    }

    return RelatorioFuncionarios.fromMap(decodificar(response));
  }
}
