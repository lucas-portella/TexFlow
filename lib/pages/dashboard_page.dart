import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Bom dia,',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Text(
                  'Ana Carvalho',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 6),
                Text('👋', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Quinta-feira, 14 de março de 2024',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '1',
                    label: 'Em produção',
                    color: const Color(0xFF4C5FE0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '1',
                    label: 'Concluídos',
                    color: const Color(0xFF2CB88A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '1',
                    label: 'Aguardando',
                    color: const Color(0xFFE0A23C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '1',
                    label: 'Planejamento',
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PRODUÇÕES ATIVAS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Ver todas',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF4C5FE0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProductionCard(
              title: 'Moda Bella Confecções',
              code: 'PRD-2024-089',
              date: '14 de abr. de 2024',
              pieces: '150 peças',
              ref: 'Ref. MOD-FEM-045',
              status: 'Em produção',
              statusColor: const Color(0xFF4C5FE0),
              progress: 0.62,
              progressText: '62% concluído',
            ),
            const SizedBox(height: 12),
            _ProductionCard(
              title: 'Vestuário Nobre SA',
              code: 'PRD-2024-090',
              date: '21 de abr. de 2024',
              pieces: '170 peças',
              ref: 'Ref. MOD-MASC-018',
              status: 'Aguardando',
              statusColor: const Color(0xFFE0A23C),
              progress: 0.15,
              progressText: '15% concluído',
            ),
            const SizedBox(height: 12),
            _ProductionCard(
              title: 'Baby Chic Infantil',
              code: 'PRD-2024-091',
              date: '',
              pieces: '',
              ref: '',
              status: 'Concluído',
              statusColor: const Color(0xFF2CB88A),
              progress: null,
              progressText: '',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _NavItem(icon: Icons.home_filled, label: 'Início', active: true),
            _NavItem(icon: Icons.search, label: 'Pesquisa', active: false),
            SizedBox(width: 40),
            _NavItem(
              icon: Icons.settings_outlined,
              label: 'Config.',
              active: false,
            ),
            _NavItem(
              icon: Icons.business_outlined,
              label: 'Empresa',
              active: false,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E2340),
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProductionCard extends StatelessWidget {
  final String title;
  final String code;
  final String date;
  final String pieces;
  final String ref;
  final String status;
  final Color statusColor;
  final double? progress;
  final String progressText;

  const _ProductionCard({
    required this.title,
    required this.code,
    required this.date,
    required this.pieces,
    required this.ref,
    required this.status,
    required this.statusColor,
    required this.progress,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(code, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          if (date.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(width: 6),
                const Text('·', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 6),
                Text(
                  pieces,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFEDEEF3),
                color: statusColor,
              ),
            ),
          ],
          if (ref.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ref,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  progressText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1E2340) : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}
