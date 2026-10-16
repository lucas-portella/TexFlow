import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/atalho_rapido.dart';
import 'package:texflow/providers/atalhos_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final String current;

  const AppBottomNav({super.key, required this.current});

  void _abrir(BuildContext context, String rota) {
    if (rota == current) return;

    if (rota == AppRoutes.dashboard || rota == AppRoutes.pesquisa) {
      Navigator.pushNamedAndRemoveUntil(context, rota, (route) => false);
      return;
    }

    Navigator.pushNamed(context, rota);
  }

  @override
  Widget build(BuildContext context) {
    final atalhos = AtalhoRapido.visiveisPara(
      context.watch<AtalhosProvider>().atalhos,
      context.watch<UsuarioProvider?>()?.usuario,
    );
    final esquerda = atalhos.take(2).toList();
    final direita = atalhos.skip(2).toList();

    Widget item(AtalhoRapido atalho) {
      return _NavItem(
        icon: atalho.icone,
        label: atalho.rotulo,
        active: current == atalho.rota,
        onTap: () => _abrir(context, atalho.rota),
      );
    }

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final atalho in esquerda) item(atalho),
          const SizedBox(width: 40),
          for (final atalho in direita) item(atalho),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.navBar : AppColors.grey;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
