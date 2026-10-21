import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/validators.dart';

class EtapaFormSheet extends StatefulWidget {
  final Etapa? etapa;

  const EtapaFormSheet({super.key, this.etapa});

  static Future<void> abrir(BuildContext context, {Etapa? etapa}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EtapaFormSheet(etapa: etapa),
    );
  }

  @override
  State<EtapaFormSheet> createState() => _EtapaFormSheetState();
}

class _EtapaFormSheetState extends State<EtapaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(text: widget.etapa?.nome);
  late final _valorController = TextEditingController(
    text: widget.etapa == null
        ? ''
        : widget.etapa!.valorComissao.toStringAsFixed(2).replaceAll('.', ','),
  );
  late bool _permiteCores = widget.etapa?.permiteCores ?? false;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  String? _validarValor(String? valor) {
    final numero = lerValor(valor ?? '');
    if (numero == null) return 'Informe o valor da comissão';
    if (numero < 0) return 'O valor não pode ser negativo';
    return null;
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<EtapaProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await provider.salvar(
        id: widget.etapa?.id,
        nome: _nomeController.text.trim(),
        valorComissao: lerValor(_valorController.text)!,
        permiteCores: _permiteCores,
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
    return Padding(
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
              widget.etapa == null ? 'Nova etapa' : 'Editar etapa',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppTextField(
              label: 'NOME DA ETAPA',
              hintText: 'Ex.: Manga',
              prefixIcon: Icons.account_tree_outlined,
              controller: _nomeController,
              validator: (valor) =>
                  validarObrigatorio(valor, 'Informe o nome da etapa'),
            ),
            AppTextField(
              label: 'COMISSÃO POR PEÇA (R\$)',
              hintText: '0,30',
              prefixIcon: Icons.payments_outlined,
              controller: _valorController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validarValor,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _permiteCores,
              onChanged: (valor) =>
                  setState(() => _permiteCores = valor ?? false),
              title: const Text('Podem haver mais cores para esta etapa'),
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
