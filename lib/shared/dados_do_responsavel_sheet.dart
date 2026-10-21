import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/cor.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/linha_da_etapa.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/models/tamanho.dart';
import 'package:texflow/providers/cor_provider.dart';
import 'package:texflow/providers/tamanho_provider.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/cor_quadradinho.dart';

Future<List<LinhaDaEtapa>?> pedirDadosDoResponsavel(
  BuildContext context,
  ProcessoProdutivo processo,
  Funcionario pessoa,
) {
  return showModalBottomSheet<List<LinhaDaEtapa>>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        _DadosDoResponsavelSheet(processo: processo, pessoa: pessoa),
  );
}

class _LinhaEditavel {
  int? corId;
  int? tamanhoId;
  final TextEditingController quantidade;
  Cor? corOriginal;
  Tamanho? tamanhoOriginal;

  _LinhaEditavel({
    this.corId,
    this.tamanhoId,
    int? quantidade,
    this.corOriginal,
    this.tamanhoOriginal,
  }) : quantidade = TextEditingController(text: quantidade?.toString());
}

class _DadosDoResponsavelSheet extends StatefulWidget {
  final ProcessoProdutivo processo;
  final Funcionario pessoa;

  const _DadosDoResponsavelSheet({
    required this.processo,
    required this.pessoa,
  });

  @override
  State<_DadosDoResponsavelSheet> createState() =>
      _DadosDoResponsavelSheetState();
}

class _DadosDoResponsavelSheetState extends State<_DadosDoResponsavelSheet> {
  late final List<_LinhaEditavel> _linhas = [
    for (final linha in widget.processo.linhasDe(widget.pessoa.id))
      _LinhaEditavel(
        corId: linha.cor?.id,
        tamanhoId: linha.tamanho?.id,
        quantidade: linha.quantidade,
        corOriginal: linha.cor,
        tamanhoOriginal: linha.tamanho,
      ),
  ];
  bool _faltaCor = false;

  bool get _colorida => widget.processo.permiteCores;

  @override
  void initState() {
    super.initState();
    if (_linhas.isEmpty) {
      _linhas.add(
        _LinhaEditavel(
          quantidade: _colorida
              ? null
              : widget.processo.quantidades[widget.pessoa.id],
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_colorida) context.read<CorProvider>().carregar();
      context.read<TamanhoProvider>().carregar();
    });
  }

  @override
  void dispose() {
    for (final linha in _linhas) {
      linha.quantidade.dispose();
    }
    super.dispose();
  }

  void _salvar() {
    if (_colorida && _linhas.any((linha) => linha.corId == null)) {
      setState(() => _faltaCor = true);
      return;
    }

    final cores = context.read<CorProvider>().cores;
    final tamanhos = context.read<TamanhoProvider>().tamanhos;

    Cor? corDe(_LinhaEditavel linha) {
      if (!_colorida) return null;
      for (final cor in cores) {
        if (cor.id == linha.corId) return cor;
      }
      return linha.corOriginal;
    }

    Tamanho? tamanhoDe(_LinhaEditavel linha) {
      for (final tamanho in tamanhos) {
        if (tamanho.id == linha.tamanhoId) return tamanho;
      }
      return linha.tamanhoOriginal;
    }

    Navigator.pop(context, [
      for (final linha in _linhas)
        LinhaDaEtapa(
          funcionario: widget.pessoa,
          cor: corDe(linha),
          tamanho: linha.tamanhoId == null ? null : tamanhoDe(linha),
          quantidade: int.tryParse(linha.quantidade.text.trim()),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(
            widget.pessoa.nome,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            widget.processo.descricao,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          for (var i = 0; i < _linhas.length; i++)
            _CartaoDaLinha(
              key: ObjectKey(_linhas[i]),
              linha: _linhas[i],
              colorida: _colorida,
              podeRemover: _linhas.length > 1,
              aoMudar: () => setState(() => _faltaCor = false),
              aoRemover: () => setState(() => _linhas.removeAt(i)),
            ),
          if (_faltaCor)
            const Text(
              'Escolha a cor de cada linha',
              style: TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _linhas.add(_LinhaEditavel())),
              icon: const Icon(Icons.add),
              label: Text(_colorida ? 'Adicionar cor' : 'Adicionar tamanho'),
            ),
          ),
          AppPrimaryButton(label: 'Salvar', onPressed: _salvar),
        ],
      ),
    );
  }
}

class _CartaoDaLinha extends StatelessWidget {
  final _LinhaEditavel linha;
  final bool colorida;
  final bool podeRemover;
  final VoidCallback aoMudar;
  final VoidCallback aoRemover;

  const _CartaoDaLinha({
    super.key,
    required this.linha,
    required this.colorida,
    required this.podeRemover,
    required this.aoMudar,
    required this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final tamanhos = [...context.watch<TamanhoProvider>().tamanhos];
    final tamanhoOriginal = linha.tamanhoOriginal;
    if (tamanhoOriginal != null &&
        !tamanhos.any((item) => item.id == tamanhoOriginal.id)) {
      tamanhos.add(tamanhoOriginal);
    }

    final seletorDeTamanho = DropdownButtonFormField<int?>(
      initialValue: tamanhos.any((item) => item.id == linha.tamanhoId)
          ? linha.tamanhoId
          : null,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Tamanho',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Sem tamanho')),
        for (final tamanho in tamanhos)
          DropdownMenuItem<int?>(value: tamanho.id, child: Text(tamanho.nome)),
      ],
      onChanged: (id) {
        linha.tamanhoId = id;
        linha.tamanhoOriginal = null;
      },
    );

    final campoDePecas = TextField(
      controller: linha.quantidade,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Peças',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );

    final botaoDeRemover = podeRemover
        ? IconButton(
            tooltip: colorida ? 'Remover cor' : 'Remover tamanho',
            onPressed: aoRemover,
            icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
          )
        : const SizedBox(width: 8);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 10,
        children: [
          if (colorida)
            Row(
              children: [
                Expanded(
                  child: _SeletorDeCor(linha: linha, aoMudar: aoMudar),
                ),
                botaoDeRemover,
              ],
            ),
          Row(
            spacing: 10,
            children: [
              Expanded(child: seletorDeTamanho),
              Expanded(child: campoDePecas),
              if (colorida) const SizedBox(width: 8) else botaoDeRemover,
            ],
          ),
        ],
      ),
    );
  }
}

class _SeletorDeCor extends StatelessWidget {
  final _LinhaEditavel linha;
  final VoidCallback aoMudar;

  const _SeletorDeCor({required this.linha, required this.aoMudar});

  @override
  Widget build(BuildContext context) {
    final cores = [...context.watch<CorProvider>().cores];
    final original = linha.corOriginal;
    if (original != null && !cores.any((cor) => cor.id == original.id)) {
      cores.add(original);
    }

    return DropdownButtonFormField<int>(
      initialValue: cores.any((cor) => cor.id == linha.corId)
          ? linha.corId
          : null,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Cor',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        for (final cor in cores)
          DropdownMenuItem(
            value: cor.id,
            child: Row(
              children: [
                CorQuadradinho(cor: cor, tamanho: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(cor.nome)),
              ],
            ),
          ),
      ],
      onChanged: (id) {
        linha.corId = id;
        linha.corOriginal = null;
        aoMudar();
      },
    );
  }
}
