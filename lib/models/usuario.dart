import 'package:texflow/models/modulo.dart';

enum UserType { OPERADOR, GESTOR }

class Usuario {
  int idUsuario;
  String nome;
  String email;
  String senha;
  UserType tipo;
  String? cargo;
  String? token;
  int? empresaId;
  bool donoDaEmpresa;
  Set<Modulo> modulos;

  Usuario({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipo,
    this.cargo,
    this.token,
    this.empresaId,
    this.donoDaEmpresa = false,
    this.modulos = const {},
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['idUsuario'] ?? 0,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
      tipo: UserType.values.byName(map['tipo']),
      cargo: map['cargo'],
      token: map['token'],
      empresaId: map['empresaId'],
      donoDaEmpresa: map['donoDaEmpresa'] ?? false,
      modulos: Modulo.lerLista(map['modulos']),
    );
  }

  UserType get tipoUsuario => tipo;

  String get nomeUsuario => nome;

  bool get ehAdm => tipo == UserType.GESTOR;

  bool temModulo(Modulo modulo) => modulos.contains(modulo);

  bool get temAlgumItemDoMenu => Modulo.doMenu.any(temModulo);

  String? get cargoInformado {
    final texto = cargo?.trim();
    return texto == null || texto.isEmpty ? null : texto;
  }

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
      'cargo': cargo,
      'token': token,
      'empresaId': empresaId,
      'donoDaEmpresa': donoDaEmpresa,
      'modulos': Modulo.paraJson(modulos),
    };
  }
}
