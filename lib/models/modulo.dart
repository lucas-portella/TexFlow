import 'package:flutter/material.dart';
import 'package:texflow/routes/app_routes.dart';

enum Modulo {
  modelos(
    'MODELOS',
    'Modelos',
    'Cadastrar e editar os modelos de peças',
    Icons.checkroom_outlined,
    AppRoutes.modelos,
  ),
  etapas(
    'ETAPAS',
    'Etapas',
    'Cadastrar e editar as etapas e as comissões',
    Icons.account_tree_outlined,
    AppRoutes.etapas,
  ),
  funcionarios(
    'FUNCIONARIOS',
    'Funcionários',
    'Cadastrar e editar os funcionários',
    Icons.groups_outlined,
    AppRoutes.funcionarios,
  ),
  clientes(
    'CLIENTES',
    'Clientes',
    'Cadastrar e editar os clientes',
    Icons.business_outlined,
    AppRoutes.clientes,
  ),
  custos(
    'CUSTOS',
    'Custos',
    'Lançar custos fixos e avulsos da empresa',
    Icons.receipt_long_outlined,
    AppRoutes.custos,
  ),
  logs(
    'LOGS',
    'Logs',
    'Ver o histórico de tudo que foi feito no sistema',
    Icons.history,
    AppRoutes.logs,
  ),
  relatorios(
    'RELATORIOS',
    'Relatórios',
    'Ver relatórios por funcionário e da empresa',
    Icons.insights_outlined,
    AppRoutes.relatorios,
  ),
  fechamento(
    'FECHAMENTO',
    'Fechamento',
    'Ver o fechamento do mês, repasses e lucro',
    Icons.payments_outlined,
    AppRoutes.fechamento,
  ),
  modoOperacao(
    'MODO_OPERACAO',
    'Modo de operação',
    'Escolher como as produções avançam: por status ou por etapas',
    Icons.tune,
    AppRoutes.modoOperacao,
  ),
  usuarios(
    'USUARIOS',
    'Usuários',
    'Cadastrar usuários e definir o que cada um acessa',
    Icons.manage_accounts_outlined,
    AppRoutes.usuarios,
  );

  final String json;
  final String rotulo;
  final String descricao;
  final IconData icone;
  final String rota;

  const Modulo(this.json, this.rotulo, this.descricao, this.icone, this.rota);

  static const opcionaisNoPacote = {
    Modulo.custos,
    Modulo.fechamento,
    Modulo.logs,
    Modulo.relatorios,
  };

  static const doMenu = [
    Modulo.modelos,
    Modulo.etapas,
    Modulo.funcionarios,
    Modulo.clientes,
    Modulo.custos,
    Modulo.fechamento,
    Modulo.logs,
    Modulo.relatorios,
  ];

  static Modulo? deJson(String? valor) {
    for (final modulo in Modulo.values) {
      if (modulo.json == valor) return modulo;
    }
    return null;
  }

  static Set<Modulo> lerLista(dynamic lista) {
    if (lista is! List) return {};
    return lista
        .map((item) => deJson(item as String?))
        .whereType<Modulo>()
        .toSet();
  }

  static List<String> paraJson(Iterable<Modulo> modulos) {
    return Modulo.values
        .where(modulos.contains)
        .map((modulo) => modulo.json)
        .toList();
  }
}
