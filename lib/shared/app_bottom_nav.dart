import 'package:flutter/material.dart';
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
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_filled,
            label: 'Início',
            active: current == AppRoutes.dashboard,
            onTap: () => _abrir(context, AppRoutes.dashboard),
          ),
          _NavItem(
            icon: Icons.search,
            label: 'Pesquisa',
            active: current == AppRoutes.pesquisa,
            onTap: () => _abrir(context, AppRoutes.pesquisa),
          ),
          const SizedBox(width: 40),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Config.',
            active: current == AppRoutes.configuracoes,
            onTap: () => _abrir(context, AppRoutes.configuracoes),
          ),
          _NavItem(
            icon: Icons.business_outlined,
            label: 'Empresa',
            active: current == AppRoutes.novaEmpresa,
            onTap: () => _abrir(context, AppRoutes.novaEmpresa),
          ),
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
