import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/custo.dart';
import 'package:texflow/providers/custo_provider.dart';
import 'package:texflow/shared/app_dropdown_field.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/validators.dart';

class CustoFormSheet extends StatefulWidget {
  final Custo? custo;

  const CustoFormSheet({super.key, this.custo});

  static Future<void> abrir(BuildContext context, {Custo? custo}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CustoFormSheet(custo: custo),
    );
  }

  @override
  State<CustoFormSheet> createState() => _CustoFormSheetState();
}

class _CustoFormSheetState extends State<CustoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _descricaoController = TextEditingController(
    text: widget.custo?.descricao,
  );
  late final _valorController = TextEditingController(
    text: widget.custo == null
        ? ''
        : widget.custo!.valor.toStringAsFixed(2).replaceAll('.', ','),
  );
  late final _intervaloController = TextEditingController(
    text: widget.custo?.intervaloDias?.toString() ?? '',
  );
  late final _dataController = TextEditingController(
    text: widget.custo == null ? '' : formatarData(widget.custo!.data),
  );
  late final _dataFimController = TextEditingController(
    text: widget.custo?.dataFim == null
        ? ''
        : formatarData(widget.custo!.dataFim),
  );
  late CategoriaCusto _categoria =
      widget.custo?.categoria ?? CategoriaCusto.outros;
  late bool _recorrente = widget.custo?.recorrente ?? false;
  late DateTime? _data = _lerData(widget.custo?.data);
  late DateTime? _dataFim = _lerData(widget.custo?.dataFim);
  bool _carregando = false;

  static DateTime? _lerData(String? texto) {
    if (texto == null || texto.isEmpty) return null;
    return DateTime.tryParse(texto);
  }

  static String _paraIso(DateTime data) {
    return '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  }

  static String _paraTela(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _intervaloController.dispose();
    _dataController.dispose();
    _dataFimController.dispose();
    super.dispose();
  }

  Future<DateTime?> _escolherData(DateTime? atual) {
    return showDatePicker(
      context: context,
      initialDate: atual ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _escolherInicio() async {
    final escolhida = await _escolherData(_data);
    if (escolhida == null) return;
    setState(() {
      _data = escolhida;
      _dataController.text = _paraTela(escolhida);
    });
  }

  Future<void> _escolherFim() async {
    final escolhida = await _escolherData(_dataFim ?? _data);
    if (escolhida == null) return;
    setState(() {
      _dataFim = escolhida;
      _dataFimController.text = _paraTela(escolhida);
    });
  }

  void _limparFim() {
    setState(() {
      _dataFim = null;
      _dataFimController.clear();
    });
  }

  String? _validarValor(String? valor) {
    final numero = lerValor(valor ?? '');
    if (numero == null || numero <= 0) return 'Informe um valor maior que zero';
    return null;
  }

  String? _validarIntervalo(String? valor) {
    if (!_recorrente) return null;
    final dias = int.tryParse((valor ?? '').trim());
    if (dias == null || dias < 1) return 'Informe de quantos em quantos dias';
    return null;
  }

  String? _validarDataFim(String? valor) {
    if (!_recorrente || _dataFim == null || _data == null) return null;
    if (_dataFim!.isBefore(_data!)) return 'Antes da data de início';
    return null;
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<CustoProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await provider.salvar(
        id: widget.custo?.id,
        descricao: _descricaoController.text.trim(),
        categoria: _categoria,
        valor: lerValor(_valorController.text)!,
        data: _paraIso(_data!),
        intervaloDias: _recorrente
            ? int.parse(_intervaloController.text.trim())
            : null,
        dataFim: _recorrente && _dataFim != null ? _paraIso(_dataFim!) : null,
      );
      navigator.pop();
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
            Text(
              widget.custo == null ? 'Novo custo' : 'Editar custo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppTextField(
              label: 'DESCRIÇÃO',
              hintText: 'Ex.: Aluguel do galpão',
              prefixIcon: Icons.notes_outlined,
              controller: _descricaoController,
              validator: (valor) =>
                  validarObrigatorio(valor, 'Informe a descrição'),
            ),
            AppDropdownField<CategoriaCusto>(
              label: 'CATEGORIA',
              hintText: 'Selecione a categoria',
              prefixIcon: Icons.category_outlined,
              value: _categoria,
              items: [
                for (final categoria in CategoriaCusto.values)
                  DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria.rotulo),
                  ),
              ],
              onChanged: (valor) => setState(() => _categoria = valor!),
            ),
            AppTextField(
              label: 'VALOR',
              hintText: '0,00',
              prefixIcon: Icons.attach_money,
              controller: _valorController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validarValor,
            ),
            AppTextField(
              label: _recorrente ? 'PRIMEIRA COBRANÇA' : 'DATA',
              hintText: 'Toque para escolher',
              prefixIcon: Icons.event_outlined,
              controller: _dataController,
              readOnly: true,
              onTap: _escolherInicio,
              validator: (_) => _data == null ? 'Escolha a data' : null,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Repetir automaticamente'),
              subtitle: const Text(
                'Conta o mesmo custo a cada quantidade de dias.',
              ),
              value: _recorrente,
              onChanged: (valor) => setState(() => _recorrente = valor),
            ),
            AppTextField(
              label: 'REPETIR A CADA (DIAS)',
              hintText: 'Ex.: 30',
              prefixIcon: Icons.repeat,
              controller: _intervaloController,
              enabled: _recorrente,
              keyboardType: TextInputType.number,
              validator: _validarIntervalo,
            ),
            AppTextField(
              label: 'REPETIR ATÉ (OPCIONAL)',
              hintText: 'Sem data final',
              prefixIcon: Icons.event_busy_outlined,
              controller: _dataFimController,
              enabled: _recorrente,
              readOnly: true,
              onTap: _escolherFim,
              validator: _validarDataFim,
            ),
            TextButton(
              onPressed: _recorrente && _dataFim != null ? _limparFim : null,
              child: const Text('Remover data final'),
            ),
            AppPrimaryButton(
              label: 'Salvar',
              carregando: _carregando,
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}
