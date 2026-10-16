import 'package:flutter/material.dart';
import 'package:texflow/models/relatorio.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/variacao_chip.dart';

class MetricaCard extends StatelessWidget {
  final String rotulo;
  final Metrica metrica;
  final String unidadeMedia;
  final bool dinheiro;
  final bool? maisEhBom;
  final Color cor;
  final bool mostrarMedia;

  const MetricaCard({
    super.key,
    required this.rotulo,
    required this.metrica,
    required this.unidadeMedia,
    this.dinheiro = true,
    this.maisEhBom = true,
    this.cor = AppColors.ink,
    this.mostrarMedia = true,
  });

  String _formatar(double valor, {bool media = false}) {
    if (dinheiro) return formatarMoeda(valor);
    return media ? formatarNumero(valor) : formatarInteiro(valor);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rotulo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
              VariacaoChip(
                variacao: metrica.variacaoPercentual,
                maisEhBom: maisEhBom,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mostrarMedia
                ? _formatar(metrica.mediaAtual, media: true)
                : _formatar(metrica.atual),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mostrarMedia
                ? 'Média do período anterior: ${_formatar(metrica.mediaAnterior, media: true)}'
                : 'Período anterior: ${_formatar(metrica.anterior)}',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
