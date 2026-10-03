import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/providers/operacao_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/app_gretting.dart';
import 'package:texflow/shared/app_main_scaffold.dart';
import 'package:texflow/shared/production_card.dart';
import 'package:texflow/shared/stat_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const route = AppRoutes.dashboard;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperacaoProvider>().carregar();
    });
  }

  Future<void> _sair() async {
    await context.read<UsuarioProvider>().logout();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppMainScaffold(
      current: DashboardPage.route,
      body: Consumer<OperacaoProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.operacoes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.operacoes.isEmpty) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.carregar,
            );
          }

          final recentes = provider.operacoes.take(5).toList();

          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<UsuarioProvider>(
                      builder: (context, usuarioProvider, child) {
                        return AppGretting(usuario: usuarioProvider.usuario);
                      },
                    ),
                    IconButton(
                      onPressed: _sair,
                      icon: const Icon(Icons.logout, color: AppColors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        valor: provider.quantidadePorStatus(Status.emAndamento),
                        rotulo: 'Em produção',
                        cor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        valor: provider.quantidadePorStatus(Status.concluido),
                        rotulo: 'Concluídos',
                        cor: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        valor: provider.quantidadePorStatus(Status.cancelado),
                        rotulo: 'Cancelado',
                        cor: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        valor: provider.quantidadePorStatus(Status.naoIniciado),
                        rotulo: 'Planejamento',
                        cor: AppColors.purple,
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
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.pesquisa,
                        (route) => false,
                      ),
                      child: const Text(
                        'Ver todas',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (recentes.isEmpty)
                  const Text('Nenhuma produção cadastrada ainda'),
                for (final operacao in recentes) ...[
                  ProductionCard(operacao: operacao),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
