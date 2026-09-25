class Referencia {
  int id;
  String nome;

  Referencia({required this.id, required this.nome});

  factory Referencia.fromMap(Map<String, dynamic> map) {
    return Referencia(id: map['id'] ?? 0, nome: map['nome'] ?? '');
  }
}
