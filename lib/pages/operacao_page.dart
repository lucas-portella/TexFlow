import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/providers/operacao_detalhe_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/grade_table.dart';
import 'package:texflow/shared/operation_header.dart';
import 'package:texflow/shared/operation_progress_card.dart';
import 'package:texflow/shared/process_tile.dart';
import 'package:texflow/shared/section_title.dart';

class OperacaoPage extends StatelessWidget {
  const OperacaoPage({super.key});

  static const route = AppRoutes.operacaoDetalhes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Detalhes da produção'),
      body: Consumer<OperacaoDetalheProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.operacao == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.operacao == null) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.recarregar,
            );
          }

          final operacao = provider.operacao;
          if (operacao == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: provider.recarregar,
            child: _Conteudo(operacao: operacao),
          );
        },
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final Operacao operacao;

  const _Conteudo({required this.operacao});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OperationHeader(operacao: operacao),
        const SizedBox(height: 16),
        OperationProgressCard(operacao: operacao),
        const SizedBox(height: 24),
        const SectionTitle(texto: 'GRADE DE ROUPAS'),
        GradeTable(itens: operacao.gradePedido),
        const SizedBox(height: 24),
        const SectionTitle(texto: 'PROCESSOS PRODUTIVOS'),
        if (operacao.processos.isEmpty)
          const Text(
            'Nenhum processo cadastrado',
            style: TextStyle(color: AppColors.muted),
          ),
        for (final processo in operacao.processos)
          ProcessTile(processo: processo),
      ],
    );
  }
}
