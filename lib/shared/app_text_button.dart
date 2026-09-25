import 'package:flutter/material.dart';
import 'package:texflow/shared/app_shadow_effect.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_text_style.dart';

class AppTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const AppTextButton({super.key, this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          boxShadow: [appShadowEffect()],
          color: AppColors.mainBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(text, style: AppTextStyle.appTextButtonStyle),
        ),
      ),
    );
  }
}
