import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class InfoChip extends StatelessWidget {
  final String texto;
  final Color cor;

  const InfoChip({super.key, required this.texto, this.cor = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          color: cor,
        ),
      ),
    );
  }
}
