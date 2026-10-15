import 'package:flutter/material.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/shared/app_colors.dart';

class AppGretting extends StatelessWidget {
  const AppGretting({
    super.key,
    required this.usuario,
    this.onLogout,
    this.onMenu,
  });

  final Usuario? usuario;
  final VoidCallback? onLogout;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onMenu != null)
          IconButton(
            tooltip: 'Menu',
            onPressed: onMenu,
            icon: const Icon(Icons.menu, color: AppColors.ink),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bom dia,',
                style: TextStyle(fontSize: 15, color: AppColors.grey),
              ),
              Text(
                usuario?.nome ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (onLogout != null)
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: AppColors.grey),
          ),
      ],
    );
  }
}
