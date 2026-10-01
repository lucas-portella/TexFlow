import 'package:flutter/material.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/shared/app_colors.dart';

class SettingsPageUserCard extends StatelessWidget {
  final Usuario usuario;
  const SettingsPageUserCard({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        spacing: 16,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.mainBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                usuario.nome[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.white,
                  fontFamily: 'DM Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuario.nome,
                style: TextStyle(
                  color: AppColors.white,
                  fontFamily: 'DM Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                usuario.tipo == UserType.GESTOR
                    ? 'Supervisor(a) de produção'
                    : 'Operador',
                style: TextStyle(fontFamily: 'DM Sans', color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
