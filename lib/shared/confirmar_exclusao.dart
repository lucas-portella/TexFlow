import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

Future<bool> confirmarExclusao(BuildContext context, String nome) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Excluir'),
        content: Text('Deseja excluir "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      );
    },
  );

  return confirmado ?? false;
}
