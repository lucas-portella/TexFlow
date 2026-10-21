import 'package:texflow/models/cor.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/linha_da_etapa.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/models/usuario.dart';

class ProcessoProdutivo {
  int? idProcessoProdutivo;
  String descricao;
  Empresa? empresaResponsavel; // Empresa responsável pelo serviço
  Funcionario? funcionario; // Funcionário responsável pela etapa
  List<Funcionario>
  funcionariosAdicionais; // Demais funcionários da mesma etapa
  Map<int, int> quantidades; // Peças de cada responsável nesta etapa
  bool permiteCores; // A etapa é dividida em lotes de cores
  List<LinhaDaEtapa> linhas; // Lotes (responsável, cor, tamanho e peças)
  double? valorComissao; // Comissão por peça paga ao funcionário
  DateTime? dataInicio; // Data de início da operação
  DateTime? dataFim; // Data de fim da operação
  Status?
  status; // Status da operação (não iniciado, em andamento, cancelado, concluído)
  Usuario? alteradoPor;

  ProcessoProdutivo({
    required this.descricao,
    this.empresaResponsavel,
    this.funcionario,
    List<Funcionario>? funcionariosAdicionais,
    Map<int, int>? quantidades,
    this.permiteCores = false,
    List<LinhaDaEtapa>? linhas,
    this.valorComissao,
    this.alteradoPor,
    this.dataFim,
    this.dataInicio,
    this.idProcessoProdutivo,
    this.status,
  }) : funcionariosAdicionais = funcionariosAdicionais ?? [],
       quantidades = quantidades ?? {},
       linhas = linhas ?? [];

  List<Funcionario> get funcionarios => [
    ?funcionario,
    ...funcionariosAdicionais,
  ];

  String get nomesDosResponsaveis =>
      funcionarios.map((item) => item.nome).join(', ');

  String get responsaveisComPecas => funcionarios
      .map(
        (item) => quantidades.containsKey(item.id)
            ? '${item.nome} (${quantidades[item.id]})'
            : item.nome,
      )
      .join(', ');

  List<LinhaDaEtapa> linhasDe(int funcionarioId) =>
      linhas.where((linha) => linha.funcionario.id == funcionarioId).toList();

  List<Cor> coresDe(int funcionarioId) {
    final cores = <Cor>[];
    for (final linha in linhasDe(funcionarioId)) {
      final cor = linha.cor;
      if (cor != null && !cores.any((item) => item.id == cor.id)) {
        cores.add(cor);
      }
    }
    return cores;
  }

  int? pecasDe(int funcionarioId) {
    final doFuncionario = linhasDe(funcionarioId);
    if (doFuncionario.isEmpty) return quantidades[funcionarioId];
    if (!doFuncionario.any((linha) => linha.quantidade != null)) return null;
    return doFuncionario.fold<int>(
      0,
      (soma, linha) => soma + (linha.quantidade ?? 0),
    );
  }

  bool responsavelCompleto(Funcionario pessoa) {
    final doFuncionario = linhasDe(pessoa.id);

    if (permiteCores) {
      return doFuncionario.isNotEmpty &&
          doFuncionario.every((linha) => linha.completa);
    }
    if (doFuncionario.isNotEmpty) {
      return doFuncionario.every((linha) => linha.quantidade != null);
    }
    return quantidades.containsKey(pessoa.id);
  }

  List<Funcionario> get semQuantidade =>
      funcionarios.where((item) => !responsavelCompleto(item)).toList();

  void definirResponsaveis(List<Funcionario> escolhidos) {
    funcionario = escolhidos.isEmpty ? null : escolhidos.first;
    funcionariosAdicionais = escolhidos.length > 1
        ? escolhidos.sublist(1)
        : <Funcionario>[];
    quantidades.removeWhere(
      (id, _) => !escolhidos.any((item) => item.id == id),
    );
    linhas.removeWhere(
      (linha) => !escolhidos.any((item) => item.id == linha.funcionario.id),
    );
  }

  void reagruparResponsaveis() {
    final pessoas = <Funcionario>[];
    for (final linha in linhas) {
      if (!pessoas.any((item) => item.id == linha.funcionario.id)) {
        pessoas.add(linha.funcionario);
      }
    }
    funcionario = pessoas.isEmpty ? null : pessoas.first;
    funcionariosAdicionais = pessoas.length > 1
        ? pessoas.sublist(1)
        : <Funcionario>[];
    quantidades.removeWhere((id, _) => !pessoas.any((item) => item.id == id));
  }

  void adicionarCores(Funcionario pessoa, List<Cor> cores) {
    for (final cor in cores) {
      final jaTem = linhas.any(
        (linha) => linha.funcionario.id == pessoa.id && linha.cor?.id == cor.id,
      );
      if (!jaTem) linhas.add(LinhaDaEtapa(funcionario: pessoa, cor: cor));
    }
    reagruparResponsaveis();
  }

  void definirCores(Funcionario pessoa, List<Cor> cores) {
    linhas.removeWhere(
      (linha) =>
          linha.funcionario.id == pessoa.id &&
          !cores.any((cor) => cor.id == linha.cor?.id),
    );
    adicionarCores(pessoa, cores);
  }

  void removerCor(Funcionario pessoa, Cor cor) {
    linhas.removeWhere(
      (linha) => linha.funcionario.id == pessoa.id && linha.cor?.id == cor.id,
    );
    reagruparResponsaveis();
  }

  void removerResponsavel(Funcionario pessoa) {
    linhas.removeWhere((linha) => linha.funcionario.id == pessoa.id);
    reagruparResponsaveis();
  }

  void setStatus(Status novoStatus, Usuario usuario) {
    status = novoStatus;
    alteradoPor = usuario;
  }

  void setEmpresaResponsavel(Empresa empresa) {
    empresaResponsavel = empresa;
  }

  void setDescricao(String novaDescricao) {
    descricao = novaDescricao;
  }

  void setDataInicio(DateTime novaDataInicio) {
    dataInicio = novaDataInicio;
  }

  void setDataFim(DateTime novaDataFim) {
    dataFim = novaDataFim;
  }

  factory ProcessoProdutivo.fromMap(Map<String, dynamic> map) {
    return ProcessoProdutivo(
      descricao: map['descricao'] ?? '',
      empresaResponsavel: map['empresaResponsavel'] != null
          ? Empresa.fromMap(map['empresaResponsavel'])
          : null,
      funcionario: map['funcionario'] != null
          ? Funcionario.fromMap(map['funcionario'])
          : null,
      funcionariosAdicionais: [
        for (final item in (map['funcionariosAdicionais'] as List? ?? []))
          Funcionario.fromMap(item as Map<String, dynamic>),
      ],
      quantidades: {
        for (final entrada
            in (map['quantidades'] as Map<String, dynamic>? ?? {}).entries)
          int.parse(entrada.key): (entrada.value as num).toInt(),
      },
      permiteCores: map['permiteCores'] ?? false,
      linhas: [
        for (final item in (map['linhas'] as List? ?? []))
          LinhaDaEtapa.fromMap(item as Map<String, dynamic>),
      ],
      valorComissao: (map['valorComissao'] as num?)?.toDouble(),
      alteradoPor: map['alteradoPor'] != null
          ? Usuario.fromMap(map['alteradoPor'])
          : null,
      dataFim: map['dataFim'] != null ? DateTime.parse(map['dataFim']) : null,
      dataInicio: map['dataInicio'] != null
          ? DateTime.parse(map['dataInicio'])
          : null,
      status: map['status'] != null
          ? Status.values.byName(map['status'])
          : null,
      idProcessoProdutivo: map['id'] ?? map['idProcessoProdutivo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProcessoProdutivo': idProcessoProdutivo,
      'descricao': descricao,
      'empresaResponsavel': empresaResponsavel?.toMap(),
      'funcionario': funcionario == null ? null : {'id': funcionario!.id},
      'funcionariosAdicionais': [
        for (final item in funcionariosAdicionais) {'id': item.id},
      ],
      'permiteCores': permiteCores,
      'linhas': [for (final linha in linhas) linha.toMap()],
      'valorComissao': valorComissao,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'status': status?.name,
      'alteradoPor': alteradoPor?.toMap(),
    };
  }
}
