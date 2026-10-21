import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/cor.dart';
import 'package:texflow/providers/cor_provider.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/seletor_de_cor.dart';
import 'package:texflow/shared/validators.dart';

class CorFormSheet extends StatefulWidget {
  final Cor? cor;

  const CorFormSheet({super.key, this.cor});

  static Future<void> abrir(BuildContext context, {Cor? cor}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CorFormSheet(cor: cor),
    );
  }

  @override
  State<CorFormSheet> createState() => _CorFormSheetState();
}

class _CorFormSheetState extends State<CorFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(text: widget.cor?.nome);
  late String? _hex = widget.cor?.hex.toUpperCase();
  bool _semQuadradinho = false;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<CorProvider>();

    final nomeOk = _formKey.currentState!.validate();
    setState(() => _semQuadradinho = _hex == null);
    if (!nomeOk || _hex == null) return;

    setState(() => _carregando = true);

    try {
      await provider.salvar(
        id: widget.cor?.id,
        nome: _nomeController.text.trim(),
        hex: _hex!,
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
              widget.cor == null ? 'Nova cor' : 'Editar cor',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppTextField(
              label: 'NOME DA COR',
              hintText: 'Ex.: Coral',
              prefixIcon: Icons.palette_outlined,
              controller: _nomeController,
              validator: (valor) =>
                  validarObrigatorio(valor, 'Informe o nome da cor'),
            ),
            const AppFieldLabel('QUADRADINHO'),
            SeletorDeCor(
              hex: _hex,
              aoEscolher: (hex) => setState(() {
                _hex = hex;
                _semQuadradinho = false;
              }),
            ),
            if (_semQuadradinho)
              const Text(
                'Escolha o quadradinho da cor',
                style: TextStyle(color: AppColors.danger, fontSize: 12),
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
