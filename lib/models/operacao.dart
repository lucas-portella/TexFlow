import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/item_grade.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/models/status.dart';

class Operacao {
  int id;
  String? numero;
  Referencia? referencia;
  Empresa? cliente;
  String? dataEntrega;
  double? valorPeca;
  int? quantidadeSolicitada;
  int? quantidadeProduzida;
  String? dataFinalizacao;
  List<ItemGrade> gradePedido;
  List<ItemGrade> gradeFabricada;
  List<ProcessoProdutivo> processos;
  Status status;

  Operacao({
    required this.id,
    this.numero,
    this.referencia,
    this.cliente,
    this.dataEntrega,
    this.valorPeca,
    this.quantidadeSolicitada,
    this.quantidadeProduzida,
    this.dataFinalizacao,
    required this.gradePedido,
    required this.gradeFabricada,
    this.processos = const [],
    required this.status,
  });

  factory Operacao.fromMap(Map<String, dynamic> map) {
    return Operacao(
      id: map['id'] ?? 0,
      numero: map['numero'],
      referencia: map['referencia'] != null
          ? Referencia.fromMap(map['referencia'])
          : null,
      cliente: map['cliente'] != null ? Empresa.fromMap(map['cliente']) : null,
      dataEntrega: map['dataEntrega'],
      valorPeca: (map['valorPeca'] as num?)?.toDouble(),
      quantidadeSolicitada: map['quantidadeSolicitada'],
      quantidadeProduzida: map['quantidadeProduzida'],
      dataFinalizacao: map['dataFinalizacao'],
      gradePedido: (map['gradePedido'] as List<dynamic>? ?? [])
          .map((item) => ItemGrade.fromMap(item))
          .toList(),
      gradeFabricada: (map['gradeFabricada'] as List<dynamic>? ?? [])
          .map((item) => ItemGrade.fromMap(item))
          .toList(),
      processos: (map['processos'] as List<dynamic>? ?? [])
          .map((item) => ProcessoProdutivo.fromMap(item))
          .toList(),
      status: Status.values.byName(map['status'] ?? 'naoIniciado'),
    );
  }

  String get codigo =>
      'OP-${numero != null && numero!.isNotEmpty ? numero : id}';

  int get pecas => quantidadeProduzida ?? quantidadeSolicitada ?? totalPedido;

  bool get finalizada => dataFinalizacao != null;

  bool get todasEtapasConcluidas => processos.every(
    (processo) =>
        processo.status == Status.concluido ||
        processo.status == Status.cancelado,
  );

  int get totalPedido =>
      gradePedido.fold(0, (soma, item) => soma + item.quantidade);

  int get totalFabricado =>
      gradeFabricada.fold(0, (soma, item) => soma + item.quantidade);

  int get processosConcluidos =>
      processos.where((processo) => processo.status == Status.concluido).length;

  double? get progresso {
    if (totalPedido > 0) return totalFabricado / totalPedido;
    if (processos.isEmpty) return null;
    return processosConcluidos / processos.length;
  }
}
