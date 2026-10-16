import 'package:texflow/models/registro_log.dart';
import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class LogsService {
  static Future<List<RegistroLog>> listar({
    required DateTime inicio,
    required DateTime fim,
    TipoLog? tipo,
  }) async {
    final parametros = {
      'inicio': inicio.toUtc().toIso8601String(),
      'fim': fim.toUtc().toIso8601String(),
      if (tipo != null) 'tipo': tipo.json,
    };
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/logs',
    ).replace(queryParameters: parametros);

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar os logs'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => RegistroLog.fromMap(item)).toList();
  }
}
