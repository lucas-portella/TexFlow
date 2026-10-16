import 'package:flutter/material.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/routes/app_routes.dart';

class AtalhoRapido {
  final String id;
  final String rotulo;
  final IconData icone;
  final String rota;
  final Modulo? modulo;

  const AtalhoRapido({
    required this.id,
    required this.rotulo,
    required this.icone,
    required this.rota,
    this.modulo,
  });

  bool liberadoPara(Usuario? usuario) {
    if (modulo == null) return true;
    return usuario?.temModulo(modulo!) ?? false;
  }

  static const catalogo = [
    AtalhoRapido(
      id: 'inicio',
      rotulo: 'Início',
      icone: Icons.home_filled,
      rota: AppRoutes.dashboard,
    ),
    AtalhoRapido(
      id: 'pesquisa',
      rotulo: 'Pesquisa',
      icone: Icons.search,
      rota: AppRoutes.pesquisa,
    ),
    AtalhoRapido(
      id: 'clientes',
      rotulo: 'Clientes',
      icone: Icons.business_outlined,
      rota: AppRoutes.clientes,
      modulo: Modulo.clientes,
    ),
    AtalhoRapido(
      id: 'configuracoes',
      rotulo: 'Config.',
      icone: Icons.settings_outlined,
      rota: AppRoutes.configuracoes,
    ),
    AtalhoRapido(
      id: 'modelos',
      rotulo: 'Modelos',
      icone: Icons.checkroom_outlined,
      rota: AppRoutes.modelos,
      modulo: Modulo.modelos,
    ),
    AtalhoRapido(
      id: 'etapas',
      rotulo: 'Etapas',
      icone: Icons.account_tree_outlined,
      rota: AppRoutes.etapas,
      modulo: Modulo.etapas,
    ),
    AtalhoRapido(
      id: 'funcionarios',
      rotulo: 'Funcionários',
      icone: Icons.groups_outlined,
      rota: AppRoutes.funcionarios,
      modulo: Modulo.funcionarios,
    ),
    AtalhoRapido(
      id: 'custos',
      rotulo: 'Custos',
      icone: Icons.receipt_long_outlined,
      rota: AppRoutes.custos,
      modulo: Modulo.custos,
    ),
    AtalhoRapido(
      id: 'relatorios',
      rotulo: 'Relatórios',
      icone: Icons.insights_outlined,
      rota: AppRoutes.relatorios,
      modulo: Modulo.relatorios,
    ),
    AtalhoRapido(
      id: 'fechamento',
      rotulo: 'Fechamento',
      icone: Icons.payments_outlined,
      rota: AppRoutes.fechamento,
      modulo: Modulo.fechamento,
    ),
  ];

  static const padrao = ['inicio', 'pesquisa', 'clientes', 'configuracoes'];

  static AtalhoRapido? porId(String id) {
    for (final atalho in catalogo) {
      if (atalho.id == id) return atalho;
    }
    return null;
  }

  static List<AtalhoRapido> visiveisPara(
    List<AtalhoRapido> escolhidos,
    Usuario? usuario,
  ) {
    final reserva = catalogo
        .where(
          (atalho) =>
              atalho.liberadoPara(usuario) && !escolhidos.contains(atalho),
        )
        .toList();

    return [
      for (final atalho in escolhidos)
        if (atalho.liberadoPara(usuario))
          atalho
        else if (reserva.isNotEmpty)
          reserva.removeAt(0),
    ];
  }
}
