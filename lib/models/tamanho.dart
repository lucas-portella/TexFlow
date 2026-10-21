class Tamanho {
  int id;
  String nome;

  Tamanho({this.id = 0, required this.nome});

  factory Tamanho.fromMap(Map<String, dynamic> map) {
    return Tamanho(id: map['id'] ?? 0, nome: map['nome'] ?? '');
  }
}
