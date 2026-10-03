import 'package:flutter/material.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/services/operacao_service.dart';

class OperacaoProvider extends ChangeNotifier {
  List<Operacao> _operacoes = [];
  bool _carregando = false;
  String? _erro;

  List<Operacao> get operacoes => _operacoes;

  bool get carregando => _carregando;

  String? get erro => _erro;

  int quantidadePorStatus(Status status) {
    return _operacoes.where((operacao) => operacao.status == status).length;
  }

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _operacoes = await OperacaoService.listar();
      _operacoes.sort((a, b) => b.id.compareTo(a.id));
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }
}
