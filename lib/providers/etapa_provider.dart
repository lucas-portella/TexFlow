import 'package:flutter/material.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/services/etapa_service.dart';

class EtapaProvider extends ChangeNotifier {
  List<Etapa> _etapas = [];
  bool _carregando = false;
  String? _erro;

  List<Etapa> get etapas => _etapas;

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _etapas = await EtapaService.listar();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> salvar({
    int? id,
    required String nome,
    required double valorComissao,
    bool permiteCores = false,
  }) async {
    await EtapaService.salvar(
      id: id,
      nome: nome,
      valorComissao: valorComissao,
      permiteCores: permiteCores,
    );
    await carregar();
  }

  Future<void> excluir(int id) async {
    await EtapaService.excluir(id);
    await carregar();
  }
}
