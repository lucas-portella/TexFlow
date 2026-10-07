import 'package:flutter/material.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/status_badge.dart';
import 'package:texflow/shared/status_helpers.dart';

class ProductionCard extends StatelessWidget {
  final Operacao operacao;

  const ProductionCard({super.key, required this.operacao});

  @override
  Widget build(BuildContext context) {
    final title = operacao.cliente?.nomeFantasia ?? 'Cliente não informado';
    final date = operacao.dataEntrega ?? '';
    final pieces = '${operacao.totalPedido} peças';
    final ref = operacao.referencia != null
        ? 'Ref. ${operacao.referencia!.nome}'
        : '';
    final color = statusColor(operacao.status);
    final progress = operacao.progresso;
    final progressText = progress != null
        ? '${(progress * 100).round()}% concluído'
        : '';

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.operacaoDetalhes,
          arguments: operacao.id,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StatusBadge(status: operacao.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                operacao.codigo,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              if (date.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(width: 6),
                    const Text('·', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 6),
                    Text(
                      pieces,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
              if (progress != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.progressTrack,
                    color: color,
                  ),
                ),
              ],
              if (ref.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ref,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      progressText,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
