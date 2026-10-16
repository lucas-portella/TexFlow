import 'package:flutter/material.dart';
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/services/fechamento_service.dart';

class FechamentoProvider extends ChangeNotifier {
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  Fechamento? _fechamento;
  bool _carregando = false;
  String? _erro;

  DateTime get mes => _mes;

  Fechamento? get fechamento => _fechamento;

  bool get carregando => _carregando;

  String? get erro => _erro;

  String get mesTexto =>
      '${_mes.year}-${_mes.month.toString().padLeft(2, '0')}';

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _fechamento = await FechamentoService.buscar(mesTexto);
    } catch (e) {
      _fechamento = null;
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> mesAnterior() async {
    _mes = DateTime(_mes.year, _mes.month - 1);
    await carregar();
  }

  Future<void> proximoMes() async {
    _mes = DateTime(_mes.year, _mes.month + 1);
    await carregar();
  }
}
