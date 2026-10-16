import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/providers/admin_provider.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/validators.dart';

class NovaEmpresaSheet extends StatefulWidget {
  const NovaEmpresaSheet({super.key});

  static Future<void> abrir(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const NovaEmpresaSheet(),
    );
  }

  @override
  State<NovaEmpresaSheet> createState() => _NovaEmpresaSheetState();
}

class _NovaEmpresaSheetState extends State<NovaEmpresaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _empresaController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _empresaController.dispose();
    _cnpjController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<AdminProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await provider.criar(
        nomeFantasia: _empresaController.text.trim(),
        cnpj: _cnpjController.text.trim().isEmpty
            ? null
            : _cnpjController.text.trim(),
        usuarioNome: _nomeController.text.trim(),
        usuarioEmail: _emailController.text.trim(),
        usuarioSenha: _senhaController.text,
      );
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Empresa cadastrada')),
      );
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
            const Text(
              'Nova empresa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppTextField(
              label: 'NOME DA EMPRESA',
              hintText: 'Ex.: Confecções Alfa',
              prefixIcon: Icons.business_outlined,
              controller: _empresaController,
              validator: (valor) =>
                  validarObrigatorio(valor, 'Informe o nome da empresa'),
            ),
            AppTextField(
              label: 'CNPJ (OPCIONAL)',
              hintText: '00.000.000/0000-00',
              prefixIcon: Icons.badge_outlined,
              controller: _cnpjController,
              keyboardType: TextInputType.number,
            ),
            const Text(
              'Primeiro usuário: acessa tudo, inclusive o cadastro da empresa.',
              style: TextStyle(fontSize: 12),
            ),
            AppTextField(
              label: 'NOME DO USUÁRIO',
              hintText: 'Nome completo',
              prefixIcon: Icons.person_outline,
              controller: _nomeController,
              validator: (valor) =>
                  validarObrigatorio(valor, 'Informe o nome do usuário'),
            ),
            AppTextField(
              label: 'E-MAIL (LOGIN)',
              hintText: 'usuario@empresa.com',
              prefixIcon: Icons.mail_outline,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: validarEmail,
            ),
            AppTextField(
              label: 'SENHA',
              hintText: 'Mínimo 6 caracteres',
              prefixIcon: Icons.lock_outline_rounded,
              controller: _senhaController,
              obscureText: true,
              validator: validarSenha,
            ),
            AppPrimaryButton(
              label: 'Cadastrar empresa',
              carregando: _carregando,
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}
