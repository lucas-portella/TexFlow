import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/atalho_rapido.dart';

class AtalhosProvider extends ChangeNotifier {
  static const _chave = 'atalhos_rapidos';

  List<String> _ids = List.of(AtalhoRapido.padrao);

  List<AtalhoRapido> get atalhos => _ids
      .map(AtalhoRapido.porId)
      .whereType<AtalhoRapido>()
      .toList(growable: false);

  List<String> get ids => List.unmodifiable(_ids);

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final salvos = prefs.getStringList(_chave);

    if (salvos != null && salvos.length == AtalhoRapido.padrao.length) {
      final validos = salvos.every((id) => AtalhoRapido.porId(id) != null);
      if (validos) _ids = salvos;
    }

    notifyListeners();
  }

  Future<void> trocar(int posicao, String novoId) async {
    if (posicao < 0 || posicao >= _ids.length) return;
    if (AtalhoRapido.porId(novoId) == null) return;

    final lista = List.of(_ids);
    final posicaoAtual = lista.indexOf(novoId);
    if (posicaoAtual >= 0) lista[posicaoAtual] = lista[posicao];
    lista[posicao] = novoId;

    _ids = lista;
    notifyListeners();
    await _salvar();
  }

  Future<void> restaurarPadrao() async {
    _ids = List.of(AtalhoRapido.padrao);
    notifyListeners();
    await _salvar();
  }

  Future<void> _salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chave, _ids);
  }
}
