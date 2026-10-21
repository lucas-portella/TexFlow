import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/tamanho.dart';
import 'package:texflow/providers/tamanho_provider.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/validators.dart';

class TamanhoFormSheet extends StatefulWidget {
  final Tamanho? tamanho;

  const TamanhoFormSheet({super.key, this.tamanho});

  static Future<void> abrir(BuildContext context, {Tamanho? tamanho}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TamanhoFormSheet(tamanho: tamanho),
    );
  }

  @override
  State<TamanhoFormSheet> createState() => _TamanhoFormSheetState();
}

class _TamanhoFormSheetState extends State<TamanhoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(
    text: widget.tamanho?.nome,
  );
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<TamanhoProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await provider.salvar(
        id: widget.tamanho?.id,
        nome: _nomeController.text.trim(),
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
              widget.tamanho == null ? 'Novo tamanho' : 'Editar tamanho',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppTextField(
              label: 'NOME DO TAMANHO',
              hintText: 'Ex.: XG',
              prefixIcon: Icons.straighten,
              controller: _nomeController,
              validator: (valor) =>
                  validarObrigatorio(valor, 'Informe o nome do tamanho'),
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
