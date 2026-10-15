import 'package:flutter/material.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/status_badge.dart';
import 'package:texflow/shared/status_helpers.dart';

class ProcessTile extends StatelessWidget {
  final ProcessoProdutivo processo;

  const ProcessTile({super.key, required this.processo});

  String get _responsavel {
    final nome =
        processo.funcionario?.nome ??
        processo.empresaResponsavel?.nomeFantasia ??
        'Sem responsável';
    final valor = processo.valorComissao;
    if (valor == null) return nome;
    return '$nome · ${formatarMoeda(valor)} por peça';
  }

  IconData _icone(Status status) {
    switch (status) {
      case Status.concluido:
        return Icons.check;
      case Status.cancelado:
        return Icons.close;
      case Status.emAndamento:
      case Status.naoIniciado:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = processo.status ?? Status.naoIniciado;
    final cor = statusColor(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icone(status), size: 18, color: cor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    processo.descricao,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _responsavel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(status: status),
          ],
        ),
      ),
    );
  }
}
