class Etapa {
  int id;
  String nome;
  double valorComissao;
  bool permiteCores;

  Etapa({
    this.id = 0,
    required this.nome,
    required this.valorComissao,
    this.permiteCores = false,
  });

  factory Etapa.fromMap(Map<String, dynamic> map) {
    return Etapa(
      id: map['id'] ?? 0,
      nome: map['nome'] ?? '',
      valorComissao: (map['valorComissao'] as num?)?.toDouble() ?? 0,
      permiteCores: map['permiteCores'] ?? false,
    );
  }
}
