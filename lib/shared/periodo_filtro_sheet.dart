import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/opcoes_filtro_sheet.dart';

const _mesesAbreviados = [
  'Jan',
  'Fev',
  'Mar',
  'Abr',
  'Mai',
  'Jun',
  'Jul',
  'Ago',
  'Set',
  'Out',
  'Nov',
  'Dez',
];

Future<ResultadoFiltro<DateTime>?> abrirFiltroDePeriodo(
  BuildContext context, {
  required DateTime? selecionado,
}) {
  return showModalBottomSheet<ResultadoFiltro<DateTime>>(
    context: context,
    showDragHandle: true,
    builder: (context) => _PeriodoSheet(selecionado: selecionado),
  );
}

class _PeriodoSheet extends StatefulWidget {
  final DateTime? selecionado;

  const _PeriodoSheet({required this.selecionado});

  @override
  State<_PeriodoSheet> createState() => _PeriodoSheetState();
}

class _PeriodoSheetState extends State<_PeriodoSheet> {
  late int _ano = widget.selecionado?.year ?? DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Período',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Usa a data de finalização, ou a de entrega se a produção ainda está aberta.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Ano anterior',
                onPressed: () => setState(() => _ano--),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '$_ano',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                tooltip: 'Próximo ano',
                onPressed: () => setState(() => _ano++),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var mes = 1; mes <= 12; mes++)
                ChoiceChip(
                  label: Text(_mesesAbreviados[mes - 1]),
                  selected:
                      widget.selecionado?.year == _ano &&
                      widget.selecionado?.month == mes,
                  onSelected: (_) => Navigator.pop(
                    context,
                    ResultadoFiltro<DateTime>(DateTime(_ano, mes)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, ResultadoFiltro<DateTime>(null)),
            child: const Text('Qualquer período'),
          ),
        ],
      ),
    );
  }
}
