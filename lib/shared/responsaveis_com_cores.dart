import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/cor.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/providers/cor_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/cor_form_sheet.dart';
import 'package:texflow/shared/cor_quadradinho.dart';
import 'package:texflow/shared/escolher_responsaveis_sheet.dart';
import 'package:texflow/shared/funcionario_form_sheet.dart';

class ResponsavelComCores {
  final Funcionario funcionario;
  final List<Cor> cores;

  const ResponsavelComCores({required this.funcionario, required this.cores});
}

Future<ResponsavelComCores?> escolherResponsavelECores(
  BuildContext context, {
  Funcionario? fixo,
  List<Cor> coresIniciais = const [],
  List<int> idsJaNaEtapa = const [],
}) {
  return showModalBottomSheet<ResponsavelComCores>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EscolherResponsavelECores(
      fixo: fixo,
      coresIniciais: coresIniciais,
      idsJaNaEtapa: idsJaNaEtapa,
    ),
  );
}

class _EscolherResponsavelECores extends StatefulWidget {
  final Funcionario? fixo;
  final List<Cor> coresIniciais;
  final List<int> idsJaNaEtapa;

  const _EscolherResponsavelECores({
    required this.fixo,
    required this.coresIniciais,
    required this.idsJaNaEtapa,
  });

  @override
  State<_EscolherResponsavelECores> createState() =>
      _EscolherResponsavelECoresState();
}

class _EscolherResponsavelECoresState
    extends State<_EscolherResponsavelECores> {
  late Funcionario? _funcionario = widget.fixo;
  late final Set<int> _ids = widget.coresIniciais.map((cor) => cor.id).toSet();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CorProvider>().carregar();
      context.read<FuncionarioProvider>().carregar();
    });
  }

  void _confirmar(List<Cor> todas) {
    final escolhidas = todas.where((cor) => _ids.contains(cor.id)).toList();
    Navigator.pop(
      context,
      ResponsavelComCores(funcionario: _funcionario!, cores: escolhidas),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.watch<CorProvider>().cores;
    final disponiveis = context
        .watch<FuncionarioProvider>()
        .ativos
        .where((item) => !widget.idsJaNaEtapa.contains(item.id))
        .toList();
    final pronto = _funcionario != null && _ids.isNotEmpty;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.fixo == null
                          ? 'Responsável e cores'
                          : 'Cores de ${widget.fixo!.nome}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.fixo == null)
                      if (disponiveis.isEmpty)
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Não há funcionários ativos.'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  FuncionarioFormSheet.abrir(context),
                              child: const Text('Cadastrar funcionário'),
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<int>(
                          initialValue:
                              disponiveis.any(
                                (item) => item.id == _funcionario?.id,
                              )
                              ? _funcionario?.id
                              : null,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Funcionário',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final funcionario in disponiveis)
                              DropdownMenuItem(
                                value: funcionario.id,
                                child: Text(funcionario.nome),
                              ),
                          ],
                          onChanged: (id) => setState(() {
                            _funcionario = disponiveis.firstWhere(
                              (item) => item.id == id,
                            );
                          }),
                        ),
                    const SizedBox(height: 12),
                    const Text(
                      'COR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                    for (final cor in cores)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _ids.contains(cor.id),
                        onChanged: (marcada) => setState(() {
                          if (marcada ?? false) {
                            _ids.add(cor.id);
                          } else {
                            _ids.remove(cor.id);
                          }
                        }),
                        title: Row(
                          children: [
                            CorQuadradinho(cor: cor, tamanho: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(cor.nome)),
                          ],
                        ),
                      ),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.add),
                      title: const Text('Cadastrar cor'),
                      onTap: () => CorFormSheet.abrir(context),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: AppPrimaryButton(
                label: pronto ? 'Confirmar (${_ids.length})' : 'Confirmar',
                onPressed: pronto ? () => _confirmar(cores) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsaveisComCores extends StatelessWidget {
  final ProcessoProdutivo processo;
  final VoidCallback aoMudar;

  const ResponsaveisComCores({
    super.key,
    required this.processo,
    required this.aoMudar,
  });

  Future<void> _adicionar(BuildContext context) async {
    final escolhido = await escolherResponsavelECores(
      context,
      idsJaNaEtapa: processo.funcionarios.map((item) => item.id).toList(),
    );
    if (escolhido == null) return;

    processo.definirCores(escolhido.funcionario, escolhido.cores);
    aoMudar();
  }

  Future<void> _alterar(BuildContext context, Funcionario pessoa) async {
    final escolhido = await escolherResponsavelECores(
      context,
      fixo: pessoa,
      coresIniciais: processo.coresDe(pessoa.id),
    );
    if (escolhido == null) return;

    processo.definirCores(pessoa, escolhido.cores);
    aoMudar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final pessoa in processo.funcionarios)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E4EA)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pessoa.nome,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final cor in processo.coresDe(pessoa.id))
                            CorQuadradinho(cor: cor, tamanho: 18),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Alterar cores de ${pessoa.nome}',
                  onPressed: () => _alterar(context, pessoa),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
                IconButton(
                  tooltip: 'Remover ${pessoa.nome}',
                  onPressed: () {
                    processo.removerResponsavel(pessoa);
                    aoMudar();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _adicionar(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar responsável e cor'),
          ),
        ),
      ],
    );
  }
}

class ResponsaveisDaEtapa extends StatelessWidget {
  final ProcessoProdutivo processo;
  final VoidCallback aoMudar;

  const ResponsaveisDaEtapa({
    super.key,
    required this.processo,
    required this.aoMudar,
  });

  Future<void> _adicionar(BuildContext context) async {
    final escolhidos = await escolherResponsaveis(
      context,
      titulo: 'Responsáveis pela etapa ${processo.descricao}',
      selecionados: processo.funcionarios,
    );
    if (escolhidos == null) return;

    processo.definirResponsaveis(escolhidos);
    aoMudar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final pessoa in processo.funcionarios)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E4EA)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    pessoa.nome,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Remover ${pessoa.nome}',
                  onPressed: () {
                    processo.definirResponsaveis(
                      processo.funcionarios
                          .where((item) => item.id != pessoa.id)
                          .toList(),
                    );
                    aoMudar();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _adicionar(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar responsável'),
          ),
        ),
      ],
    );
  }
}
