import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/routes/app_router.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/services/api_client.dart';
import 'package:texflow/services/auth_service.dart';
import 'package:texflow/services/usuario_service.dart';

class UsuarioProvider extends ChangeNotifier {
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', jsonEncode(usuario.toMap()));
  }

  Future<void> carregarUsuarioSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('usuario');

    if (dados == null) return;

    final salvo = Usuario.fromMap(jsonDecode(dados));
    if (salvo.token == null || salvo.token!.isEmpty) {
      await prefs.remove('usuario');
      return;
    }

    _usuario = salvo;
    Sessao.token = salvo.token;
    notifyListeners();
  }

  Future<void> alterarSenha(String senhaAtual, String novaSenha) async {
    await UsuarioService.alterarSenha(
      usuarioId: _usuario!.idUsuario,
      senhaAtual: senhaAtual,
      novaSenha: novaSenha,
    );
  }

  Future<void> atualizarPerfil() async {
    final atual = usuario;
    if (atual == null) return;

    try {
      final recebido = await UsuarioService.eu();
      recebido.token = atual.token;
      _usuario = recebido;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario', jsonEncode(recebido.toMap()));
    } catch (_) {
      return;
    }
  }

  Future<void> logout() async {
    Sessao.token = null;
    _usuario = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
  }

  Future<void> _sessaoExpirou() async {
    await logout();
    AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }
}
