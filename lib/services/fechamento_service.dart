import 'package:http/http.dart' as http;
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class FechamentoService {
  static Future<Fechamento> buscar(String mes) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/fechamento?mes=$mes'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar o fechamento'));
    }

    return Fechamento.fromMap(decodificar(response));
  }
}
