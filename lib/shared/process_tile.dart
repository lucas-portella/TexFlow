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
  final bool mostrarStatus;
  final bool selecionavel;
  final bool selecionado;
  final VoidCallback? onTap;

  const ProcessTile({
    super.key,
    required this.processo,
    this.mostrarStatus = true,
    this.selecionavel = false,
    this.selecionado = false,
    this.onTap,
  });

  String get _responsavel {
    final nome =
        (processo.funcionarios.isEmpty ? null : processo.nomesDosResponsaveis) ??
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
    final cor = mostrarStatus ? statusColor(status) : AppColors.muted;
    final marcavel = selecionavel && status != Status.concluido;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (marcavel)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    selecionado
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: selecionado ? AppColors.primary : AppColors.muted,
                  ),
                )
              else if (mostrarStatus)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icone(status), size: 18, color: cor),
                  ),
                ),
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
              if (mostrarStatus) StatusBadge(status: status),
            ],
          ),
        ),
      ),
    );
  }
}
