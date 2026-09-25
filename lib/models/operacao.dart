import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/item_grade.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/models/status.dart';

class Operacao {
  int id;
  Referencia? referencia;
  Empresa? cliente;
  String? dataEntrega;
  List<ItemGrade> gradePedido;
  List<ItemGrade> gradeFabricada;
  Status status;

  Operacao({
    required this.id,
    this.referencia,
    this.cliente,
    this.dataEntrega,
    required this.gradePedido,
    required this.gradeFabricada,
    required this.status,
  });

  factory Operacao.fromMap(Map<String, dynamic> map) {
    return Operacao(
      id: map['id'] ?? 0,
      referencia: map['referencia'] != null
          ? Referencia.fromMap(map['referencia'])
          : null,
      cliente: map['cliente'] != null ? Empresa.fromMap(map['cliente']) : null,
      dataEntrega: map['dataEntrega'],
      gradePedido: (map['gradePedido'] as List<dynamic>? ?? [])
          .map((item) => ItemGrade.fromMap(item))
          .toList(),
      gradeFabricada: (map['gradeFabricada'] as List<dynamic>? ?? [])
          .map((item) => ItemGrade.fromMap(item))
          .toList(),
      status: Status.values.byName(map['status'] ?? 'naoIniciado'),
    );
  }

  int get totalPedido =>
      gradePedido.fold(0, (soma, item) => soma + item.quantidade);

  int get totalFabricado =>
      gradeFabricada.fold(0, (soma, item) => soma + item.quantidade);

  double? get progresso {
    if (totalPedido == 0) return null;
    return totalFabricado / totalPedido;
  }
}
