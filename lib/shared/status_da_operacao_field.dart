import 'package:flutter/material.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/status_helpers.dart';

String rotuloDoStatusDaOperacao(Status status) {
  switch (status) {
    case Status.naoIniciado:
      return 'Novo';
    case Status.emAndamento:
      return 'Em andamento';
    case Status.concluido:
      return 'Concluído';
    case Status.cancelado:
      return 'Cancelado';
  }
}

class StatusDaOperacaoField extends StatelessWidget {
  final Status status;
  final bool habilitado;
  final ValueChanged<Status> aoEscolher;

  const StatusDaOperacaoField({
    super.key,
    required this.status,
    required this.aoEscolher,
    this.habilitado = true,
  });

  static const _opcoes = [
    Status.naoIniciado,
    Status.emAndamento,
    Status.concluido,
  ];

  Future<void> _abrir(BuildContext context) async {
    final escolhido = await showModalBottomSheet<Status>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Status da produção',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            for (final opcao in _opcoes)
              ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 14,
                  color: statusColor(opcao),
                ),
                title: Text(rotuloDoStatusDaOperacao(opcao)),
                trailing: opcao == status
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(sheetContext, opcao),
              ),
            const SizedBox(height: 12),
          ],
        );
      },
    );

    if (escolhido != null && escolhido != status) aoEscolher(escolhido);
  }

  @override
  Widget build(BuildContext context) {
    final cor = statusColor(status);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: habilitado ? () => _abrir(context) : null,
      child: AppCard(
        child: Row(
          children: [
            Icon(Icons.circle, size: 14, color: cor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rotuloDoStatusDaOperacao(status),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (habilitado)
              const Icon(Icons.arrow_drop_down, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
