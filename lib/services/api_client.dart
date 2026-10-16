import 'package:http/http.dart' as http;

export 'package:http/http.dart' show Response;

class Sessao {
  static String? token;
  static void Function()? aoExpirar;
}

Map<String, String> _comAutorizacao(Map<String, String>? headers) {
  final token = Sessao.token;
  final jaTem = headers?.containsKey('Authorization') ?? false;
  return {
    ...?headers,
    if (!jaTem && token != null && token.isNotEmpty)
      'Authorization': 'Bearer $token',
  };
}

Future<http.Response> _verificar(Future<http.Response> envio) async {
  final resposta = await envio;
  if (resposta.statusCode == 401 && Sessao.token != null) {
    Sessao.aoExpirar?.call();
  }
  return resposta;
}

Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
  return _verificar(http.get(url, headers: _comAutorizacao(headers)));
}

Future<http.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
}) {
  return _verificar(
    http.post(url, headers: _comAutorizacao(headers), body: body),
  );
}

Future<http.Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
}) {
  return _verificar(
    http.put(url, headers: _comAutorizacao(headers), body: body),
  );
}

Future<http.Response> delete(Uri url, {Map<String, String>? headers}) {
  return _verificar(http.delete(url, headers: _comAutorizacao(headers)));
}
