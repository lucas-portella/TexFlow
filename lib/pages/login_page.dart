import 'package:flutter/material.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/login_page_logo.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_text_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.lightBackground,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 50),
              LoginPageLogo(),
              SizedBox(height: 50),
              Form(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      AppTextField(
                        label: 'USUÁRIO',
                        hintText: 'seu.usuario',
                        prefixIcon: Icons.person_outlined,
                      ),
                      AppTextField(
                        label: 'SENHA',
                        hintText: '********',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: Icons.visibility_outlined,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Esqueci minha senha',
                          style: TextStyle(
                            color: AppColors.lightBlue,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      AppTextButton(text: 'Entrar', onPressed: () {}),
                      Text(
                        'TexFlow v0.0.1 © 2026 Todos os direitos reservados',
                        style: TextStyle(
                          color: AppColors.lightGrey,
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
