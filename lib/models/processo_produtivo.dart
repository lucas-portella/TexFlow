import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/models/usuario.dart';

class ProcessoProdutivo {
  int? idProcessoProdutivo;
  String descricao;
  Empresa? empresaResponsavel; // Empresa responsável pelo serviço
  Funcionario? funcionario; // Funcionário responsável pela etapa
  List<Funcionario> funcionariosAdicionais; // Demais funcionários da mesma etapa
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
    this.valorComissao,
    this.alteradoPor,
    this.dataFim,
    this.dataInicio,
    this.idProcessoProdutivo,
    this.status,
  }) : funcionariosAdicionais = funcionariosAdicionais ?? [];

  List<Funcionario> get funcionarios => [
    ?funcionario,
    ...funcionariosAdicionais,
  ];

  String get nomesDosResponsaveis =>
      funcionarios.map((item) => item.nome).join(', ');

  void definirResponsaveis(List<Funcionario> escolhidos) {
    funcionario = escolhidos.isEmpty ? null : escolhidos.first;
    funcionariosAdicionais = escolhidos.length > 1
        ? escolhidos.sublist(1)
        : <Funcionario>[];
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
      'valorComissao': valorComissao,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'status': status?.name,
      'alteradoPor': alteradoPor?.toMap(),
    };
  }
}
