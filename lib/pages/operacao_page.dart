import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/modo_operacao.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/providers/operacao_detalhe_provider.dart';
import 'package:texflow/providers/preferencias_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/adicionar_etapa_sheet.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/confirmar_exclusao.dart';
import 'package:texflow/shared/finalizar_producao_dialog.dart';
import 'package:texflow/shared/grade_table.dart';
import 'package:texflow/shared/operation_header.dart';
import 'package:texflow/shared/operation_progress_card.dart';
import 'package:texflow/shared/process_tile.dart';
import 'package:texflow/shared/dados_do_responsavel_sheet.dart';
import 'package:texflow/shared/quantidades_pendentes_dialog.dart';
import 'package:texflow/shared/section_title.dart';
import 'package:texflow/shared/status_da_operacao_field.dart';

class OperacaoPage extends StatefulWidget {
  const OperacaoPage({super.key});

  static const route = AppRoutes.operacaoDetalhes;

  @override
  State<OperacaoPage> createState() => _OperacaoPageState();
}

class _OperacaoPageState extends State<OperacaoPage> {
  final Set<int> _selecionadas = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PreferenciasProvider>().carregar();
    });
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem.replaceFirst('Exception: ', ''))),
    );
  }

  Future<void> _executar(
    Future<void> Function() acao, {
    String? sucesso,
  }) async {
    try {
      await acao();
      if (sucesso != null) _avisar(sucesso);
    } catch (e) {
      _avisar(e.toString());
    }
  }

  Future<void> _editar(
    OperacaoDetalheProvider provider,
    Operacao operacao,
  ) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.novoPedido,
      arguments: operacao,
    );
    if (mounted) await provider.recarregar();
  }

  Future<void> _excluir(
    OperacaoDetalheProvider provider,
    Operacao operacao,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (!await confirmarExclusao(context, operacao.codigo)) return;

    try {
      await provider.excluir();
      navigator.pop(true);
      messenger.showSnackBar(const SnackBar(content: Text('Pedido excluído')));
    } catch (e) {
      _avisar(e.toString());
    }
  }

  Future<void> _informarPessoa(
    OperacaoDetalheProvider provider,
    ProcessoProdutivo processo,
    Funcionario pessoa,
  ) async {
    final id = processo.idProcessoProdutivo;
    if (id == null) return;

    final linhas = await pedirDadosDoResponsavel(context, processo, pessoa);
    if (linhas == null) return;

    await _executar(
      () => provider.informarLinhas(id, pessoa.id, linhas),
      sucesso: 'Peças salvas',
    );
  }

  Future<void> _finalizar(
    OperacaoDetalheProvider provider,
    Operacao operacao,
  ) async {
    final pendencias = operacao.pendenciasDeQuantidade;
    if (pendencias.isNotEmpty) {
      await avisarQuantidadesPendentes(context, pendencias: pendencias);
      return;
    }

    final dados = await pedirDadosDaFinalizacao(
      context,
      sugestao: operacao.quantidadeSolicitada,
    );
    if (dados == null) return;

    await _executar(
      () => provider.finalizar(dados.quantidade, dados.dataEntrega),
      sucesso: 'Produção finalizada',
    );
  }

  Future<void> _escolherStatus(
    OperacaoDetalheProvider provider,
    Operacao operacao,
    Status status,
  ) async {
    if (status == Status.concluido) {
      await _finalizar(provider, operacao);
      return;
    }

    await _executar(() => provider.alterarStatus(status));
  }

  bool _podeInformarQuantidades(bool editavel, ProcessoProdutivo processo) {
    return editavel &&
        processo.idProcessoProdutivo != null &&
        processo.funcionarios.isNotEmpty;
  }

  void _alternarSelecao(ProcessoProdutivo processo) {
    final id = processo.idProcessoProdutivo;
    if (id == null) return;

    setState(() {
      if (!_selecionadas.remove(id)) _selecionadas.add(id);
    });
  }

  Future<void> _concluirSelecionadas(OperacaoDetalheProvider provider) async {
    final ids = _selecionadas.toList();
    setState(_selecionadas.clear);

    await _executar(() => provider.atualizarEtapas(ids, Status.concluido));
  }

  Future<void> _reabrir(
    OperacaoDetalheProvider provider,
    ProcessoProdutivo processo,
  ) async {
    final id = processo.idProcessoProdutivo;
    if (id == null) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reabrir etapa'),
        content: Text('Voltar "${processo.descricao}" para não iniciada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reabrir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await _executar(() => provider.atualizarEtapas([id], Status.naoIniciado));
  }

  @override
  Widget build(BuildContext context) {
    final modo = context.watch<PreferenciasProvider>().modoOperacao;
    final detalhe = context.watch<OperacaoDetalheProvider>();
    final aberta = detalhe.operacao;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: ApplicationAppBar(
        title: 'Detalhes da produção',
        actions: [
          if (aberta != null && aberta.editavel)
            IconButton(
              tooltip: 'Editar pedido',
              icon: const Icon(Icons.edit_outlined, color: AppColors.ink),
              onPressed: () => _editar(detalhe, aberta),
            ),
          if (aberta != null &&
              aberta.podeExcluir(porEtapas: modo == ModoOperacao.porEtapas))
            IconButton(
              tooltip: 'Excluir pedido',
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _excluir(detalhe, aberta),
            ),
          const SizedBox(width: 4),
        ],
      ),
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

          final editavel =
              !operacao.finalizada && operacao.status != Status.cancelado;
          final pendentes = operacao.processos
              .where((processo) => processo.status != Status.concluido)
              .map((processo) => processo.idProcessoProdutivo)
              .toSet();
          final selecionadas = _selecionadas.where(pendentes.contains).toSet();

          return RefreshIndicator(
            onRefresh: provider.recarregar,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                OperationHeader(operacao: operacao),
                const SizedBox(height: 16),
                if (modo == ModoOperacao.porStatus)
                  StatusDaOperacaoField(
                    status: operacao.status,
                    habilitado: editavel,
                    aoEscolher: (status) =>
                        _escolherStatus(provider, operacao, status),
                  )
                else
                  OperationProgressCard(operacao: operacao),
                const SizedBox(height: 24),
                const SectionTitle(texto: 'GRADE DE ROUPAS'),
                GradeTable(itens: operacao.gradePedido),
                const SizedBox(height: 24),
                SectionTitle(
                  texto: modo == ModoOperacao.porEtapas
                      ? 'ETAPAS'
                      : 'PROCESSOS PRODUTIVOS',
                ),
                if (operacao.processos.isEmpty)
                  const Text(
                    'Nenhum processo cadastrado',
                    style: TextStyle(color: AppColors.muted),
                  ),
                for (final processo in operacao.processos)
                  if (modo == ModoOperacao.porEtapas)
                    ProcessTile(
                      processo: processo,
                      aoInformarPessoa:
                          _podeInformarQuantidades(editavel, processo)
                          ? (pessoa) =>
                                _informarPessoa(provider, processo, pessoa)
                          : null,
                      selecionavel: editavel,
                      selecionado: selecionadas.contains(
                        processo.idProcessoProdutivo,
                      ),
                      onTap: !editavel
                          ? null
                          : processo.status == Status.concluido
                          ? () => _reabrir(provider, processo)
                          : processo.status == Status.cancelado
                          ? null
                          : () => _alternarSelecao(processo),
                    )
                  else
                    ProcessTile(
                      processo: processo,
                      mostrarStatus: false,
                      aoInformarPessoa:
                          _podeInformarQuantidades(editavel, processo)
                          ? (pessoa) =>
                                _informarPessoa(provider, processo, pessoa)
                          : null,
                    ),
                if (editavel) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => AdicionarEtapaSheet.abrir(
                        context,
                        descricoesExistentes: operacao.processos
                            .map((processo) => processo.descricao)
                            .toList(),
                        aoConfirmar: (dados) => provider.adicionarEtapa(
                          etapaId: dados.etapa?.id,
                          nome: dados.nome,
                          valorComissao: dados.valor,
                          funcionarioId: dados.funcionarios.isEmpty
                              ? null
                              : dados.funcionarios.first.id,
                          outrosFuncionarioIds: dados.funcionarios
                              .skip(1)
                              .map((item) => item.id)
                              .toList(),
                          permiteCores: dados.permiteCores,
                          linhas: dados.linhas,
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar etapa'),
                    ),
                  ),
                ],
                if (modo == ModoOperacao.porEtapas && editavel) ...[
                  const SizedBox(height: 12),
                  if (selecionadas.isNotEmpty) ...[
                    AppPrimaryButton(
                      label: selecionadas.length == 1
                          ? 'Concluir 1 etapa selecionada'
                          : 'Concluir ${selecionadas.length} etapas selecionadas',
                      onPressed: () => _concluirSelecionadas(provider),
                    ),
                    const SizedBox(height: 12),
                  ],
                  AppPrimaryButton(
                    label: 'Concluir operação',
                    onPressed: operacao.todasEtapasConcluidas
                        ? () => _finalizar(provider, operacao)
                        : null,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
