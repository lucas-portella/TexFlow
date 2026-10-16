import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/filtro_operacoes.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/providers/operacao_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/app_main_scaffold.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/filtro_chip.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/opcoes_filtro_sheet.dart';
import 'package:texflow/shared/periodo_filtro_sheet.dart';
import 'package:texflow/shared/production_card.dart';
import 'package:texflow/shared/status_helpers.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const route = AppRoutes.pesquisa;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _buscaController = TextEditingController();
  FiltroOperacoes _filtro = const FiltroOperacoes();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperacaoProvider>().carregar();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Referencia> _modelosDisponiveis(List<Operacao> operacoes) {
    final modelos = <int, Referencia>{};
    for (final operacao in operacoes) {
      final modelo = operacao.referencia;
      if (modelo != null) modelos[modelo.id] = modelo;
    }
    return modelos.values.toList()..sort((a, b) => a.nome.compareTo(b.nome));
  }

  List<Empresa> _clientesDisponiveis(List<Operacao> operacoes) {
    final clientes = <int, Empresa>{};
    for (final operacao in operacoes) {
      final cliente = operacao.cliente;
      if (cliente != null) clientes[cliente.id] = cliente;
    }
    return clientes.values.toList()
      ..sort((a, b) => a.nomeFantasia.compareTo(b.nomeFantasia));
  }

  Future<void> _escolherStatus() async {
    final resultado = await abrirOpcoesDeFiltro<Status>(
      context,
      titulo: 'Status',
      selecionado: _filtro.status,
      opcoes: [
        for (final status in Status.values)
          OpcaoFiltro(
            rotulo: statusLabel(status),
            valor: status,
            icone: Icon(Icons.circle, size: 12, color: statusColor(status)),
          ),
      ],
    );
    if (resultado == null) return;
    setState(() {
      _filtro = resultado.valor == null
          ? _filtro.copiarCom(limparStatus: true)
          : _filtro.copiarCom(status: resultado.valor);
    });
  }

  Future<void> _escolherPeriodo() async {
    final resultado = await abrirFiltroDePeriodo(
      context,
      selecionado: _filtro.mes,
    );
    if (resultado == null) return;
    setState(() {
      _filtro = resultado.valor == null
          ? _filtro.copiarCom(limparMes: true)
          : _filtro.copiarCom(mes: resultado.valor);
    });
  }

  Future<void> _escolherModelo(List<Operacao> operacoes) async {
    final resultado = await abrirOpcoesDeFiltro<int>(
      context,
      titulo: 'Modelo',
      textoTodos: 'Todos os modelos',
      selecionado: _filtro.modeloId,
      opcoes: [
        for (final modelo in _modelosDisponiveis(operacoes))
          OpcaoFiltro(rotulo: modelo.nome, valor: modelo.id),
      ],
    );
    if (resultado == null) return;
    setState(() {
      _filtro = resultado.valor == null
          ? _filtro.copiarCom(limparModelo: true)
          : _filtro.copiarCom(modeloId: resultado.valor);
    });
  }

  Future<void> _escolherCliente(List<Operacao> operacoes) async {
    final resultado = await abrirOpcoesDeFiltro<int>(
      context,
      titulo: 'Cliente',
      textoTodos: 'Todos os clientes',
      selecionado: _filtro.clienteId,
      opcoes: [
        for (final cliente in _clientesDisponiveis(operacoes))
          OpcaoFiltro(rotulo: cliente.nomeFantasia, valor: cliente.id),
      ],
    );
    if (resultado == null) return;
    setState(() {
      _filtro = resultado.valor == null
          ? _filtro.copiarCom(limparCliente: true)
          : _filtro.copiarCom(clienteId: resultado.valor);
    });
  }

  void _limparTudo() {
    _buscaController.clear();
    setState(() => _filtro = const FiltroOperacoes());
  }

  String? _nomeDoModelo(List<Operacao> operacoes) {
    if (_filtro.modeloId == null) return null;
    for (final modelo in _modelosDisponiveis(operacoes)) {
      if (modelo.id == _filtro.modeloId) return modelo.nome;
    }
    return 'Modelo';
  }

  String? _nomeDoCliente(List<Operacao> operacoes) {
    if (_filtro.clienteId == null) return null;
    for (final cliente in _clientesDisponiveis(operacoes)) {
      if (cliente.id == _filtro.clienteId) return cliente.nomeFantasia;
    }
    return 'Cliente';
  }

  @override
  Widget build(BuildContext context) {
    return AppMainScaffold(
      current: SearchPage.route,
      body: Consumer<OperacaoProvider>(
        builder: (context, provider, child) {
          final operacoes = provider.operacoes;
          final resultado = _filtro.aplicar(operacoes);

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pesquisar',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _buscaController,
                  onChanged: (valor) =>
                      setState(() => _filtro = _filtro.copiarCom(texto: valor)),
                  decoration: appFieldDecoration(
                    hintText: 'Cliente, modelo ou número do pedido',
                    prefixIcon: Icons.search,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FiltroChip(
                        icone: Icons.flag_outlined,
                        rotulo: 'Status',
                        valor: _filtro.status == null
                            ? null
                            : statusLabel(_filtro.status!),
                        onTap: _escolherStatus,
                        onLimpar: () => setState(
                          () => _filtro = _filtro.copiarCom(limparStatus: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FiltroChip(
                        icone: Icons.calendar_month_outlined,
                        rotulo: 'Período',
                        valor: _filtro.mes == null
                            ? null
                            : nomeDoMes(_filtro.mes!),
                        onTap: _escolherPeriodo,
                        onLimpar: () => setState(
                          () => _filtro = _filtro.copiarCom(limparMes: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FiltroChip(
                        icone: Icons.checkroom_outlined,
                        rotulo: 'Modelo',
                        valor: _nomeDoModelo(operacoes),
                        onTap: () => _escolherModelo(operacoes),
                        onLimpar: () => setState(
                          () => _filtro = _filtro.copiarCom(limparModelo: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FiltroChip(
                        icone: Icons.business_outlined,
                        rotulo: 'Cliente',
                        valor: _nomeDoCliente(operacoes),
                        onTap: () => _escolherCliente(operacoes),
                        onLimpar: () => setState(
                          () =>
                              _filtro = _filtro.copiarCom(limparCliente: true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${resultado.length} ${resultado.length == 1 ? 'produção' : 'produções'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    if (_filtro.temFiltro)
                      TextButton(
                        onPressed: _limparTudo,
                        child: const Text('Limpar filtros'),
                      ),
                  ],
                ),
                Expanded(child: _lista(provider, resultado)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _lista(OperacaoProvider provider, List<Operacao> resultado) {
    if (provider.carregando && provider.operacoes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.erro != null && provider.operacoes.isEmpty) {
      return AppErrorMessage(
        mensagem: provider.erro!,
        onRetry: provider.carregar,
      );
    }

    if (resultado.isEmpty) {
      return const Center(child: Text('Nenhuma produção encontrada'));
    }

    return RefreshIndicator(
      onRefresh: provider.carregar,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 4, bottom: 96),
        itemCount: resultado.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            ProductionCard(operacao: resultado[index]),
      ),
    );
  }
}
