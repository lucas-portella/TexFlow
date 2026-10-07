import 'package:flutter/material.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/item_grade.dart';
import 'package:texflow/models/processo_produtivo.dart';

class NewOperationPageProvider extends ChangeNotifier {
  Empresa? cliente;
  Empresa? prestador;
  List<ItemGrade> gradePedido = [
    ItemGrade(descricao: 'PP', quantidade: 0),
    ItemGrade(descricao: 'P', quantidade: 0),
    ItemGrade(descricao: 'M', quantidade: 0),
    ItemGrade(descricao: 'G', quantidade: 0),
    ItemGrade(descricao: 'GG', quantidade: 0),
  ];

  List<ProcessoProdutivo> processos = [
    ProcessoProdutivo(descricao: 'Corte'),
    ProcessoProdutivo(descricao: 'Costura'),
  ];

  void decrementarQuantidadeItemGrade(ItemGrade item) {
    item.decrementar();
    notifyListeners();
  }

  void incrementarQuantidadeItemGrade(ItemGrade item) {
    item.incrementar();
    notifyListeners();
  }

  void criarPedido() {
    // 1 - criar objeto Operacao
    // 2 - subir no bd
    // 3 - retornar um sucesso ou uma excessao
  }

  void setCliente(Empresa empresa) {
    cliente = empresa;
    notifyListeners();
  }
}
