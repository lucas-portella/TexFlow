import 'package:flutter/material.dart';
import 'package:texflow/models/cor.dart';
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/formatters.dart';

class RepasseFuncionarioSheet extends StatelessWidget {
  final RepasseFuncionario repasse;

  const RepasseFuncionarioSheet({super.key, required this.repasse});

  static Future<void> abrir(BuildContext context, RepasseFuncionario repasse) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RepasseFuncionarioSheet(repasse: repasse),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              repasse.funcionario,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Total a receber: ${formatarMoeda(repasse.total)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            for (final operacao in repasse.operacoes)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CartaoDaOperacao(operacao: operacao),
              ),
          ],
        );
      },
    );
  }
}

class _CartaoDaOperacao extends StatelessWidget {
  final RepasseOperacao operacao;

  const _CartaoDaOperacao({required this.operacao});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${operacao.codigo}'
                  '${operacao.cliente == null ? '' : ' · ${operacao.cliente}'}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatarMoeda(operacao.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${formatarInteiro(operacao.quantidade.toDouble())} peças produzidas',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          for (final etapa in operacao.etapas) ...[
            const Divider(height: 22),
            _BlocoDaEtapa(
              etapa: etapa,
              quantidadeDaOperacao: operacao.quantidade,
            ),
          ],
        ],
      ),
    );
  }
}

class _BlocoDaEtapa extends StatelessWidget {
  final RepasseEtapa etapa;
  final int quantidadeDaOperacao;

  const _BlocoDaEtapa({
    required this.etapa,
    required this.quantidadeDaOperacao,
  });

  @override
  Widget build(BuildContext context) {
    final quantidade = etapa.quantidade ?? quantidadeDaOperacao;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etapa.etapa,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${formatarMoeda(etapa.valorPorPeca)} × ${formatarInteiro(quantidade.toDouble())} peças',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatarMoeda(etapa.total),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        if (etapa.linhas.any((linha) => linha.cor != null)) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.screenBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                for (final linha in etapa.linhas) _LinhaDaCor(linha: linha),
              ],
            ),
          ),
        ] else
          for (final linha in etapa.linhas.where((l) => l.tamanho != null))
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${linha.tamanho} · ${formatarInteiro(linha.quantidade.toDouble())} peças',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ),
      ],
    );
  }
}

class _LinhaDaCor extends StatelessWidget {
  final RepasseLinha linha;

  const _LinhaDaCor({required this.linha});

  @override
  Widget build(BuildContext context) {
    final cor = linha.hex == null ? null : Cor.corDoHex(linha.hex!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (cor != null) ...[
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black26),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              [?linha.cor, ?linha.tamanho].join(' · '),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${formatarInteiro(linha.quantidade.toDouble())} peças',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
