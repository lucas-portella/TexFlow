import 'dart:convert';

import 'package:http/http.dart' as http;

dynamic decodificar(http.Response resposta) {
  return jsonDecode(utf8.decode(resposta.bodyBytes));
}

String mensagemDeErro(http.Response resposta, String padrao) {
  try {
    final corpo = decodificar(resposta);
    final mensagem = corpo['message'];
    if (mensagem is String && mensagem.isNotEmpty) return mensagem;
  } catch (_) {
    return padrao;
  }
  return padrao;
}

Map<String, String> get cabecalhosJson => {'Content-Type': 'application/json'};
