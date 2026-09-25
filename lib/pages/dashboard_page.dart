import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/pages/search_page.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/services/operacao_service.dart';
import 'package:texflow/shared/app_bottom_nav.dart';
import 'package:texflow/shared/production_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Operacao>> _operacoesFuture;

  @override
  void initState() {
    super.initState();
    _operacoesFuture = OperacaoService.listar();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UsuarioProvider>().usuario;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: FutureBuilder<List<Operacao>>(
          future: _operacoesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
            }

            final operacoes = snapshot.data ?? [];
            final planejamento = operacoes
                .where((o) => o.status == Status.naoIniciado)
                .length;
            final emProducao = operacoes
                .where((o) => o.status == Status.emAndamento)
                .length;
            final concluidos = operacoes
                .where((o) => o.status == Status.concluido)
                .length;
            final cancelados = operacoes
                .where((o) => o.status == Status.cancelado)
                .length;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Bom dia,',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                Text(
                  usuario?.nome ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '$emProducao',
                        label: 'Em produção',
                        color: const Color(0xFF4C5FE0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '$concluidos',
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
                        value: '$cancelados',
                        label: 'Cancelado',
                        color: const Color(0xFFE0524A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '$planejamento',
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Ver todas',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4C5FE0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (operacoes.isEmpty) const Text('Nenhuma operação cadastrada'),
                for (final operacao in operacoes) ...[
                  ProductionCard(operacao: operacao),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: 'inicio'),
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
