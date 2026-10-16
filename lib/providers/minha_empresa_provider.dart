import 'package:flutter/material.dart';
import 'package:texflow/models/minha_empresa.dart';
import 'package:texflow/services/minha_empresa_service.dart';

class MinhaEmpresaProvider extends ChangeNotifier {
  MinhaEmpresa? _empresa;
  bool _carregando = false;
  String? _erro;

  MinhaEmpresa? get empresa => _empresa;

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _empresa = await MinhaEmpresaService.buscar();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> salvar(MinhaEmpresa empresa) async {
    _empresa = await MinhaEmpresaService.salvar(empresa);
    notifyListeners();
  }
}
