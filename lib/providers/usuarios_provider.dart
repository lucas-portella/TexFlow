import 'package:flutter/material.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/services/usuario_service.dart';

class UsuariosProvider extends ChangeNotifier {
  List<Usuario> _usuarios = [];
  bool _carregando = false;
  String? _erro;

  List<Usuario> get usuarios => _usuarios;

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _usuarios = await UsuarioService.listar();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> criar({
    required String nome,
    required String email,
    required String senha,
    required UserType tipo,
    String? cargo,
    required Set<Modulo> modulos,
  }) async {
    await UsuarioService.criar(
      nome: nome,
      email: email,
      senha: senha,
      tipo: tipo,
      cargo: cargo,
      modulos: modulos,
    );
    await carregar();
  }

  Future<void> atualizar(
    Usuario usuario, {
    required String nome,
    required String email,
    String? cargo,
    UserType? tipo,
    Set<Modulo>? modulos,
  }) async {
    await UsuarioService.atualizar(
      id: usuario.idUsuario,
      nome: nome,
      email: email,
      cargo: cargo,
      tipo: tipo,
    );
    if (modulos != null) {
      await UsuarioService.alterarModulos(usuario.idUsuario, modulos);
    }
    await carregar();
  }
}
