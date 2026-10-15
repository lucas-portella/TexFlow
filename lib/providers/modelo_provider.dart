import 'package:flutter/material.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/services/referencia_service.dart';

class ModeloProvider extends ChangeNotifier {
  List<Referencia> _modelos = [];
  bool _carregando = false;
  String? _erro;

  List<Referencia> get modelos => _modelos;

  List<Referencia> get ativos =>
      modelos.where((modelo) => modelo.ativo).toList();

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _modelos = await ReferenciaService.listar();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> salvar({
    int? id,
    required String nome,
    required List<int> etapaIds,
    bool ativo = true,
  }) async {
    await ReferenciaService.salvar(
      id: id,
      nome: nome,
      etapaIds: etapaIds,
      ativo: ativo,
    );
    await carregar();
  }

  Future<void> excluir(int id) async {
    await ReferenciaService.excluir(id);
    await carregar();
  }
}
