import 'package:flutter/material.dart';
import 'package:texflow/models/tamanho.dart';
import 'package:texflow/services/tamanho_service.dart';

class TamanhoProvider extends ChangeNotifier {
  List<Tamanho> _tamanhos = [];
  bool _carregando = false;
  String? _erro;

  List<Tamanho> get tamanhos => _tamanhos;

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _tamanhos = await TamanhoService.listar();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> salvar({int? id, required String nome}) async {
    await TamanhoService.salvar(id: id, nome: nome);
    await carregar();
  }

  Future<void> excluir(int id) async {
    await TamanhoService.excluir(id);
    await carregar();
  }
}
