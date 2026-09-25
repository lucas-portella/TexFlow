class Empresa {
  int id;
  String cnpj;
  String nomeFantasia;

  Empresa({required this.id, required this.cnpj, required this.nomeFantasia});

  factory Empresa.fromMap(Map<String, dynamic> map) {
    return Empresa(
      id: map['id'] ?? 0,
      cnpj: map['cnpj'] ?? '',
      nomeFantasia: map['nomeFantasia'] ?? '',
    );
  }
}
