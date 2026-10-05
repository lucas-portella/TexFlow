import 'package:flutter/material.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/info_chip.dart';
import 'package:texflow/shared/status_badge.dart';

class OperationHeader extends StatelessWidget {
  final Operacao operacao;

  const OperationHeader({super.key, required this.operacao});

  @override
  Widget build(BuildContext context) {
    final cliente = operacao.cliente?.nomeFantasia ?? 'Cliente não informado';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cliente,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              StatusBadge(status: operacao.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(texto: operacao.codigo),
              if (operacao.referencia != null)
                InfoChip(
                  texto: operacao.referencia!.nome,
                  cor: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                'Entrega em ${formatarData(operacao.dataEntrega)}',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
