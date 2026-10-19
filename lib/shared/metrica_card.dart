import 'package:flutter/material.dart';
import 'package:texflow/models/relatorio.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/variacao_chip.dart';

class MetricaCard extends StatelessWidget {
  final String rotulo;
  final Metrica metrica;
  final bool dinheiro;
  final bool? maisEhBom;
  final Color cor;
  final bool compacto;

  const MetricaCard({
    super.key,
    required this.rotulo,
    required this.metrica,
    this.dinheiro = true,
    this.maisEhBom = true,
    this.cor = AppColors.ink,
    this.compacto = false,
  });

  String _formatar(double valor) {
    return dinheiro ? formatarMoeda(valor) : formatarInteiro(valor);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatar(metrica.atual),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
          const SizedBox(height: 8),
          ComparacaoComPeriodoAnterior(
            anterior: _formatar(metrica.anterior),
            variacao: metrica.variacaoPercentual,
            maisEhBom: maisEhBom,
            compacto: compacto,
          ),
        ],
      ),
    );
  }
}

class ComparacaoComPeriodoAnterior extends StatelessWidget {
  final String anterior;
  final double? variacao;
  final bool? maisEhBom;
  final bool compacto;

  const ComparacaoComPeriodoAnterior({
    super.key,
    required this.anterior,
    required this.variacao,
    this.maisEhBom = true,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            '${compacto ? 'Anterior' : 'Período anterior'}: $anterior',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
        const SizedBox(width: 8),
        VariacaoChip(variacao: variacao, maisEhBom: maisEhBom),
      ],
    );
  }
}
