import 'package:flutter/material.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';

class OperationProgressCard extends StatelessWidget {
  final Operacao operacao;

  const OperationProgressCard({super.key, required this.operacao});

  @override
  Widget build(BuildContext context) {
    final valor = operacao.progresso ?? 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso geral',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '${(valor * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: valor,
              minHeight: 6,
              backgroundColor: AppColors.progressTrack,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${operacao.processosConcluidos} de ${operacao.processos.length} processos concluídos',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
