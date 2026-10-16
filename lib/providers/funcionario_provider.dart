import 'package:flutter/material.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/services/funcionario_service.dart';

class FuncionarioProvider extends ChangeNotifier {
  List<Funcionario> _funcionarios = [];
  bool _carregando = false;
  String? _erro;

  List<Funcionario> get funcionarios => _funcionarios;

  List<Funcionario> get ativos =>
      funcionarios.where((funcionario) => funcionario.ativo).toList();

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _funcionarios = await FuncionarioService.listar();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> salvar({
    int? id,
    required String nome,
    required bool ativo,
    String? cargo,
  }) async {
    await FuncionarioService.salvar(
      id: id,
      nome: nome,
      cargo: cargo,
      ativo: ativo,
    );
    await carregar();
  }

  Future<void> excluir(int id) async {
    await FuncionarioService.excluir(id);
    await carregar();
  }
}
