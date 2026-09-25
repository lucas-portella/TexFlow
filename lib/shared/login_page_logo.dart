import 'package:flutter/material.dart';
import 'package:texflow/shared/app_shadow_effect.dart';
import 'package:texflow/shared/app_colors.dart';

class LoginPageLogo extends StatelessWidget {
  const LoginPageLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Container(
          decoration: BoxDecoration(boxShadow: [appShadowEffect()]),
          child: Image.asset(
            'lib/assets/images/logo-mark.png',
            width: 72,
            height: 72,
          ),
        ),
        Text(
          'TexFlow',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            fontFamily: 'DM Sans',
            color: AppColors.black,
          ),
        ),
        Text(
          'Gestão de produção têxtil',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: AppColors.mainGrey,
          ),
        ),
      ],
    );
  }
}
