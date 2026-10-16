import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/custo.dart';
import 'package:texflow/providers/custo_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/cadastro_item_tile.dart';
import 'package:texflow/shared/confirmar_exclusao.dart';
import 'package:texflow/shared/custo_form_sheet.dart';
import 'package:texflow/shared/fechamento_resumo_card.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/section_title.dart';

class CustosPage extends StatefulWidget {
  const CustosPage({super.key});

  static const route = AppRoutes.custos;

  @override
  State<CustosPage> createState() => _CustosPageState();
}

class _CustosPageState extends State<CustosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustoProvider>().carregar();
    });
  }

  Future<void> _excluir(Custo custo) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<CustoProvider>();

    if (!await confirmarExclusao(context, custo.descricao)) return;

    try {
      await provider.excluir(custo.id);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Custos'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.white,
        onPressed: () => CustoFormSheet.abrir(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<CustoProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _SeletorMes(provider: provider),
              Expanded(
                child: _Conteudo(provider: provider, aoExcluir: _excluir),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SeletorMes extends StatelessWidget {
  final CustoProvider provider;

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
  final CustoProvider provider;
  final Future<void> Function(Custo) aoExcluir;

  const _Conteudo({required this.provider, required this.aoExcluir});

  String _periodicidade(Custo custo) {
    if (!custo.recorrente) return 'em ${formatarData(custo.data)}';

    final partes = <String>[
      custo.intervaloDias == 1
          ? 'todo dia'
          : 'a cada ${custo.intervaloDias} dias',
      if (custo.ocorrenciasNoMes > 1) '${custo.ocorrenciasNoMes}x no mês',
      if (custo.dataFim != null) 'até ${formatarData(custo.dataFim)}',
    ];
    return partes.join(' · ');
  }

  Widget _tile(BuildContext context, Custo custo, {required bool doMes}) {
    return CadastroItemTile(
      titulo: custo.descricao,
      subtitulo: '${custo.categoria.rotulo} · ${_periodicidade(custo)}',
      selo: Text(
        doMes
            ? formatarMoeda(custo.totalNoMes)
            : '${formatarMoeda(custo.valor)} / vez',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: doMes ? AppColors.danger : AppColors.muted,
        ),
      ),
      onTap: () => CustoFormSheet.abrir(context, custo: custo),
      onExcluir: () => aoExcluir(custo),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (provider.carregando && provider.custos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.erro != null && provider.custos.isEmpty) {
      return AppErrorMessage(
        mensagem: provider.erro!,
        onRetry: provider.carregar,
      );
    }

    final doMes = provider.doMes;
    final foraDoMes = provider.foraDoMes;

    return RefreshIndicator(
      onRefresh: provider.carregar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          FechamentoResumoCard(
            rotulo: 'Custos do mês',
            valor: formatarMoeda(provider.totalDoMes),
            cor: AppColors.danger,
            detalhe: doMes.isEmpty
                ? 'Nenhum custo neste mês'
                : '${doMes.length} ${doMes.length == 1 ? 'lançamento' : 'lançamentos'}',
          ),
          const SizedBox(height: 20),
          if (provider.custos.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: Text('Nenhum custo cadastrado')),
            ),
          if (doMes.isNotEmpty) ...[
            const SectionTitle(texto: 'NESTE MÊS'),
            for (final custo in doMes) _tile(context, custo, doMes: true),
          ],
          if (foraDoMes.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionTitle(texto: 'OUTROS LANÇAMENTOS'),
            for (final custo in foraDoMes) _tile(context, custo, doMes: false),
          ],
        ],
      ),
    );
  }
}
