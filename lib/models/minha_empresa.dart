import 'package:texflow/models/modo_operacao.dart';

class MinhaEmpresa {
  String nomeFantasia;
  String? razaoSocial;
  String? cnpj;
  String? telefone;
  String? email;
  String? endereco;
  String? cidade;
  ModoOperacao modoOperacao;

  MinhaEmpresa({
    this.nomeFantasia = '',
    this.razaoSocial,
    this.cnpj,
    this.telefone,
    this.email,
    this.endereco,
    this.cidade,
    this.modoOperacao = ModoOperacao.porStatus,
  });

  factory MinhaEmpresa.fromMap(Map<String, dynamic> map) {
    return MinhaEmpresa(
      nomeFantasia: map['nomeFantasia'] ?? '',
      razaoSocial: map['razaoSocial'],
      cnpj: map['cnpj'],
      telefone: map['telefone'],
      email: map['email'],
      endereco: map['endereco'],
      cidade: map['cidade'],
      modoOperacao: ModoOperacao.deJson(map['modoOperacao']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomeFantasia': nomeFantasia,
      'razaoSocial': razaoSocial,
      'cnpj': cnpj,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'cidade': cidade,
    };
  }

  bool get cadastrada => nomeFantasia.isNotEmpty;
}
