import 'package:flutter/material.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';

class FechamentoResumoCard extends StatelessWidget {
  final String rotulo;
  final String valor;
  final String? detalhe;
  final Color cor;
  final VoidCallback? onTap;
  final bool aberto;
  final Widget? conteudo;

  const FechamentoResumoCard({
    super.key,
    required this.rotulo,
    required this.valor,
    this.detalhe,
    this.cor = AppColors.ink,
    this.onTap,
    this.aberto = false,
    this.conteudo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rotulo,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    aberto ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.muted,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: cor,
              ),
            ),
            if (detalhe != null) ...[
              const SizedBox(height: 2),
              Text(
                detalhe!,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
            if (aberto && conteudo != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              conteudo!,
            ],
          ],
        ),
      ),
    );
  }
}
