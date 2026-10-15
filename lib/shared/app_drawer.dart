import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _abrir(BuildContext context, String rota) {
    Navigator.pop(context);
    Navigator.pushNamed(context, rota);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UsuarioProvider>().usuario;

    return Drawer(
      backgroundColor: AppColors.navBar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TexFlow',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario?.nome ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 8),
            _ItemMenu(
              icone: Icons.checkroom_outlined,
              titulo: 'Modelos',
              aoTocar: () => _abrir(context, AppRoutes.modelos),
            ),
            _ItemMenu(
              icone: Icons.account_tree_outlined,
              titulo: 'Etapas',
              aoTocar: () => _abrir(context, AppRoutes.etapas),
            ),
            _ItemMenu(
              icone: Icons.groups_outlined,
              titulo: 'Funcionários',
              aoTocar: () => _abrir(context, AppRoutes.funcionarios),
            ),
            const Divider(color: Colors.white24, height: 24),
            _ItemMenu(
              icone: Icons.payments_outlined,
              titulo: 'Fechamento',
              aoTocar: () => _abrir(context, AppRoutes.fechamento),
            ),
          ],
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
