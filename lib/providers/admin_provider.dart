import 'package:flutter/material.dart';
import 'package:texflow/models/empresa_cliente.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  String? _token;
  List<EmpresaCliente> _empresas = [];
  bool _carregando = false;
  String? _erro;

  bool get autenticado => _token != null;

  List<EmpresaCliente> get empresas => _empresas;

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> entrar(String usuario, String codigo) async {
    _token = await AdminService.entrar(usuario, codigo);
    _empresas = [];
    _erro = null;
    notifyListeners();
  }

  Future<void> carregar() async {
    final token = _token;
    if (token == null) return;

    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _empresas = await AdminService.listar(token);
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> criar({
    required String nomeFantasia,
    String? cnpj,
    required String usuarioNome,
    required String usuarioEmail,
    required String usuarioSenha,
  }) async {
    await AdminService.criar(
      _token!,
      nomeFantasia: nomeFantasia,
      cnpj: cnpj,
      usuarioNome: usuarioNome,
      usuarioEmail: usuarioEmail,
      usuarioSenha: usuarioSenha,
    );
    await carregar();
  }

  Future<void> alterarAtiva(EmpresaCliente empresa, bool ativa) async {
    await AdminService.alterarAtiva(_token!, empresa.id, ativa);
    await carregar();
  }

  Future<void> alterarModulos(
    EmpresaCliente empresa,
    Set<Modulo> modulos,
  ) async {
    await AdminService.alterarModulos(_token!, empresa.id, modulos);
    await carregar();
  }

  Future<void> redefinirSenhaDoDono(EmpresaCliente empresa, String senha) {
    return AdminService.redefinirSenhaDoDono(_token!, empresa.id, senha);
  }

  void sair() {
    _token = null;
    _empresas = [];
    _erro = null;
    notifyListeners();
  }
}
