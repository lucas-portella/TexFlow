import 'package:flutter/material.dart';
import 'package:texflow/models/modo_operacao.dart';
import 'package:texflow/services/minha_empresa_service.dart';

class PreferenciasProvider extends ChangeNotifier {
  ModoOperacao _modoOperacao = ModoOperacao.porStatus;

  ModoOperacao get modoOperacao => _modoOperacao;

  Future<void> carregar() async {
    try {
      final empresa = await MinhaEmpresaService.buscar();
      _modoOperacao = empresa.modoOperacao;
      notifyListeners();
    } catch (_) {
      return;
    }
  }

  Future<void> alterarModoOperacao(ModoOperacao modo) async {
    final empresa = await MinhaEmpresaService.alterarModoOperacao(modo);
    _modoOperacao = empresa.modoOperacao;
    notifyListeners();
  }
}
