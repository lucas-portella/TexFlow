import 'package:texflow/models/etapa.dart';

class Referencia {
  int id;
  String nome;
  bool ativo;
  List<Etapa> etapas;

  Referencia({
    this.id = 0,
    required this.nome,
    this.ativo = true,
    this.etapas = const [],
  });

  factory Referencia.fromMap(Map<String, dynamic> map) {
    return Referencia(
      id: map['id'] ?? 0,
      nome: map['nome'] ?? '',
      ativo: map['ativo'] ?? true,
      etapas: (map['etapas'] as List<dynamic>? ?? [])
          .map((item) => Etapa.fromMap(item))
          .toList(),
    );
  }
}
