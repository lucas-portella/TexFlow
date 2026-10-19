class Empresa {
  int id;
  String cnpj;
  String nomeFantasia;
  String contatoNome;
  String contatoTelefone;

  Empresa({
    required this.id,
    required this.cnpj,
    required this.nomeFantasia,
    this.contatoNome = '',
    this.contatoTelefone = '',
  });

  factory Empresa.fromMap(Map<String, dynamic> map) {
    final contato = map['contato'] as Map<String, dynamic>?;

    return Empresa(
      id: map['id'] ?? 0,
      cnpj: map['cnpj'] ?? '',
      nomeFantasia: map['nomeFantasia'] ?? '',
      contatoNome: contato?['nome'] ?? '',
      contatoTelefone: contato?['telefone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'cnpj': cnpj, 'nomeFantasia': nomeFantasia};
  }
}
