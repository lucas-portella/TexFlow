import 'package:flutter/material.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/item_grade.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/services/empresa_service.dart';
import 'package:texflow/services/etapa_service.dart';
import 'package:texflow/shared/adicionar_etapa_sheet.dart';
import 'package:texflow/services/operacao_service.dart';

class NewOperationPageProvider extends ChangeNotifier {
  final Future<List<Etapa>> Function() _listarEtapas;
  final Future<Etapa> Function(String nome, double valor) _cadastrarEtapa;

  NewOperationPageProvider({
    Future<List<Etapa>> Function()? listarEtapas,
    Future<Etapa> Function(String nome, double valor)? cadastrarEtapa,
  }) : _listarEtapas = listarEtapas ?? EtapaService.listar,
       _cadastrarEtapa =
           cadastrarEtapa ??
           ((nome, valor) =>
               EtapaService.salvar(nome: nome, valorComissao: valor));

  String numero = '';
  Empresa? cliente;
  Referencia? modelo;
  double? valorPeca;
  int? quantidadeSolicitada;
  DateTime? dataEntrega;
  List<ProcessoProdutivo> processos = [];
  final Set<ProcessoProdutivo> _extras = {};
  bool salvando = false;
  List<ItemGrade> gradePedido = _gradeVazia();

  static List<ItemGrade> _gradeVazia() {
    return [
      ItemGrade(descricao: 'PP', quantidade: 0),
      ItemGrade(descricao: 'P', quantidade: 0),
      ItemGrade(descricao: 'M', quantidade: 0),
      ItemGrade(descricao: 'G', quantidade: 0),
      ItemGrade(descricao: 'GG', quantidade: 0),
    ];
  }

  void limpar() {
    numero = '';
    cliente = null;
    modelo = null;
    valorPeca = null;
    quantidadeSolicitada = null;
    dataEntrega = null;
    processos = [];
    _extras.clear();
    gradePedido = _gradeVazia();
    notifyListeners();
  }

  void setNumero(String valor) {
    numero = valor;
  }

  void setCliente(Empresa empresa) {
    cliente = empresa;
    notifyListeners();
  }

  void updateDataEntrega(DateTime data) {
    dataEntrega = data;
    notifyListeners();
  }

  void setValorPeca(double? valor) {
    valorPeca = valor;
  }

  void setQuantidadeSolicitada(int? quantidade) {
    quantidadeSolicitada = quantidade;
  }

  void setModelo(Referencia novoModelo) {
    modelo = novoModelo;
    _extras.clear();
    processos = novoModelo.etapas
        .map(
          (etapa) => ProcessoProdutivo(
            descricao: etapa.nome,
            valorComissao: etapa.valorComissao,
            status: Status.naoIniciado,
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> adicionarEtapaAoPedido(DadosDaEtapaAdicionada dados) async {
    String descricao = dados.descricao.trim();
    final repetida = processos.any(
      (processo) =>
          processo.descricao.trim().toLowerCase() == descricao.toLowerCase(),
    );
    if (repetida) {
      throw Exception('Esse pedido já tem a etapa $descricao');
    }

    if (dados.ehNova) {
      final cadastradas = await _listarEtapas();
      Etapa? existente;
      for (final etapa in cadastradas) {
        if (etapa.nome.trim().toLowerCase() == descricao.toLowerCase()) {
          existente = etapa;
        }
      }
      final etapa = existente ?? await _cadastrarEtapa(descricao, dados.valor);
      descricao = etapa.nome;
    }

    final adicionada = ProcessoProdutivo(
      descricao: descricao,
      valorComissao: dados.valor,
      funcionario: dados.funcionario,
      status: Status.naoIniciado,
    );
    _extras.add(adicionada);
    processos = [...processos, adicionada];
    notifyListeners();
  }

  bool ehEtapaExtra(ProcessoProdutivo processo) => _extras.contains(processo);

  void removerEtapaExtra(ProcessoProdutivo processo) {
    if (!_extras.remove(processo)) return;
    processos = processos.where((item) => item != processo).toList();
    notifyListeners();
  }

  void setResponsavel(ProcessoProdutivo processo, Funcionario funcionario) {
    processo.funcionario = funcionario;
    notifyListeners();
  }

  void alterarValorEtapa(ProcessoProdutivo processo, double valor) {
    processo.valorComissao = valor;
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

  String? validar() {
    if (numero.trim().isEmpty) return 'Informe o número do pedido';
    if (cliente == null) return 'Selecione o cliente';
    if (modelo == null) return 'Selecione o modelo';
    if (valorPeca == null || valorPeca! <= 0) {
      return 'Informe o valor da peça';
    }
    if (quantidadeSolicitada == null || quantidadeSolicitada! <= 0) {
      return 'Informe a quantidade solicitada';
    }
    for (final processo in processos) {
      if (processo.funcionario == null) {
        return 'Escolha o responsável da etapa ${processo.descricao}';
      }
    }
    return null;
  }

  Future<void> criarPedido() async {
    final erro = validar();
    if (erro != null) throw Exception(erro);

    salvando = true;
    notifyListeners();

    try {
      final data = dataEntrega;
      await OperacaoService.criar(
        clienteId: cliente!.id,
        referenciaId: modelo!.id,
        numero: numero.trim(),
        dataEntrega: data == null
            ? null
            : '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}',
        valorPeca: valorPeca!,
        quantidadeSolicitada: quantidadeSolicitada!,
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
                'status': Status.naoIniciado.name,
                'valorComissao': processo.valorComissao,
                'funcionario': {'id': processo.funcionario!.id},
              },
            )
            .toList(),
      );
      limpar();
    } finally {
      salvando = false;
      notifyListeners();
    }
  }
}
