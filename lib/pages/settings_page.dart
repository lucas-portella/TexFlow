import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/providers/preferencias_provider.dart';
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
    final usuarioLogado = context.watch<UsuarioProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const ApplicationAppBar(title: 'Configurações'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
              if (usuarioLogado.donoDaEmpresa)
                SettingsPageCard(
                  title: 'EMPRESA',
                  buttons: [
                    SettingsPageButton(
                      title: 'Minha empresa',
                      subtitle:
                          'Nome, CNPJ, contato e endereço da sua empresa.',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.minhaEmpresa),
                    ),
                  ],
                ),
              Consumer<PreferenciasProvider>(
                builder: (context, preferencias, child) {
                  return SettingsPageCard(
                    title: 'PREFERÊNCIAS',
                    buttons: [
                      if (usuarioLogado.usuario?.temModulo(
                            Modulo.modoOperacao,
                          ) ??
                          false)
                        SettingsPageButton(
                          title: 'Modo de operação',
                          subtitle: preferencias.modoOperacao.rotulo,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.modoOperacao,
                          ),
                        ),
                      SettingsPageButton(
                        title: 'Atalhos da tela inicial',
                        subtitle: 'Escolha os 4 atalhos da barra de baixo.',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.atalhos),
                      ),
                    ],
                  );
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
                  if (usuarioLogado.usuario?.temModulo(Modulo.usuarios) ??
                      false)
                    SettingsPageButton(
                      title: 'Usuários',
                      subtitle:
                          'Cadastrar usuários e definir o que cada um acessa',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.usuarios),
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
