import 'package:flutter/material.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/services/operacao_service.dart';

class OperacaoDetalheProvider extends ChangeNotifier {
  Operacao? _operacao;
  bool _carregando = false;
  String? _erro;
  int? _id;
  bool _descartado = false;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  Operacao? get operacao => _operacao;

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar(int id) async {
    _id = id;
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _operacao = await OperacaoService.buscarPorId(id);
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> recarregar() async {
    if (_id == null) return;
    await carregar(_id!);
  }
}
