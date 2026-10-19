import 'package:flutter/material.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/status.dart';
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

  Future<void> excluir() async {
    final operacao = _operacao;
    if (operacao == null) return;

    await OperacaoService.excluir(operacao.id);
  }

  Future<void> alterarStatus(Status status) async {
    final operacao = _operacao;
    if (operacao == null) return;

    _operacao = await OperacaoService.alterarStatus(
      operacaoId: operacao.id,
      status: status,
    );
    notifyListeners();
  }

  Future<void> atualizarEtapas(List<int> processoIds, Status status) async {
    final operacao = _operacao;
    if (operacao == null || processoIds.isEmpty) return;

    _operacao = await OperacaoService.atualizarStatusDasEtapas(
      operacaoId: operacao.id,
      processoIds: processoIds,
      status: status,
    );
    notifyListeners();
  }

  Future<void> adicionarEtapa({
    int? etapaId,
    String? nome,
    required double valorComissao,
    required int funcionarioId,
    List<int> outrosFuncionarioIds = const [],
  }) async {
    final operacao = _operacao;
    if (operacao == null) return;

    _operacao = await OperacaoService.adicionarEtapa(
      operacaoId: operacao.id,
      etapaId: etapaId,
      nome: nome,
      valorComissao: valorComissao,
      funcionarioId: funcionarioId,
      outrosFuncionarioIds: outrosFuncionarioIds,
    );
    notifyListeners();
  }

  Future<void> finalizar(int quantidadeProduzida, DateTime dataEntrega) async {
    final operacao = _operacao;
    if (operacao == null) return;

    _operacao = await OperacaoService.finalizar(
      operacaoId: operacao.id,
      quantidadeProduzida: quantidadeProduzida,
      dataEntrega: dataEntrega,
    );
    notifyListeners();
  }

  Future<void> recarregar() async {
    if (_id == null) return;
    await carregar(_id!);
  }
}
