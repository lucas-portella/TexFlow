class Funcionario {
  int id;
  String nome;
  bool ativo;

  Funcionario({this.id = 0, required this.nome, this.ativo = true});

  factory Funcionario.fromMap(Map<String, dynamic> map) {
    return Funcionario(
      id: map['id'] ?? 0,
      nome: map['nome'] ?? '',
      ativo: map['ativo'] ?? true,
    );
  }
}
