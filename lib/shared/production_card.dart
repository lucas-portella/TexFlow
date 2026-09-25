import 'package:flutter/material.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/shared/status_helpers.dart';

class ProductionCard extends StatelessWidget {
  final Operacao operacao;

  const ProductionCard({super.key, required this.operacao});

  @override
  Widget build(BuildContext context) {
    final title = operacao.cliente?.nomeFantasia ?? 'Cliente não informado';
    final code = 'OP-${operacao.id}';
    final date = operacao.dataEntrega ?? '';
    final pieces = '${operacao.totalPedido} peças';
    final ref = operacao.referencia != null
        ? 'Ref. ${operacao.referencia!.nome}'
        : '';
    final status = statusLabel(operacao.status);
    final color = statusColor(operacao.status);
    final progress = operacao.progresso;
    final progressText = progress != null
        ? '${(progress * 100).round()}% concluído'
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(code, style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
                backgroundColor: const Color(0xFFEDEEF3),
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
    );
  }
}
