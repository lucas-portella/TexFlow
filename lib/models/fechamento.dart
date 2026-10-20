import 'package:texflow/models/custo.dart';

class RepasseEtapa {
  String etapa;
  double valorPorPeca;
  int? quantidade;
  double total;

  RepasseEtapa({
    required this.etapa,
    required this.valorPorPeca,
    this.quantidade,
    required this.total,
  });

  factory RepasseEtapa.fromMap(Map<String, dynamic> map) {
    return RepasseEtapa(
      etapa: map['etapa'] ?? '',
      valorPorPeca: (map['valorPorPeca'] as num?)?.toDouble() ?? 0,
      quantidade: (map['quantidade'] as num?)?.toInt(),
      total: (map['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RepasseOperacao {
  int operacaoId;
  String? numero;
  String? cliente;
  int quantidade;
  double total;
  List<RepasseEtapa> etapas;

  RepasseOperacao({
    required this.operacaoId,
    this.numero,
    this.cliente,
    required this.quantidade,
    required this.total,
    required this.etapas,
  });

  String get codigo {
    final texto = numero?.trim();
    return 'OP-${texto == null || texto.isEmpty ? operacaoId : texto}';
  }

  factory RepasseOperacao.fromMap(Map<String, dynamic> map) {
    return RepasseOperacao(
      operacaoId: map['operacaoId'] ?? 0,
      numero: map['numero'],
      cliente: map['cliente'],
      quantidade: map['quantidade'] ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      etapas: (map['etapas'] as List<dynamic>? ?? [])
          .map((item) => RepasseEtapa.fromMap(item))
          .toList(),
    );
  }
}

class RepasseFuncionario {
  int funcionarioId;
  String funcionario;
  double total;
  List<RepasseOperacao> operacoes;

  RepasseFuncionario({
    required this.funcionarioId,
    required this.funcionario,
    required this.total,
    required this.operacoes,
  });

  factory RepasseFuncionario.fromMap(Map<String, dynamic> map) {
    return RepasseFuncionario(
      funcionarioId: map['funcionarioId'] ?? 0,
      funcionario: map['funcionario'] ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0,
      operacoes: (map['operacoes'] as List<dynamic>? ?? [])
          .map((item) => RepasseOperacao.fromMap(item))
          .toList(),
    );
  }
}

class Fechamento {
  String mes;
  int quantidadeOperacoes;
  int totalPecas;
  double totalRecebido;
  double totalRepasse;
  double lucro;
  bool custosIncluidos;
  double totalCustos;
  List<CustoCategoriaTotal> custosPorCategoria;
  List<RepasseFuncionario> repasses;

  Fechamento({
    required this.mes,
    required this.quantidadeOperacoes,
    required this.totalPecas,
    required this.totalRecebido,
    required this.totalRepasse,
    required this.lucro,
    this.custosIncluidos = false,
    this.totalCustos = 0,
    this.custosPorCategoria = const [],
    required this.repasses,
  });

  factory Fechamento.fromMap(Map<String, dynamic> map) {
    return Fechamento(
      mes: map['mes'] ?? '',
      quantidadeOperacoes: map['quantidadeOperacoes'] ?? 0,
      totalPecas: map['totalPecas'] ?? 0,
      totalRecebido: (map['totalRecebido'] as num?)?.toDouble() ?? 0,
      totalRepasse: (map['totalRepasse'] as num?)?.toDouble() ?? 0,
      lucro: (map['lucro'] as num?)?.toDouble() ?? 0,
      custosIncluidos: map['custosIncluidos'] ?? false,
      totalCustos: (map['totalCustos'] as num?)?.toDouble() ?? 0,
      custosPorCategoria: (map['custosPorCategoria'] as List<dynamic>? ?? [])
          .map((item) => CustoCategoriaTotal.fromMap(item))
          .toList(),
      repasses: (map['repasses'] as List<dynamic>? ?? [])
          .map((item) => RepasseFuncionario.fromMap(item))
          .toList(),
    );
  }
}
