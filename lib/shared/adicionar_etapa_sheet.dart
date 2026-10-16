import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/shared/app_dropdown_field.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/validators.dart';

class DadosDaEtapaAdicionada {
  final Etapa? etapa;
  final String? nome;
  final double valor;
  final Funcionario funcionario;

  const DadosDaEtapaAdicionada({
    this.etapa,
    this.nome,
    required this.valor,
    required this.funcionario,
  });

  bool get ehNova => etapa == null;

  String get descricao => etapa?.nome ?? nome ?? '';
}

class AdicionarEtapaSheet extends StatefulWidget {
  final List<String> descricoesExistentes;
  final Future<void> Function(DadosDaEtapaAdicionada dados) aoConfirmar;

  const AdicionarEtapaSheet({
    super.key,
    required this.descricoesExistentes,
    required this.aoConfirmar,
  });

  static Future<void> abrir(
    BuildContext context, {
    required List<String> descricoesExistentes,
    required Future<void> Function(DadosDaEtapaAdicionada dados) aoConfirmar,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AdicionarEtapaSheet(
        descricoesExistentes: descricoesExistentes,
        aoConfirmar: aoConfirmar,
      ),
    );
  }

  @override
  State<AdicionarEtapaSheet> createState() => _AdicionarEtapaSheetState();
}

class _AdicionarEtapaSheetState extends State<AdicionarEtapaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  bool _nova = false;
  Etapa? _etapa;
  Funcionario? _funcionario;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EtapaProvider>().carregar();
      context.read<FuncionarioProvider>().carregar();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  List<Etapa> _disponiveis(List<Etapa> todas) {
    final existentes = widget.descricoesExistentes
        .map((descricao) => descricao.trim().toLowerCase())
        .toSet();

    return todas
        .where((etapa) => !existentes.contains(etapa.nome.trim().toLowerCase()))
        .toList();
  }

  void _escolherEtapa(Etapa? etapa) {
    setState(() {
      _etapa = etapa;
      if (etapa != null) {
        _valorController.text = etapa.valorComissao
            .toStringAsFixed(2)
            .replaceAll('.', ',');
      }
    });
  }

  String? _validarValor(String? valor) {
    final numero = lerValor(valor ?? '');
    if (numero == null) return 'Informe o valor da etapa';
    if (numero < 0) return 'O valor não pode ser negativo';
    return null;
  }

  Future<void> _adicionar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await widget.aoConfirmar(
        DadosDaEtapaAdicionada(
          etapa: _nova ? null : _etapa,
          nome: _nova ? _nomeController.text.trim() : null,
          valor: lerValor(_valorController.text)!,
          funcionario: _funcionario!,
        ),
      );
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Etapa adicionada')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disponiveis = _disponiveis(context.watch<EtapaProvider>().etapas);
    final funcionarios = context.watch<FuncionarioProvider>().ativos;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            const Text(
              'Adicionar etapa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  const ButtonSegment(
                    value: false,
                    label: Text('Já cadastrada'),
                  ),
                  ButtonSegment(value: true, label: const Text('Nova etapa')),
                ],
                selected: {_nova},
                onSelectionChanged: (valor) =>
                    setState(() => _nova = valor.first),
              ),
            ),
            if (_nova)
              AppTextField(
                label: 'NOME DA ETAPA',
                hintText: 'Ex.: Bordado',
                prefixIcon: Icons.account_tree_outlined,
                controller: _nomeController,
                validator: (valor) =>
                    validarObrigatorio(valor, 'Informe o nome da etapa'),
              )
            else
              AppDropdownField<Etapa>(
                label: 'ETAPA',
                hintText: 'Escolha uma etapa',
                prefixIcon: Icons.account_tree_outlined,
                value: _etapa,
                items: [
                  for (final etapa in disponiveis)
                    DropdownMenuItem(value: etapa, child: Text(etapa.nome)),
                ],
                onChanged: _escolherEtapa,
                validator: (valor) => valor == null ? 'Escolha a etapa' : null,
              ),
            AppTextField(
              label: 'VALOR POR PEÇA',
              hintText: '0,00',
              prefixIcon: Icons.attach_money,
              controller: _valorController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validarValor,
            ),
            AppDropdownField<Funcionario>(
              label: 'RESPONSÁVEL',
              hintText: 'Escolha o funcionário',
              prefixIcon: Icons.person_outline,
              value: _funcionario,
              items: [
                for (final funcionario in funcionarios)
                  DropdownMenuItem(
                    value: funcionario,
                    child: Text(funcionario.nome),
                  ),
              ],
              onChanged: (valor) => setState(() => _funcionario = valor),
              validator: (valor) =>
                  valor == null ? 'Escolha o responsável' : null,
            ),
            AppPrimaryButton(
              label: 'Adicionar etapa',
              carregando: _carregando,
              onPressed: _adicionar,
            ),
          ],
        ),
      ),
    );
  }
}
