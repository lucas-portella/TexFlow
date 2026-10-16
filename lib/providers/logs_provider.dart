import 'package:flutter/material.dart';
import 'package:texflow/models/registro_log.dart';
import 'package:texflow/services/logs_service.dart';

class LogsProvider extends ChangeNotifier {
  DateTime _primeiroDia = _hoje();
  DateTime _ultimoDia = _hoje();
  TipoLog? _tipo;
  List<RegistroLog> _logs = [];
  bool _carregando = false;
  String? _erro;

  static DateTime _hoje() {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  DateTime get primeiroDia => _primeiroDia;

  DateTime get ultimoDia => _ultimoDia;

  TipoLog? get tipo => _tipo;

  List<RegistroLog> get logs => _logs;

  bool get carregando => _carregando;

  String? get erro => _erro;

  bool get periodoEhHoje => _primeiroDia == _hoje() && _ultimoDia == _hoje();

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _logs = await LogsService.listar(
        inicio: _primeiroDia,
        fim: DateTime(_ultimoDia.year, _ultimoDia.month, _ultimoDia.day + 1),
        tipo: _tipo,
      );
    } catch (e) {
      _logs = [];
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> filtrarTipo(TipoLog? tipo) async {
    _tipo = tipo;
    await carregar();
  }

  Future<void> filtrarPeriodo(DateTime primeiro, DateTime ultimo) async {
    _primeiroDia = DateTime(primeiro.year, primeiro.month, primeiro.day);
    _ultimoDia = DateTime(ultimo.year, ultimo.month, ultimo.day);
    await carregar();
  }

  Future<void> voltarParaHoje() {
    return filtrarPeriodo(_hoje(), _hoje());
  }
}
