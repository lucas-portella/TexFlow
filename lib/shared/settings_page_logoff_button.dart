import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class SettingsPageLogoffButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SettingsPageLogoffButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.lightRed,
          side: BorderSide(color: AppColors.errorRed),
        ),
        child: Text(
          'Sair da conta',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            color: AppColors.errorRed,
          ),
        ),
      ),
    );
  }
}
