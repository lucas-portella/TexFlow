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

  ButtonStyle get _estiloBotao => IconButton.styleFrom(
    backgroundColor: AppColors.white,
    fixedSize: const Size(44, 44),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: AppColors.grey.withValues(alpha: 0.25)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        if (onMenu != null)
          IconButton(
            tooltip: 'Menu',
            style: _estiloBotao,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            tooltip: 'Sair',
            style: _estiloBotao,
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: AppColors.grey),
          ),
      ],
    );
  }
}
