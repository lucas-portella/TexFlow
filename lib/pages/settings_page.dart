import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_info.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/settings_page_button.dart';
import 'package:texflow/shared/settings_page_card.dart';
import 'package:texflow/shared/settings_page_logoff_button.dart';
import 'package:texflow/shared/settings_page_user_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const route = AppRoutes.configuracoes;

  Future<void> _sair(BuildContext context) async {
    await context.read<UsuarioProvider>().logout();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

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
              Consumer<UsuarioProvider>(
                builder: (context, usuarioProvider, child) {
                  final usuario = usuarioProvider.usuario;
                  if (usuario == null) return const SizedBox.shrink();
                  return SettingsPageUserCard(usuario: usuario);
                },
              ),
              SettingsPageCard(
                title: 'CONTA',
                buttons: [
                  SettingsPageButton(
                    title: 'Alterar senha',
                    subtitle: 'Altere sua senha de acesso ao aplicativo.',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.alterarSenha),
                  ),
                  SettingsPageButton(
                    title: 'Cadastrar usuário',
                    subtitle: 'Cadastrar um novo operador ou supervisor',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.novoUsuario),
                  ),
                ],
              ),
              SettingsPageCard(
                title: 'SOBRE',
                buttons: [
                  SettingsPageButton(
                    title: 'Versão do app',
                    subtitle: AppInfo.versao,
                    onTap: () {},
                  ),
                  SettingsPageButton(
                    title: 'Suporte técnico',
                    subtitle: 'suporte@texflow.com.br',
                    onTap: () {},
                  ),
                ],
              ),
              SettingsPageLogoffButton(onPressed: () => _sair(context)),
            ],
          ),
        ),
      ),
    );
  }
}
