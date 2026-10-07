import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class LoginPageLogo extends StatelessWidget {
  const LoginPageLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(40, 0, 0, 0),
                blurRadius: 20,
                spreadRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'lib/assets/images/logo-mark.png',
            width: 72,
            height: 72,
          ),
        ),
        const Text(
          'TexFlow',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        const Text(
          'Gestão de produção têxtil',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
