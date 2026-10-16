import 'package:flutter/material.dart';
import 'package:texflow/models/relatorio.dart';
import 'package:texflow/services/relatorios_service.dart';

class RelatoriosProvider extends ChangeNotifier {
  DateTime _inicio = _primeiroDiaDoMes();
  DateTime _fim = _hoje();
  RelatorioEmpresa? _empresa;
  RelatorioFuncionarios? _funcionarios;
  bool _carregando = false;
  String? _erro;

  static DateTime _hoje() {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  static DateTime _primeiroDiaDoMes() {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, 1);
  }

  DateTime get inicio => _inicio;

  DateTime get fim => _fim;

  bool get periodoEhPadrao => _inicio == _primeiroDiaDoMes() && _fim == _hoje();

  RelatorioEmpresa? get empresa => _empresa;

  RelatorioFuncionarios? get funcionarios => _funcionarios;

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        RelatoriosService.empresa(_inicio, _fim),
        RelatoriosService.funcionarios(_inicio, _fim),
      ]);
      _empresa = resultados[0] as RelatorioEmpresa;
      _funcionarios = resultados[1] as RelatorioFuncionarios;
    } catch (e) {
      _empresa = null;
      _funcionarios = null;
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> filtrarPeriodo(DateTime inicio, DateTime fim) async {
    _inicio = DateTime(inicio.year, inicio.month, inicio.day);
    _fim = DateTime(fim.year, fim.month, fim.day);
    await carregar();
  }

  Future<void> voltarParaPadrao() {
    return filtrarPeriodo(_primeiroDiaDoMes(), _hoje());
  }
}
