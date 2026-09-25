import 'package:flutter/material.dart';
import 'package:texflow/pages/dashboard_page.dart';
import 'package:texflow/pages/search_page.dart';

class AppBottomNav extends StatelessWidget {
  final String current;

  const AppBottomNav({super.key, required this.current});

  void _irPara(BuildContext context, String destino) {
    if (destino == current) return;

    final page = destino == 'inicio'
        ? const DashboardPage()
        : const SearchPage();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
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
            active: current == 'inicio',
            onTap: () => _irPara(context, 'inicio'),
          ),
          _NavItem(
            icon: Icons.search,
            label: 'Pesquisa',
            active: current == 'pesquisa',
            onTap: () => _irPara(context, 'pesquisa'),
          ),
          const SizedBox(width: 40),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Config.',
            active: false,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.business_outlined,
            label: 'Empresa',
            active: false,
            onTap: () {},
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
    final color = active ? const Color(0xFF1E2340) : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
