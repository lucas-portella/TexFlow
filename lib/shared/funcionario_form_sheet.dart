import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/validators.dart';

class FuncionarioFormSheet extends StatefulWidget {
  final Funcionario? funcionario;

  const FuncionarioFormSheet({super.key, this.funcionario});

  static Future<void> abrir(BuildContext context, {Funcionario? funcionario}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FuncionarioFormSheet(funcionario: funcionario),
    );
  }

  @override
  State<FuncionarioFormSheet> createState() => _FuncionarioFormSheetState();
}

class _FuncionarioFormSheetState extends State<FuncionarioFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(
    text: widget.funcionario?.nome,
  );
  late final _cargoController = TextEditingController(
    text: widget.funcionario?.cargo,
  );
  late bool _ativo = widget.funcionario?.ativo ?? true;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<FuncionarioProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await provider.salvar(
        id: widget.funcionario?.id,
        nome: _nomeController.text.trim(),
        cargo: _cargoController.text.trim().isEmpty
            ? null
            : _cargoController.text.trim(),
        ativo: _ativo,
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
              widget.funcionario == null
                  ? 'Novo funcionário'
                  : 'Editar funcionário',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppTextField(
              label: 'NOME',
              hintText: 'Nome do funcionário',
              prefixIcon: Icons.person_outline,
              controller: _nomeController,
              validator: (valor) =>
                  validarObrigatorio(valor, 'Informe o nome do funcionário'),
            ),
            AppTextField(
              label: 'CARGO',
              hintText: 'Ex.: Costureira',
              prefixIcon: Icons.work_outline,
              controller: _cargoController,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ativo'),
              subtitle: const Text(
                'Só funcionários ativos podem ser escolhidos como responsáveis.',
              ),
              value: _ativo,
              onChanged: (valor) => setState(() => _ativo = valor),
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
