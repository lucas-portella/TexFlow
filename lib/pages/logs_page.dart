import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/registro_log.dart';
import 'package:texflow/providers/logs_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/filtro_chip.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  static const route = AppRoutes.logs;

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogsProvider>().carregar();
    });
  }

  static String _dia(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  static String _diaCurto(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
  }

  String _rotuloDoPeriodo(LogsProvider provider) {
    if (provider.primeiroDia == provider.ultimoDia) {
      return _dia(provider.primeiroDia);
    }
    return '${_diaCurto(provider.primeiroDia)} a ${_diaCurto(provider.ultimoDia)}';
  }

  Future<void> _escolherPeriodo() async {
    final provider = context.read<LogsProvider>();

    final escolhido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: provider.primeiroDia,
        end: provider.ultimoDia,
      ),
      saveText: 'Aplicar',
    );

    if (escolhido == null) return;
    await provider.filtrarPeriodo(escolhido.start, escolhido.end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Logs'),
      body: Consumer<LogsProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _Filtros(
                provider: provider,
                rotuloDoPeriodo: _rotuloDoPeriodo(provider),
                aoEscolherPeriodo: _escolherPeriodo,
              ),
              Expanded(child: _Lista(provider: provider)),
            ],
          );
        },
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  final LogsProvider provider;
  final String rotuloDoPeriodo;
  final VoidCallback aoEscolherPeriodo;

  const _Filtros({
    required this.provider,
    required this.rotuloDoPeriodo,
    required this.aoEscolherPeriodo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FiltroChip(
              icone: Icons.calendar_today_outlined,
              rotulo: 'Hoje',
              valor: provider.periodoEhHoje ? null : rotuloDoPeriodo,
              onTap: aoEscolherPeriodo,
              onLimpar: provider.periodoEhHoje ? null : provider.voltarParaHoje,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: provider.tipo == null,
                  onSelected: (_) => provider.filtrarTipo(null),
                ),
                for (final tipo in TipoLog.values)
                  ChoiceChip(
                    avatar: Icon(tipo.icone, size: 16, color: tipo.cor),
                    label: Text(tipo.rotulo),
                    selected: provider.tipo == tipo,
                    onSelected: (_) => provider.filtrarTipo(tipo),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  final LogsProvider provider;

  const _Lista({required this.provider});

  static String _tituloDoDia(DateTime dia) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final texto =
        '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}/${dia.year}';

    if (dia == hoje) return 'HOJE · $texto';
    if (dia == hoje.subtract(const Duration(days: 1))) return 'ONTEM · $texto';
    return texto;
  }

  @override
  Widget build(BuildContext context) {
    if (provider.carregando && provider.logs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.erro != null && provider.logs.isEmpty) {
      return AppErrorMessage(
        mensagem: provider.erro!,
        onRetry: provider.carregar,
      );
    }

    if (provider.logs.isEmpty) {
      return const Center(child: Text('Nenhum registro neste período'));
    }

    final itens = <Widget>[];
    DateTime? diaAtual;

    for (final log in provider.logs) {
      if (log.dia != diaAtual) {
        diaAtual = log.dia;
        itens.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              _tituloDoDia(log.dia),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.muted,
              ),
            ),
          ),
        );
      }
      itens.add(_ItemDoLog(log: log));
    }

    return RefreshIndicator(
      onRefresh: provider.carregar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${provider.logs.length} ${provider.logs.length == 1 ? 'registro' : 'registros'}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          ...itens,
        ],
      ),
    );
  }
}

class _ItemDoLog extends StatelessWidget {
  final RegistroLog log;

  const _ItemDoLog({required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: log.tipo.cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(log.tipo.icone, size: 18, color: log.tipo.cor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.frase,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${log.tipo.rotulo} · ${log.area} · ${log.hora}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
