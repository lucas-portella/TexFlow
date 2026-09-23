enum UserType { operador, gestor }

class Usuario {
  int idUsuario;
  String nome;
  String email;
  String senha;
  UserType tipo;

  Usuario({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipo,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['idUsuario'] ?? 0,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
      tipo: UserType.values.byName(map['tipo']),
    );
  }

  UserType get tipoUsuario => tipo;

  String get nomeUsuario => nome;

  void alterarSenha(String novaSenha) {
    senha = novaSenha;
  }

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'nome': nome,
      'email': email,
      'senha': senha,
      'tipo': tipo.name,
    };
  }
}
