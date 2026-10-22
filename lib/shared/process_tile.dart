import 'package:flutter/material.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/cor_quadradinho.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/status_badge.dart';
import 'package:texflow/shared/status_helpers.dart';

class ProcessTile extends StatelessWidget {
  final ProcessoProdutivo processo;
  final bool mostrarStatus;
  final bool selecionavel;
  final bool selecionado;
  final VoidCallback? onTap;
  final void Function(Funcionario pessoa)? aoInformarPessoa;
  final VoidCallback? aoAdicionarResponsavel;

  const ProcessTile({
    super.key,
    required this.processo,
    this.mostrarStatus = true,
    this.selecionavel = false,
    this.selecionado = false,
    this.onTap,
    this.aoInformarPessoa,
    this.aoAdicionarResponsavel,
  });

  IconData _icone(Status status) {
    switch (status) {
      case Status.concluido:
        return Icons.check;
      case Status.cancelado:
        return Icons.close;
      case Status.emAndamento:
      case Status.naoIniciado:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = processo.status ?? Status.naoIniciado;
    final cor = mostrarStatus ? statusColor(status) : AppColors.muted;
    final marcavel = selecionavel && status != Status.concluido;
    final valor = processo.valorComissao;
    final responsaveis = processo.funcionarios;
    final recuo = marcavel
        ? 38.0
        : mostrarStatus
        ? 54.0
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (marcavel)
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Icon(
                        selecionado
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: selecionado
                            ? AppColors.primary
                            : AppColors.muted,
                      ),
                    )
                  else if (mostrarStatus)
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_icone(status), size: 18, color: cor),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          processo.descricao,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        if (valor != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            formatarMoeda(valor),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                        if (responsaveis.isEmpty &&
                            aoAdicionarResponsavel == null) ...[
                          const SizedBox(height: 4),
                          Text(
                            processo.empresaResponsavel?.nomeFantasia ??
                                'Sem responsável',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (mostrarStatus) StatusBadge(status: status),
                ],
              ),
              if (responsaveis.isNotEmpty) ...[
                const SizedBox(height: 6),
                for (final pessoa in responsaveis)
                  Padding(
                    padding: EdgeInsets.only(left: recuo),
                    child: _LinhaDoResponsavel(
                      processo: processo,
                      pessoa: pessoa,
                      aoInformar: aoInformarPessoa == null
                          ? null
                          : () => aoInformarPessoa!(pessoa),
                    ),
                  ),
              ],
              if (aoAdicionarResponsavel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: aoAdicionarResponsavel,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.person_add_alt, size: 18),
                      label: const Text(
                        'Adicionar responsável',
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinhaDoResponsavel extends StatelessWidget {
  final ProcessoProdutivo processo;
  final Funcionario pessoa;
  final VoidCallback? aoInformar;

  const _LinhaDoResponsavel({
    required this.processo,
    required this.pessoa,
    required this.aoInformar,
  });

  String _pecas(int? quantidade) {
    if (quantidade == null) return 'sem peças';
    return '${formatarInteiro(quantidade.toDouble())} peças';
  }

  @override
  Widget build(BuildContext context) {
    final linhas = processo.linhasDe(pessoa.id);
    final simples =
        !processo.permiteCores &&
        (linhas.isEmpty ||
            (linhas.length == 1 && linhas.first.tamanho == null));

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pessoa.nome,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                if (simples)
                  Text(
                    _pecas(processo.pecasDe(pessoa.id)),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  )
                else
                  for (final linha in linhas)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (linha.cor != null) ...[
                                CorQuadradinho(cor: linha.cor!, tamanho: 14),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  [
                                        ?linha.cor?.nome,
                                        ?linha.tamanho?.nome,
                                      ].isEmpty
                                      ? 'Sem tamanho'
                                      : [
                                          ?linha.cor?.nome,
                                          ?linha.tamanho?.nome,
                                        ].join(' · '),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _pecas(linha.quantidade),
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
          if (aoInformar != null)
            IconButton(
              tooltip: 'Peças de ${pessoa.nome}',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: aoInformar,
              icon: const Icon(Icons.edit_note, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
