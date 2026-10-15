import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/providers/fechamento_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/fechamento_resumo_card.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/repasse_funcionario_sheet.dart';

class FechamentoPage extends StatefulWidget {
  const FechamentoPage({super.key});

  static const route = AppRoutes.fechamento;

  @override
  State<FechamentoPage> createState() => _FechamentoPageState();
}

class _FechamentoPageState extends State<FechamentoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FechamentoProvider>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Fechamento'),
      body: Consumer<FechamentoProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _SeletorMes(provider: provider),
              Expanded(child: _Conteudo(provider: provider)),
            ],
          );
        },
      ),
    );
  }
}

class _SeletorMes extends StatelessWidget {
  final FechamentoProvider provider;

  const _SeletorMes({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Mês anterior',
            onPressed: provider.mesAnterior,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            nomeDoMes(provider.mes),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          IconButton(
            tooltip: 'Próximo mês',
            onPressed: provider.proximoMes,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final FechamentoProvider provider;

  const _Conteudo({required this.provider});

  @override
  Widget build(BuildContext context) {
    final fechamento = provider.fechamento;

    if (provider.carregando && fechamento == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.erro != null && fechamento == null) {
      return AppErrorMessage(
        mensagem: provider.erro!,
        onRetry: provider.carregar,
      );
    }

    if (fechamento == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: provider.carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FechamentoResumoCard(
            rotulo: 'Total recebido',
            valor: formatarMoeda(fechamento.totalRecebido),
            detalhe: _textoProducoes(fechamento),
          ),
          const SizedBox(height: 12),
          _CartaoRepasse(fechamento: fechamento),
          const SizedBox(height: 12),
          FechamentoResumoCard(
            rotulo: 'Lucro da empresa',
            valor: formatarMoeda(fechamento.lucro),
            cor: fechamento.lucro < 0 ? AppColors.danger : AppColors.success,
          ),
        ],
      ),
    );
  }

  String _textoProducoes(Fechamento fechamento) {
    final producoes = fechamento.quantidadeOperacoes;
    if (producoes == 0) return 'Nenhuma produção finalizada neste mês';
    return '$producoes ${producoes == 1 ? 'produção finalizada' : 'produções finalizadas'}'
        ' · ${fechamento.totalPecas} peças';
  }
}

class _CartaoRepasse extends StatefulWidget {
  final Fechamento fechamento;

  const _CartaoRepasse({required this.fechamento});

  @override
  State<_CartaoRepasse> createState() => _CartaoRepasseState();
}

class _CartaoRepasseState extends State<_CartaoRepasse> {
  bool _aberto = false;

  @override
  Widget build(BuildContext context) {
    return FechamentoResumoCard(
      rotulo: 'Total a repassar',
      valor: formatarMoeda(widget.fechamento.totalRepasse),
      cor: AppColors.warning,
      aberto: _aberto,
      onTap: () => setState(() => _aberto = !_aberto),
      conteudo: _ListaRepasses(repasses: widget.fechamento.repasses),
    );
  }
}

class _ListaRepasses extends StatelessWidget {
  final List<RepasseFuncionario> repasses;

  const _ListaRepasses({required this.repasses});

  @override
  Widget build(BuildContext context) {
    if (repasses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text(
          'Nenhum repasse neste mês',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    return Column(
      children: [
        for (final repasse in repasses)
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                repasse.funcionario,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${repasse.operacoes.length} ${repasse.operacoes.length == 1 ? 'produção' : 'produções'}',
              ),
              trailing: Text(
                formatarMoeda(repasse.total),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () => RepasseFuncionarioSheet.abrir(context, repasse),
            ),
          ),
      ],
    );
  }
}
