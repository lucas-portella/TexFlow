import 'package:flutter/material.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/services/empresa_service.dart';

class ClienteProvider extends ChangeNotifier {
  List<Empresa> _clientes = [];
  bool _carregando = false;
  String? _erro;

  List<Empresa> get clientes => _clientes;

  bool get carregando => _carregando;

  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _clientes = await EmpresaService.listar();
      _clientes.sort(
        (a, b) => a.nomeFantasia.toLowerCase().compareTo(
          b.nomeFantasia.toLowerCase(),
        ),
      );
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
    }

    _carregando = false;
    notifyListeners();
  }
}
