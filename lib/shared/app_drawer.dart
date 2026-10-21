import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/providers/minha_empresa_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_info.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _cadastros = [
    Modulo.modelos,
    Modulo.etapas,
    Modulo.funcionarios,
    Modulo.clientes,
  ];

  static const _administrativo = [
    Modulo.custos,
    Modulo.fechamento,
    Modulo.relatorios,
    Modulo.logs,
  ];

  void _abrir(BuildContext context, String rota) {
    Navigator.pop(context);
    Navigator.pushNamed(context, rota);
  }

  void _irParaInicio(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  Future<void> _sair(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<UsuarioProvider>().logout();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UsuarioProvider>().usuario;
    final nomeDaEmpresa = context
        .watch<MinhaEmpresaProvider>()
        .empresa
        ?.nomeFantasia
        .trim();

    List<Modulo> liberados(List<Modulo> modulos) {
      return modulos
          .where((modulo) => usuario?.temModulo(modulo) ?? false)
          .toList();
    }

    final cadastros = liberados(_cadastros);
    final administrativo = liberados(_administrativo);

    return Drawer(
      backgroundColor: AppColors.navBar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 12, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomeDaEmpresa ?? '',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          usuario?.nome ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Sair',
                        onPressed: () => _sair(context),
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  _ItemMenu(
                    icone: Icons.home_outlined,
                    titulo: 'Início',
                    aoTocar: () => _irParaInicio(context),
                  ),
                  if (cadastros.isNotEmpty) ...[
                    const _SecaoMenu('CADASTROS'),
                    for (final modulo in cadastros) ...[
                      _ItemMenu(
                        icone: modulo.icone,
                        titulo: modulo.rotulo,
                        aoTocar: () => _abrir(context, modulo.rota),
                      ),
                      if (modulo == Modulo.etapas) ...[
                        _ItemMenu(
                          icone: Icons.palette_outlined,
                          titulo: 'Cores',
                          aoTocar: () => _abrir(context, AppRoutes.cores),
                        ),
                        _ItemMenu(
                          icone: Icons.straighten,
                          titulo: 'Tamanhos',
                          aoTocar: () => _abrir(context, AppRoutes.tamanhos),
                        ),
                      ],
                    ],
                  ],
                  if (administrativo.isNotEmpty) ...[
                    const _SecaoMenu('ADMINISTRATIVO'),
                    for (final modulo in administrativo)
                      _ItemMenu(
                        icone: modulo.icone,
                        titulo: modulo.rotulo,
                        aoTocar: () => _abrir(context, modulo.rota),
                      ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TexFlow',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'v${AppInfo.versao}',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecaoMenu extends StatelessWidget {
  final String titulo;

  const _SecaoMenu(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback aoTocar;

  const _ItemMenu({
    required this.icone,
    required this.titulo,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icone, color: Colors.white70),
      title: Text(
        titulo,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: aoTocar,
    );
  }
}
