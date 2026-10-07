import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String texto;

  const SectionTitle({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
