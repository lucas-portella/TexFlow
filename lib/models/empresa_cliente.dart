import 'package:texflow/models/modulo.dart';

class EmpresaCliente {
  final int id;
  final String nomeFantasia;
  final String? cnpj;
  final bool ativa;
  final int totalUsuarios;
  final String? donoNome;
  final String? donoEmail;
  final Set<Modulo> modulos;

  EmpresaCliente({
    required this.id,
    required this.nomeFantasia,
    this.cnpj,
    required this.ativa,
    required this.totalUsuarios,
    this.donoNome,
    this.donoEmail,
    this.modulos = const {},
  });

  factory EmpresaCliente.fromMap(Map<String, dynamic> map) {
    return EmpresaCliente(
      id: map['id'] ?? 0,
      nomeFantasia: map['nomeFantasia'] ?? '',
      cnpj: map['cnpj'],
      ativa: map['ativa'] ?? true,
      totalUsuarios: map['totalUsuarios'] ?? 0,
      donoNome: map['donoNome'],
      donoEmail: map['donoEmail'],
      modulos: Modulo.lerLista(map['modulos']),
    );
  }

  String get descricao {
    final partes = <String>[?donoNome, ?donoEmail, '$totalUsuarios usuário(s)'];
    return partes.join(' · ');
  }
}
