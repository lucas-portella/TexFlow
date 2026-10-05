import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/validators.dart';

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({super.key});

  static const route = AppRoutes.alterarSenha;

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  String? _validarConfirmacao(String? valor) {
    if (valor != _novaSenhaController.text) {
      return 'As senhas não conferem';
    }
    return null;
  }

  Future<void> _alterar() async {
    final messenger = ScaffoldMessenger.of(context);
    final usuarioProvider = context.read<UsuarioProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await usuarioProvider.alterarSenha(
        _senhaAtualController.text,
        _novaSenhaController.text,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso')),
      );
      Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Alterar senha'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              AppTextField(
                label: 'SENHA ATUAL',
                hintText: '********',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _senhaAtualController,
                obscureText: true,
                validator: (valor) =>
                    validarObrigatorio(valor, 'Informe a senha atual'),
              ),
              AppTextField(
                label: 'NOVA SENHA',
                hintText: '********',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _novaSenhaController,
                obscureText: true,
                validator: validarSenha,
              ),
              AppTextField(
                label: 'CONFIRMAR NOVA SENHA',
                hintText: '********',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _confirmarSenhaController,
                obscureText: true,
                validator: _validarConfirmacao,
              ),
              const SizedBox(height: 8),
              AppPrimaryButton(
                label: 'Alterar senha',
                carregando: _carregando,
                onPressed: _alterar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
