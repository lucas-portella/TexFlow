import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class StatCard extends StatelessWidget {
  final int valor;
  final String rotulo;
  final Color cor;

  const StatCard({
    super.key,
    required this.valor,
    required this.rotulo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rotulo,
            style: const TextStyle(fontSize: 13, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
