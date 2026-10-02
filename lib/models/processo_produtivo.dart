import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/models/usuario.dart';

class ProcessoProdutivo {
  int? idProcessoProdutivo;
  String descricao;
  Empresa? empresaResponsavel; // Empresa responsável pelo serviço
  DateTime? dataInicio; // Data de início da operação
  DateTime? dataFim; // Data de fim da operação
  Status?
  status; // Status da operação (não iniciado, em andamento, cancelado, concluído)
  Usuario? alteradoPor;

  ProcessoProdutivo({
    required this.descricao,
    this.empresaResponsavel,
    this.alteradoPor,
    this.dataFim,
    this.dataInicio,
    this.idProcessoProdutivo,
    this.status,
  });

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
      idProcessoProdutivo: map['idProcessoProdutivo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProcessoProdutivo': idProcessoProdutivo,
      'descricao': descricao,
      'empresaResponsavel': empresaResponsavel?.toMap(),
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'status': status?.name,
      'alteradoPor': alteradoPor?.toMap(),
    };
  }
}
