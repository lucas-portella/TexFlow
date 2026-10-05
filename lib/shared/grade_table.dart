import 'package:flutter/material.dart';
import 'package:texflow/models/item_grade.dart';
import 'package:texflow/shared/app_colors.dart';

class GradeTable extends StatelessWidget {
  final List<ItemGrade> itens;

  const GradeTable({super.key, required this.itens});

  int get _total => itens.fold(0, (soma, item) => soma + item.quantidade);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const _GradeRow(
            tamanho: 'TAMANHO',
            quantidade: 'QUANTIDADE',
            fundo: AppColors.screenBackground,
            cabecalho: true,
          ),
          for (var i = 0; i < itens.length; i++)
            _GradeRow(
              tamanho: itens[i].descricao,
              quantidade: '${itens[i].quantidade} pç',
              fundo: i.isOdd ? AppColors.tableStripe : AppColors.white,
            ),
          _GradeRow(
            tamanho: 'Total',
            quantidade: '$_total pç',
            fundo: AppColors.tableTotal,
            destaque: true,
          ),
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  final String tamanho;
  final String quantidade;
  final Color fundo;
  final bool cabecalho;
  final bool destaque;

  const _GradeRow({
    required this.tamanho,
    required this.quantidade,
    required this.fundo,
    this.cabecalho = false,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final corTexto = cabecalho ? AppColors.muted : AppColors.ink;

    return Container(
      color: fundo,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: cabecalho ? 12 : 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tamanho,
            style: TextStyle(
              fontSize: cabecalho ? 11 : 14,
              fontWeight: FontWeight.w700,
              color: corTexto,
            ),
          ),
          Text(
            quantidade,
            style: TextStyle(
              fontSize: cabecalho ? 11 : 14,
              fontFamily: cabecalho ? null : 'monospace',
              fontWeight: cabecalho || destaque
                  ? FontWeight.w800
                  : FontWeight.normal,
              color: cabecalho || destaque ? corTexto : AppColors.tableText,
            ),
          ),
        ],
      ),
    );
  }
}
