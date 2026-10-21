import 'package:flutter/material.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/item_grade.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/services/empresa_service.dart';
import 'package:texflow/services/etapa_service.dart';
import 'package:texflow/shared/adicionar_etapa_sheet.dart';
import 'package:texflow/services/operacao_service.dart';

class NewOperationPageProvider extends ChangeNotifier {
  final Future<List<Etapa>> Function() _listarEtapas;
  final Future<Etapa> Function(String nome, double valor, bool permiteCores)
  _cadastrarEtapa;

  NewOperationPageProvider({
    Future<List<Etapa>> Function()? listarEtapas,
    Future<Etapa> Function(String nome, double valor, bool permiteCores)?
    cadastrarEtapa,
  }) : _listarEtapas = listarEtapas ?? EtapaService.listar,
       _cadastrarEtapa =
           cadastrarEtapa ??
           ((nome, valor, permiteCores) => EtapaService.salvar(
             nome: nome,
             valorComissao: valor,
             permiteCores: permiteCores,
           ));

  String numero = '';
  Empresa? cliente;
  Referencia? modelo;
  double? valorPeca;
  int? quantidadeSolicitada;
  DateTime? dataEntrega;
  List<ProcessoProdutivo> processos = [];
  final Set<ProcessoProdutivo> _extras = {};
  bool salvando = false;
  Operacao? emEdicao;
  List<ItemGrade> gradePedido = _gradeVazia();

  bool get editando => emEdicao != null;

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
    emEdicao = null;
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

  void carregarParaEdicao(Operacao operacao) {
    emEdicao = operacao;
    numero = operacao.numero ?? '';
    cliente = operacao.cliente;
    modelo = operacao.referencia;
    valorPeca = operacao.valorPeca;
    quantidadeSolicitada = operacao.quantidadeSolicitada;
    dataEntrega = operacao.dataEntrega == null
        ? null
        : DateTime.tryParse(operacao.dataEntrega!);
    processos = operacao.processos.map(_copiar).toList();
    _extras.clear();
    gradePedido = operacao.gradePedido.isEmpty
        ? _gradeVazia()
        : operacao.gradePedido
              .map(
                (item) => ItemGrade(
                  descricao: item.descricao,
                  quantidade: item.quantidade,
                ),
              )
              .toList();
    notifyListeners();
  }

  static ProcessoProdutivo _copiar(ProcessoProdutivo original) {
    return ProcessoProdutivo(
      idProcessoProdutivo: original.idProcessoProdutivo,
      descricao: original.descricao,
      empresaResponsavel: original.empresaResponsavel,
      funcionario: original.funcionario,
      funcionariosAdicionais: List.of(original.funcionariosAdicionais),
      quantidades: Map.of(original.quantidades),
      permiteCores: original.permiteCores,
      linhas: [for (final linha in original.linhas) linha.copia()],
      valorComissao: original.valorComissao,
      status: original.status,
      dataInicio: original.dataInicio,
      dataFim: original.dataFim,
    );
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
            permiteCores: etapa.permiteCores,
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
      final etapa =
          existente ??
          await _cadastrarEtapa(descricao, dados.valor, dados.permiteCores);
      descricao = etapa.nome;
    }

    final adicionada = ProcessoProdutivo(
      descricao: descricao,
      valorComissao: dados.valor,
      permiteCores: dados.permiteCores,
      status: Status.naoIniciado,
    );
    if (dados.permiteCores) {
      adicionada.linhas = [for (final linha in dados.linhas) linha.copia()];
      adicionada.reagruparResponsaveis();
    } else {
      adicionada.definirResponsaveis(dados.funcionarios);
    }
    _extras.add(adicionada);
    processos = [...processos, adicionada];
    notifyListeners();
  }

  bool ehEtapaExtra(ProcessoProdutivo processo) => _extras.contains(processo);

  bool podeRemoverEtapa(ProcessoProdutivo processo) {
    if (_extras.contains(processo)) return true;
    return editando &&
        (processo.status ?? Status.naoIniciado) == Status.naoIniciado;
  }

  void removerEtapaExtra(ProcessoProdutivo processo) {
    if (!podeRemoverEtapa(processo)) return;
    _extras.remove(processo);
    processos = processos.where((item) => item != processo).toList();
    notifyListeners();
  }

  void setResponsaveis(
    ProcessoProdutivo processo,
    List<Funcionario> funcionarios,
  ) {
    processo.definirResponsaveis(funcionarios);
    notifyListeners();
  }

  void atualizouEtapa() => notifyListeners();

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
    if (!editando && numero.trim().isEmpty) {
      return 'Informe o número do pedido';
    }
    if (cliente == null) return 'Selecione o cliente';
    if (modelo == null) return 'Selecione o modelo';
    if (valorPeca == null || valorPeca! <= 0) {
      return 'Informe o valor da peça';
    }
    if (quantidadeSolicitada == null || quantidadeSolicitada! <= 0) {
      return 'Informe a quantidade solicitada';
    }
    return null;
  }

  String? get _dataParaEnvio {
    final data = dataEntrega;
    if (data == null) return null;
    return '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> get _gradeParaEnvio => gradePedido
      .map(
        (item) => {'descricao': item.descricao, 'quantidade': item.quantidade},
      )
      .toList();

  List<Map<String, dynamic>> _processosParaEnvio({bool comId = false}) {
    return processos
        .map(
          (processo) => {
            if (comId && processo.idProcessoProdutivo != null)
              'id': processo.idProcessoProdutivo,
            'descricao': processo.descricao,
            'status': (processo.status ?? Status.naoIniciado).name,
            'valorComissao': processo.valorComissao,
            if (processo.funcionario != null)
              'funcionario': {'id': processo.funcionario!.id},
            'funcionariosAdicionais': [
              for (final item in processo.funcionariosAdicionais)
                {'id': item.id},
            ],
            'permiteCores': processo.permiteCores,
            if (processo.permiteCores)
              'linhas': [for (final linha in processo.linhas) linha.toMap()],
          },
        )
        .toList();
  }

  Future<void> criarPedido() async {
    final erro = validar();
    if (erro != null) throw Exception(erro);

    salvando = true;
    notifyListeners();

    try {
      await OperacaoService.criar(
        clienteId: cliente!.id,
        referenciaId: modelo!.id,
        numero: numero.trim(),
        dataEntrega: _dataParaEnvio,
        valorPeca: valorPeca!,
        quantidadeSolicitada: quantidadeSolicitada!,
        gradePedido: _gradeParaEnvio,
        processos: _processosParaEnvio(),
      );
      limpar();
    } finally {
      salvando = false;
      notifyListeners();
    }
  }

  Future<Operacao> salvarEdicao() async {
    final pedido = emEdicao;
    if (pedido == null) throw Exception('Nenhum pedido em edição');

    final erro = validar();
    if (erro != null) throw Exception(erro);

    salvando = true;
    notifyListeners();

    try {
      final salvo = await OperacaoService.atualizar(
        id: pedido.id,
        clienteId: cliente!.id,
        referenciaId: modelo!.id,
        numero: (pedido.numero ?? '').isEmpty && numero.trim().isNotEmpty
            ? numero.trim()
            : null,
        dataEntrega: _dataParaEnvio,
        valorPeca: valorPeca!,
        quantidadeSolicitada: quantidadeSolicitada!,
        gradePedido: _gradeParaEnvio,
        processos: _processosParaEnvio(comId: true),
      );
      limpar();
      return salvo;
    } finally {
      salvando = false;
      notifyListeners();
    }
  }
}
