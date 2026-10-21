import 'package:flutter/material.dart';
import 'package:texflow/models/cor.dart';
import 'package:texflow/services/cor_service.dart';

class CorProvider extends ChangeNotifier {
  List<Cor> _cores = [];
  bool _carregando = false;
  String? _erro;

  List<Cor> get cores => _cores;

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _cores = await CorService.listar();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> salvar({
    int? id,
    required String nome,
    required String hex,
  }) async {
    await CorService.salvar(id: id, nome: nome, hex: hex);
    await carregar();
  }

  Future<void> excluir(int id) async {
    await CorService.excluir(id);
    await carregar();
  }
}
