import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/services/auth_service.dart';

class UsuarioProvider extends ChangeNotifier {
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  bool get logado => _usuario != null;

  Future<void> login(String email, String senha) async {
    final usuario = await AuthService.login(email, senha);
    _usuario = usuario;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', jsonEncode(usuario.toMap()));
  }

  Future<void> carregarUsuarioSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('usuario');

    if (dados != null) {
      _usuario = Usuario.fromMap(jsonDecode(dados));
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _usuario = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
  }
}
