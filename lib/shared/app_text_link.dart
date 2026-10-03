import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class AppTextLink extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const AppTextLink({super.key, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        texto,
        style: const TextStyle(
          color: AppColors.link,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
