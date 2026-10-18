import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/routes/app_router.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/services/api_client.dart';
import 'package:texflow/services/auth_service.dart';
import 'package:texflow/services/usuario_service.dart';

class UsuarioProvider extends ChangeNotifier {
  static const _chaveUsuario = 'usuario';
  static const _chaveToken = 'token';

  final _cofre = const FlutterSecureStorage();

  Usuario? _usuario;

  UsuarioProvider() {
    Sessao.aoExpirar = () => _sessaoExpirou();
  }

  Usuario? get usuario => _usuario;

  bool get logado => _usuario != null;

  bool get ehAdm => usuario?.ehAdm ?? false;

  bool get donoDaEmpresa => usuario?.donoDaEmpresa ?? false;

  Future<void> login(String email, String senha) async {
    final usuario = await AuthService.login(email, senha);
    Sessao.token = usuario.token;
    _usuario = usuario;
    notifyListeners();

    await _guardar(usuario);
  }

  Future<void> carregarUsuarioSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveUsuario);

    if (dados == null) return;

    final salvo = Usuario.fromMap(jsonDecode(dados));
    final token = await _cofre.read(key: _chaveToken) ?? salvo.token;
    if (token == null || token.isEmpty) {
      await _esquecer();
      return;
    }

    salvo.token = token;
    _usuario = salvo;
    Sessao.token = token;
    notifyListeners();

    if (_tokenAindaNasPreferencias(prefs)) await _guardar(salvo);
  }

  Future<void> alterarSenha(String senhaAtual, String novaSenha) async {
    final tokenNovo = await UsuarioService.alterarSenha(
      usuarioId: _usuario!.idUsuario,
      senhaAtual: senhaAtual,
      novaSenha: novaSenha,
    );

    if (tokenNovo == null || tokenNovo.isEmpty) return;

    _usuario!.token = tokenNovo;
    Sessao.token = tokenNovo;
    await _guardar(_usuario!);
  }

  Future<void> atualizarPerfil() async {
    final atual = usuario;
    if (atual == null) return;

    try {
      final recebido = await UsuarioService.eu();
      recebido.token = atual.token;
      _usuario = recebido;
      notifyListeners();

      await _guardar(recebido);
    } catch (_) {
      return;
    }
  }

  Future<void> logout() async {
    Sessao.token = null;
    _usuario = null;
    notifyListeners();

    await _esquecer();
  }

  Future<void> _sessaoExpirou() async {
    await logout();
    AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _guardar(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chaveUsuario,
      jsonEncode(usuario.toMap()..remove('token')),
    );
    await _cofre.write(key: _chaveToken, value: usuario.token ?? '');
  }

  Future<void> _esquecer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveUsuario);
    await _cofre.delete(key: _chaveToken);
  }

  bool _tokenAindaNasPreferencias(SharedPreferences prefs) {
    final dados = prefs.getString(_chaveUsuario);
    return dados != null && jsonDecode(dados)['token'] != null;
  }
}
