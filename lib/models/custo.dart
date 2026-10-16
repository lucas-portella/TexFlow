import 'package:flutter/material.dart';

enum CategoriaCusto {
  aluguel('ALUGUEL', 'Aluguel', Icons.home_work_outlined),
  energiaAgua('ENERGIA_AGUA', 'Energia e água', Icons.bolt_outlined),
  internetTelefone(
    'INTERNET_TELEFONE',
    'Internet e telefone',
    Icons.wifi_outlined,
  ),
  salarios('SALARIOS', 'Salários e encargos', Icons.badge_outlined),
  material('MATERIAL', 'Material', Icons.inventory_2_outlined),
  manutencao('MANUTENCAO', 'Manutenção', Icons.build_outlined),
  impostos('IMPOSTOS', 'Impostos', Icons.account_balance_outlined),
  transporte('TRANSPORTE', 'Transporte', Icons.local_shipping_outlined),
  outros('OUTROS', 'Outros', Icons.more_horiz);

  final String json;
  final String rotulo;
  final IconData icone;

  const CategoriaCusto(this.json, this.rotulo, this.icone);

  static CategoriaCusto deJson(String? valor) {
    for (final categoria in CategoriaCusto.values) {
      if (categoria.json == valor) return categoria;
    }
    return CategoriaCusto.outros;
  }
}

class Custo {
  final int id;
  final String descricao;
  final CategoriaCusto categoria;
  final double valor;
  final String data;
  final int? intervaloDias;
  final String? dataFim;
  final int ocorrenciasNoMes;
  final double totalNoMes;

  Custo({
    required this.id,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.data,
    this.intervaloDias,
    this.dataFim,
    this.ocorrenciasNoMes = 0,
    this.totalNoMes = 0,
  });

  factory Custo.fromMap(Map<String, dynamic> map) {
    return Custo(
      id: map['id'] ?? 0,
      descricao: map['descricao'] ?? '',
      categoria: CategoriaCusto.deJson(map['categoria']),
      valor: (map['valor'] as num?)?.toDouble() ?? 0,
      data: map['data'] ?? '',
      intervaloDias: map['intervaloDias'],
      dataFim: map['dataFim'],
      ocorrenciasNoMes: map['ocorrenciasNoMes'] ?? 0,
      totalNoMes: (map['totalNoMes'] as num?)?.toDouble() ?? 0,
    );
  }

  bool get recorrente => intervaloDias != null;
}

class CustoCategoriaTotal {
  final CategoriaCusto categoria;
  final double total;

  CustoCategoriaTotal({required this.categoria, required this.total});

  factory CustoCategoriaTotal.fromMap(Map<String, dynamic> map) {
    return CustoCategoriaTotal(
      categoria: CategoriaCusto.deJson(map['categoria']),
      total: (map['total'] as num?)?.toDouble() ?? 0,
    );
  }
}
