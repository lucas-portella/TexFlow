import 'package:flutter/material.dart';
import 'package:texflow/models/fechamento.dart';
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
      initialChildSize: 0.6,
      maxChildSize: 0.9,
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
            for (final operacao in repasse.operacoes) ...[
              Text(
                '${operacao.codigo}'
                '${operacao.cliente == null ? '' : ' · ${operacao.cliente}'}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                '${operacao.quantidade} peças produzidas',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              for (final etapa in operacao.etapas)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${etapa.etapa} · ${formatarMoeda(etapa.valorPorPeca)} × ${etapa.quantidade ?? operacao.quantidade}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        formatarMoeda(etapa.total),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 24),
            ],
          ],
        );
      },
    );
  }
}
