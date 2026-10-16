import 'package:flutter/material.dart';
import 'package:texflow/models/custo.dart';
import 'package:texflow/services/custo_service.dart';

class CustoProvider extends ChangeNotifier {
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  List<Custo> _custos = [];
  bool _carregando = false;
  String? _erro;

  DateTime get mes => _mes;

  List<Custo> get custos => _custos;

  bool get carregando => _carregando;

  String? get erro => _erro;

  String get mesTexto =>
      '${_mes.year}-${_mes.month.toString().padLeft(2, '0')}';

  double get totalDoMes =>
      custos.fold(0, (soma, custo) => soma + custo.totalNoMes);

  List<Custo> get doMes =>
      custos.where((custo) => custo.ocorrenciasNoMes > 0).toList();

  List<Custo> get foraDoMes =>
      custos.where((custo) => custo.ocorrenciasNoMes == 0).toList();

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _custos = await CustoService.listar(mesTexto);
    } catch (e) {
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

  Future<void> salvar({
    int? id,
    required String descricao,
    required CategoriaCusto categoria,
    required double valor,
    required String data,
    int? intervaloDias,
    String? dataFim,
  }) async {
    await CustoService.salvar(
      id: id,
      descricao: descricao,
      categoria: categoria,
      valor: valor,
      data: data,
      intervaloDias: intervaloDias,
      dataFim: dataFim,
    );
    await carregar();
  }

  Future<void> excluir(int id) async {
    await CustoService.excluir(id);
    await carregar();
  }
}
