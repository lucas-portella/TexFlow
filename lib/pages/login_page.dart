import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_text_style.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.blueBackground,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                spacing: 8,
                children: [
                  Image.asset(
                    'lib/assets/images/logo-mark.png',
                    width: 64,
                    height: 64,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TexFlow', style: AppTextStyle.title),
                      Text('Textile Assis.', style: AppTextStyle.title),
                    ],
                  ),
                ],
              ),
              Form(
                child: Column(
                  children: [
                    AppTextField(
                      icon: Icon(Icons.account_circle_outlined),
                      labelText: 'Usuário/email',
                    ),
                    AppTextField(
                      icon: Icon(Icons.visibility_off),
                      labelText: 'Senha',
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Container(
                  width: 223,
                  height: 71,
                  decoration: BoxDecoration(
                    color: AppColors.mainBlue,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: AppColors.black, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      'Entrar',
                      style: TextStyle(color: AppColors.white),
                    ),
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

class AppTextField extends StatelessWidget {
  final Icon icon;
  final String labelText;

  const AppTextField({super.key, required this.icon, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 235,
      height: 60,
      child: TextFormField(
        decoration: InputDecoration(
          suffixIcon: icon,
          labelStyle: AppTextStyle.formLabel,
          filled: true,
          fillColor: AppColors.white,
          hintText: labelText,
          border: OutlineInputBorder(
            borderSide: BorderSide(),
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}
