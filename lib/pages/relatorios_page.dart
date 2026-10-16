import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/relatorio.dart';
import 'package:texflow/providers/relatorios_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/filtro_chip.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/metrica_card.dart';
import 'package:texflow/shared/section_title.dart';
import 'package:texflow/shared/variacao_chip.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  static const route = AppRoutes.relatorios;

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RelatoriosProvider>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        appBar: const ApplicationAppBar(title: 'Relatórios'),
        body: Consumer<RelatoriosProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _Cabecalho(provider: provider),
                Expanded(child: _Conteudo(provider: provider)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final RelatoriosProvider provider;

  const _Cabecalho({required this.provider});

  String get _rotuloDoPeriodo {
    String dia(DateTime data) =>
        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

    if (provider.inicio == provider.fim) return dia(provider.inicio);
    return '${dia(provider.inicio)} a ${dia(provider.fim)}';
  }

  String? get _textoDaComparacao {
    final periodo = provider.empresa?.periodo ?? provider.funcionarios?.periodo;
    if (periodo == null || periodo.inicio.isEmpty) return null;

    final dias = periodo.dias == 1 ? '1 dia' : '${periodo.dias} dias';
    return '$dias · comparado com ${formatarData(periodo.anteriorInicio)} a ${formatarData(periodo.anteriorFim)}';
  }

  Future<void> _escolherPeriodo(BuildContext context) async {
    final escolhido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: provider.inicio,
        end: provider.fim,
      ),
      saveText: 'Aplicar',
    );

    if (escolhido == null) return;
    await provider.filtrarPeriodo(escolhido.start, escolhido.end);
  }

  @override
  Widget build(BuildContext context) {
    final texto = _textoDaComparacao;

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FiltroChip(
            icone: Icons.calendar_today_outlined,
            rotulo: 'Escolher período',
            valor: _rotuloDoPeriodo,
            onTap: () => _escolherPeriodo(context),
            onLimpar: provider.periodoEhPadrao
                ? null
                : provider.voltarParaPadrao,
          ),
          if (texto != null) ...[
            const SizedBox(height: 8),
            Text(
              texto,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 4),
          const TabBar(
            labelColor: AppColors.ink,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Funcionários'),
              Tab(text: 'Empresa'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final RelatoriosProvider provider;

  const _Conteudo({required this.provider});

  @override
  Widget build(BuildContext context) {
    final empresa = provider.empresa;
    final funcionarios = provider.funcionarios;

    if (provider.carregando && empresa == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.erro != null && empresa == null) {
      return AppErrorMessage(
        mensagem: provider.erro!,
        onRetry: provider.carregar,
      );
    }

    if (empresa == null || funcionarios == null) {
      return const SizedBox.shrink();
    }

    return TabBarView(
      children: [
        RefreshIndicator(
          onRefresh: provider.carregar,
          child: _AbaFuncionarios(relatorio: funcionarios),
        ),
        RefreshIndicator(
          onRefresh: provider.carregar,
          child: _AbaEmpresa(relatorio: empresa),
        ),
      ],
    );
  }
}

class _AbaFuncionarios extends StatelessWidget {
  final RelatorioFuncionarios relatorio;

  const _AbaFuncionarios({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    final unidade = relatorio.periodo.unidadeMedia;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MetricaCard(
          rotulo: 'Total de peças',
          mostrarMedia: false,
          metrica: relatorio.totalPecas,
          unidadeMedia: unidade,
          dinheiro: false,
        ),
        const SizedBox(height: 12),
        MetricaCard(
          rotulo: 'Total de repasses',
          mostrarMedia: false,
          metrica: relatorio.totalRepasse,
          unidadeMedia: unidade,
          maisEhBom: null,
          cor: AppColors.warning,
        ),
        const SizedBox(height: 20),
        const SectionTitle(texto: 'POR FUNCIONÁRIO'),
        if (relatorio.funcionarios.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(
              child: Text('Nenhuma produção finalizada neste período'),
            ),
          ),
        for (final linha in relatorio.funcionarios)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CartaoDoFuncionario(linha: linha, unidade: unidade),
          ),
      ],
    );
  }
}

class _CartaoDoFuncionario extends StatelessWidget {
  final LinhaFuncionarioRelatorio linha;
  final String unidade;

  const _CartaoDoFuncionario({required this.linha, required this.unidade});

  Widget _dado(String rotulo, String valor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      linha.funcionario,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    if (linha.etapaPrincipal != null)
                      Text(
                        'Mais faz: ${linha.etapaPrincipal}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              VariacaoChip(variacao: linha.pecas.variacaoPercentual),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${formatarInteiro(linha.pecas.atual)} peças',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          Text(
            'Média por $unidade: ${formatarNumero(linha.pecas.mediaAtual)} peças',
            style: const TextStyle(fontSize: 12, color: AppColors.ink),
          ),
          Text(
            'Comparado ao período anterior: ${formatarInteiro(linha.pecas.anterior)} peças',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _dado('Produções', formatarInteiro(linha.producoes.atual)),
              _dado('Repasse', formatarMoeda(linha.repasse.atual)),
              _dado('Por peça', formatarMoeda(linha.valorMedioPorPeca)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AbaEmpresa extends StatelessWidget {
  final RelatorioEmpresa relatorio;

  const _AbaEmpresa({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    final unidade = relatorio.periodo.unidadeMedia;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MetricaCard(
          rotulo: 'Média de faturamento',
          metrica: relatorio.faturamento,
          unidadeMedia: unidade,
          cor: AppColors.success,
        ),
        const SizedBox(height: 12),
        MetricaCard(
          rotulo: 'Faturamento do ano até agora',
          mostrarMedia: false,
          metrica: relatorio.faturamentoDoAno,
          unidadeMedia: 'mês',
        ),
        const SizedBox(height: 12),
        MetricaCard(
          rotulo: 'Média de repasses aos funcionários',
          metrica: relatorio.repasses,
          unidadeMedia: unidade,
          maisEhBom: false,
          cor: AppColors.warning,
        ),
        if (relatorio.custosIncluidos) ...[
          const SizedBox(height: 12),
          MetricaCard(
            rotulo: 'Média de despesas (custos)',
            metrica: relatorio.despesas,
            unidadeMedia: unidade,
            maisEhBom: false,
            cor: AppColors.danger,
          ),
        ],
        const SizedBox(height: 12),
        MetricaCard(
          rotulo: 'Média de lucro',
          metrica: relatorio.lucro,
          unidadeMedia: unidade,
          cor: relatorio.lucro.atual < 0 ? AppColors.danger : AppColors.success,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: MetricaCard(
                rotulo: 'Produções',
                metrica: relatorio.producoes,
                unidadeMedia: unidade,
                dinheiro: false,
                mostrarMedia: false,
              ),
            ),
            Expanded(
              child: MetricaCard(
                rotulo: 'Peças',
                metrica: relatorio.pecas,
                unidadeMedia: unidade,
                dinheiro: false,
                mostrarMedia: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionTitle(texto: 'REPASSES POR TIPO DE ETAPA'),
        if (relatorio.repassesPorEtapa.isEmpty)
          const _SemDados()
        else
          AppCard(
            child: Column(
              children: [
                for (final linha in relatorio.repassesPorEtapa)
                  _LinhaDeValor(
                    titulo: linha.etapa,
                    metrica: linha.valor,
                    unidade: unidade,
                  ),
              ],
            ),
          ),
        if (relatorio.custosIncluidos) ...[
          const SizedBox(height: 20),
          const SectionTitle(texto: 'DESPESAS POR CATEGORIA'),
          if (relatorio.despesasPorCategoria.isEmpty)
            const _SemDados()
          else
            AppCard(
              child: Column(
                children: [
                  for (final linha in relatorio.despesasPorCategoria)
                    _LinhaDeValor(
                      titulo: linha.categoria.rotulo,
                      metrica: linha.valor,
                      unidade: unidade,
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _SemDados extends StatelessWidget {
  const _SemDados();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'Nenhum valor neste período',
        style: TextStyle(color: AppColors.muted),
      ),
    );
  }
}

class _LinhaDeValor extends StatelessWidget {
  final String titulo;
  final Metrica metrica;
  final String unidade;

  const _LinhaDeValor({
    required this.titulo,
    required this.metrica,
    required this.unidade,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Média do período anterior: ${formatarMoeda(metrica.mediaAnterior)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatarMoeda(metrica.mediaAtual),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              VariacaoChip(
                variacao: metrica.variacaoPercentual,
                maisEhBom: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
