import 'package:texflow/models/custo.dart';

double _numero(dynamic valor) => (valor as num?)?.toDouble() ?? 0;

class Metrica {
  final double atual;
  final double anterior;
  final double? variacaoPercentual;
  final double mediaAtual;
  final double mediaAnterior;

  const Metrica({
    this.atual = 0,
    this.anterior = 0,
    this.variacaoPercentual,
    this.mediaAtual = 0,
    this.mediaAnterior = 0,
  });

  factory Metrica.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Metrica();

    return Metrica(
      atual: _numero(map['atual']),
      anterior: _numero(map['anterior']),
      variacaoPercentual: (map['variacaoPercentual'] as num?)?.toDouble(),
      mediaAtual: _numero(map['mediaAtual']),
      mediaAnterior: _numero(map['mediaAnterior']),
    );
  }
}

class PeriodoDoRelatorio {
  final int dias;
  final String inicio;
  final String fim;
  final String anteriorInicio;
  final String anteriorFim;
  final String unidadeMedia;

  const PeriodoDoRelatorio({
    this.dias = 0,
    this.inicio = '',
    this.fim = '',
    this.anteriorInicio = '',
    this.anteriorFim = '',
    this.unidadeMedia = 'mês',
  });

  factory PeriodoDoRelatorio.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PeriodoDoRelatorio();

    return PeriodoDoRelatorio(
      dias: map['dias'] ?? 0,
      inicio: map['inicio'] ?? '',
      fim: map['fim'] ?? '',
      anteriorInicio: map['anteriorInicio'] ?? '',
      anteriorFim: map['anteriorFim'] ?? '',
      unidadeMedia: map['unidadeMedia'] ?? 'mês',
    );
  }
}

class LinhaCategoriaRelatorio {
  final CategoriaCusto categoria;
  final Metrica valor;

  const LinhaCategoriaRelatorio({required this.categoria, required this.valor});

  factory LinhaCategoriaRelatorio.fromMap(Map<String, dynamic> map) {
    return LinhaCategoriaRelatorio(
      categoria: CategoriaCusto.deJson(map['categoria']),
      valor: Metrica.fromMap(map['valor']),
    );
  }
}

class LinhaEtapaRelatorio {
  final String etapa;
  final Metrica valor;

  const LinhaEtapaRelatorio({required this.etapa, required this.valor});

  factory LinhaEtapaRelatorio.fromMap(Map<String, dynamic> map) {
    return LinhaEtapaRelatorio(
      etapa: map['etapa'] ?? '',
      valor: Metrica.fromMap(map['valor']),
    );
  }
}

class RelatorioEmpresa {
  final PeriodoDoRelatorio periodo;
  final bool custosIncluidos;
  final Metrica faturamento;
  final Metrica repasses;
  final Metrica despesas;
  final Metrica lucro;
  final Metrica producoes;
  final Metrica pecas;
  final Metrica faturamentoDoAno;
  final List<LinhaCategoriaRelatorio> despesasPorCategoria;
  final List<LinhaEtapaRelatorio> repassesPorEtapa;

  const RelatorioEmpresa({
    required this.periodo,
    required this.custosIncluidos,
    required this.faturamento,
    required this.repasses,
    required this.despesas,
    required this.lucro,
    required this.producoes,
    required this.pecas,
    required this.faturamentoDoAno,
    required this.despesasPorCategoria,
    required this.repassesPorEtapa,
  });

  factory RelatorioEmpresa.fromMap(Map<String, dynamic> map) {
    return RelatorioEmpresa(
      periodo: PeriodoDoRelatorio.fromMap(map['periodo']),
      custosIncluidos: map['custosIncluidos'] ?? false,
      faturamento: Metrica.fromMap(map['faturamento']),
      repasses: Metrica.fromMap(map['repasses']),
      despesas: Metrica.fromMap(map['despesas']),
      lucro: Metrica.fromMap(map['lucro']),
      producoes: Metrica.fromMap(map['producoes']),
      pecas: Metrica.fromMap(map['pecas']),
      faturamentoDoAno: Metrica.fromMap(map['faturamentoDoAno']),
      despesasPorCategoria:
          (map['despesasPorCategoria'] as List<dynamic>? ?? [])
              .map((item) => LinhaCategoriaRelatorio.fromMap(item))
              .toList(),
      repassesPorEtapa: (map['repassesPorEtapa'] as List<dynamic>? ?? [])
          .map((item) => LinhaEtapaRelatorio.fromMap(item))
          .toList(),
    );
  }
}

class LinhaFuncionarioRelatorio {
  final int funcionarioId;
  final String funcionario;
  final Metrica pecas;
  final Metrica producoes;
  final Metrica repasse;
  final double valorMedioPorPeca;
  final String? etapaPrincipal;

  const LinhaFuncionarioRelatorio({
    required this.funcionarioId,
    required this.funcionario,
    required this.pecas,
    required this.producoes,
    required this.repasse,
    required this.valorMedioPorPeca,
    this.etapaPrincipal,
  });

  factory LinhaFuncionarioRelatorio.fromMap(Map<String, dynamic> map) {
    return LinhaFuncionarioRelatorio(
      funcionarioId: map['funcionarioId'] ?? 0,
      funcionario: map['funcionario'] ?? '',
      pecas: Metrica.fromMap(map['pecas']),
      producoes: Metrica.fromMap(map['producoes']),
      repasse: Metrica.fromMap(map['repasse']),
      valorMedioPorPeca: _numero(map['valorMedioPorPeca']),
      etapaPrincipal: map['etapaPrincipal'],
    );
  }
}

class RelatorioFuncionarios {
  final PeriodoDoRelatorio periodo;
  final Metrica totalPecas;
  final Metrica totalRepasse;
  final List<LinhaFuncionarioRelatorio> funcionarios;

  const RelatorioFuncionarios({
    required this.periodo,
    required this.totalPecas,
    required this.totalRepasse,
    required this.funcionarios,
  });

  factory RelatorioFuncionarios.fromMap(Map<String, dynamic> map) {
    return RelatorioFuncionarios(
      periodo: PeriodoDoRelatorio.fromMap(map['periodo']),
      totalPecas: Metrica.fromMap(map['totalPecas']),
      totalRepasse: Metrica.fromMap(map['totalRepasse']),
      funcionarios: (map['funcionarios'] as List<dynamic>? ?? [])
          .map((item) => LinhaFuncionarioRelatorio.fromMap(item))
          .toList(),
    );
  }
}
