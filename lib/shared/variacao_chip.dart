import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/formatters.dart';

class VariacaoChip extends StatelessWidget {
  final double? variacao;
  final bool? maisEhBom;

  const VariacaoChip({
    super.key,
    required this.variacao,
    this.maisEhBom = true,
  });

  @override
  Widget build(BuildContext context) {
    final valor = variacao;

    if (valor == null) {
      return const _Selo(
        texto: 'Sem base',
        cor: AppColors.muted,
        icone: Icons.remove,
      );
    }

    if (valor == 0) {
      return const _Selo(
        texto: '0,0%',
        cor: AppColors.muted,
        icone: Icons.remove,
      );
    }

    final subiu = valor > 0;
    final cor = maisEhBom == null
        ? AppColors.muted
        : (subiu == maisEhBom! ? AppColors.success : AppColors.danger);

    return _Selo(
      texto: '${subiu ? '+' : '-'}${formatarNumero(valor.abs())}%',
      cor: cor,
      icone: subiu ? Icons.arrow_upward : Icons.arrow_downward,
    );
  }
}

class _Selo extends StatelessWidget {
  final String texto;
  final Color cor;
  final IconData icone;

  const _Selo({required this.texto, required this.cor, required this.icone});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 12, color: cor),
        const SizedBox(width: 2),
        Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cor,
          ),
        ),
      ],
    );
  }
}
