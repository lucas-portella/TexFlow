class Funcionario {
  int id;
  String nome;
  String? cargo;
  bool ativo;

  Funcionario({this.id = 0, required this.nome, this.cargo, this.ativo = true});

  factory Funcionario.fromMap(Map<String, dynamic> map) {
    return Funcionario(
      id: map['id'] ?? 0,
      nome: map['nome'] ?? '',
      cargo: map['cargo'],
      ativo: map['ativo'] ?? true,
    );
  }
}
