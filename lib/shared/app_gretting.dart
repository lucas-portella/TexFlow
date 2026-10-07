import 'package:flutter/material.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/shared/app_colors.dart';

class AppGretting extends StatelessWidget {
  const AppGretting({super.key, required this.usuario});

  final Usuario? usuario;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bom dia,',
          style: TextStyle(fontSize: 15, color: AppColors.grey),
        ),
        Text(
          usuario?.nome ?? '',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
