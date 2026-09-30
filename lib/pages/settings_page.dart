import 'package:flutter/material.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/shared/settings_page_button.dart';
import 'package:texflow/shared/settings_page_card.dart';
import 'package:texflow/shared/settings_page_logoff_button.dart';
import 'package:texflow/shared/settings_page_user_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/application_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationAppBar(title: 'Configurações'),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: AppColors.lightBackground,
        child: SafeArea(
          child: Column(
            spacing: 20,
            children: [
              SettingsPageUserCard(
                usuario: Usuario(
                  idUsuario: 0,
                  nome: 'Lucas Portella',
                  email: '',
                  senha: '',
                  tipo: UserType.GESTOR,
                ),
              ),
              SettingsPageCard(
                title: 'CONTA',
                buttons: [
                  SettingsPageButton(
                    title: 'Alterar senha',
                    subtitle: 'Altere sua senha de acesso ao aplicativo.',
                    onTap: () {},
                  ),
                  SettingsPageButton(
                    title: 'Cadastrar usuário',
                    subtitle: 'Cadastrar um novo operador ou supervisor',
                    onTap: () {},
                  ),
                ],
              ),
              SettingsPageCard(
                title: 'SOBRE',
                buttons: [
                  SettingsPageButton(
                    title: 'Versão do app',
                    subtitle: '0.0.1',
                    onTap: () {},
                  ),
                  SettingsPageButton(
                    title: 'Suporte técnico',
                    subtitle: 'suporte@texflow.com.br',
                    onTap: () {},
                  ),
                ],
              ),
              SettingsPageLogoffButton(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
