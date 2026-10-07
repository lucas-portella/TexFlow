import 'package:flutter/material.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/item_grade.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/services/empresa_service.dart';
import 'package:texflow/services/operacao_service.dart';

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
  DateTime? dataEntrega;

  void updateDataEntrega(DateTime data) {
    dataEntrega = data;
    notifyListeners();
  }

  List<ProcessoProdutivo> processos = [
    ProcessoProdutivo(descricao: 'Corte'),
    ProcessoProdutivo(descricao: 'Costura'),
  ];

  void updateDescricaoProcessoProdutivo(
    ProcessoProdutivo processo,
    String descricao,
  ) {
    processo.descricao = descricao;
  }

  void criarProcessoProdutivo() {
    processos.add(ProcessoProdutivo(descricao: 'Processo'));
    notifyListeners();
  }

  void deletarProcessoProdutivo(ProcessoProdutivo processo) {
    processos.removeAt(processos.indexOf(processo));
    notifyListeners();
  }

  void updateEmpresaProcessoProdutivo(
    ProcessoProdutivo processo,
    Empresa empresa,
  ) {
    processo.empresaResponsavel = empresa;
    notifyListeners();
  }

  void decrementarQuantidadeItemGrade(ItemGrade item) {
    item.decrementar();
    notifyListeners();
  }

  void incrementarQuantidadeItemGrade(ItemGrade item) {
    item.incrementar();
    notifyListeners();
  }

  Future<List<Empresa>> listarEmpresas() {
    return EmpresaService.listar();
  }

  void criarPedido() {
    try {
      OperacaoService.criar(
        clienteId: cliente!.id,
        dataEntrega: dataEntrega!.toIso8601String(),
        gradePedido: gradePedido
            .map(
              (item) => {
                'descricao': item.descricao,
                'quantidade': item.quantidade,
              },
            )
            .toList(),
        processos: processos
            .map(
              (processo) => {
                'descricao': processo.descricao,
                'empresaResponsavelId': processo.empresaResponsavel?.id,
              },
            )
            .toList(),
      );
    } catch (e) {
      print('Erro ao criar pedido: $e');
    }
  }

  void setCliente(Empresa empresa) {
    cliente = empresa;
    notifyListeners();
  }
}
