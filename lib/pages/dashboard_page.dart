import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/providers/minha_empresa_provider.dart';
import 'package:texflow/providers/operacao_provider.dart';
import 'package:texflow/providers/preferencias_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_bottom_nav.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_drawer.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/app_gretting.dart';
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
      context.read<PreferenciasProvider>().carregar();
      context.read<MinhaEmpresaProvider>().carregar();
      context.read<UsuarioProvider>().atualizarPerfil();
    });
  }

  Future<void> _novoPedido() async {
    final provider = context.read<OperacaoProvider>();
    await Navigator.pushNamed(context, AppRoutes.novoPedido);
    provider.carregar();
  }

  List<Operacao> _emAndamento(List<Operacao> operacoes) {
    return operacoes
        .where(
          (operacao) =>
              operacao.status == Status.emAndamento ||
              operacao.status == Status.naoIniciado,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Consumer<OperacaoProvider>(
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

            final emAndamento = _emAndamento(provider.operacoes);

            return RefreshIndicator(
              onRefresh: provider.carregar,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Consumer<UsuarioProvider>(
                    builder: (context, usuarioProvider, child) {
                      return AppGretting(
                        usuario: usuarioProvider.usuario,
                        onMenu: () => Scaffold.of(context).openDrawer(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: StatCard(
                          valor: provider.quantidadePorStatus(
                            Status.emAndamento,
                          ),
                          rotulo: 'Em produção',
                          cor: AppColors.primary,
                        ),
                      ),
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
                    spacing: 12,
                    children: [
                      Expanded(
                        child: StatCard(
                          valor: provider.quantidadePorStatus(Status.cancelado),
                          rotulo: 'Cancelado',
                          cor: AppColors.danger,
                        ),
                      ),
                      Expanded(
                        child: StatCard(
                          valor: provider.quantidadePorStatus(
                            Status.naoIniciado,
                          ),
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
                        'EM ANDAMENTO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.pesquisa),
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
                  if (emAndamento.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Nenhuma produção em andamento'),
                      ),
                    ),
                  for (final operacao in emAndamento) ...[
                    ProductionCard(operacao: operacao),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppRoutes.dashboard),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        shape: const CircleBorder(),
        onPressed: _novoPedido,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
