import 'dart:convert';

import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/services/api_client.dart' as http;
import 'package:texflow/services/api_config.dart';
import 'package:texflow/services/api_helper.dart';

class UsuarioService {
  static Future<Usuario> criar({
    required String nome,
    required String email,
    required String senha,
    required UserType tipo,
    String? cargo,
    Set<Modulo>? modulos,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios'),
      headers: cabecalhosJson,
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
        'tipo': tipo.name,
        'cargo': cargo,
        if (modulos != null) 'modulos': Modulo.paraJson(modulos),
      }),
    );

    if (response.statusCode == 200) {
      return Usuario.fromMap(decodificar(response));
    }

    throw Exception(mensagemDeErro(response, 'Erro ao cadastrar usuario'));
  }

  static Future<List<Usuario>> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar os usuarios'));
    }

    final lista = decodificar(response) as List<dynamic>;
    return lista.map((item) => Usuario.fromMap(item)).toList();
  }

  static Future<Usuario> eu() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/me'),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao buscar o usuario'));
    }

    return Usuario.fromMap(decodificar(response));
  }

  static Future<Usuario> atualizar({
    required int id,
    required String nome,
    required String email,
    String? cargo,
    UserType? tipo,
    String? novaSenha,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/$id'),
      headers: cabecalhosJson,
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'cargo': cargo ?? '',
        if (tipo != null) 'tipo': tipo.name,
        if (novaSenha != null && novaSenha.isNotEmpty) 'novaSenha': novaSenha,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao alterar o usuario'));
    }

    return Usuario.fromMap(decodificar(response));
  }

  static Future<Usuario> alterarModulos(int id, Set<Modulo> modulos) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/$id/modulos'),
      headers: cabecalhosJson,
      body: jsonEncode({'modulos': Modulo.paraJson(modulos)}),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao salvar os acessos'));
    }

    return Usuario.fromMap(decodificar(response));
  }

  static Future<String?> alterarSenha({
    required int usuarioId,
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/$usuarioId/senha'),
      headers: cabecalhosJson,
      body: jsonEncode({'senhaAtual': senhaAtual, 'novaSenha': novaSenha}),
    );

    if (response.statusCode != 200) {
      throw Exception(mensagemDeErro(response, 'Erro ao alterar a senha'));
    }

    return decodificar(response)['token'] as String?;
  }
}
