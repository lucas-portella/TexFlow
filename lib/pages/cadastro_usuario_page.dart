import 'package:flutter/material.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/services/usuario_service.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_dropdown_field.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/validators.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  static const route = AppRoutes.novoUsuario;

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  UserType _tipo = UserType.OPERADOR;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await UsuarioService.criar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        tipo: _tipo,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso')),
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
      appBar: const ApplicationAppBar(title: 'Cadastrar usuário'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              AppTextField(
                label: 'NOME',
                hintText: 'nome completo',
                prefixIcon: Icons.badge_outlined,
                controller: _nomeController,
                validator: (valor) =>
                    validarObrigatorio(valor, 'Digite o nome'),
              ),
              AppTextField(
                label: 'E-MAIL',
                hintText: 'email@exemplo.com',
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: validarEmail,
              ),
              AppTextField(
                label: 'SENHA',
                hintText: '********',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _senhaController,
                obscureText: true,
                validator: validarSenha,
              ),
              AppDropdownField<UserType>(
                label: 'PERFIL',
                hintText: 'Selecione o perfil',
                prefixIcon: Icons.person_outline,
                value: _tipo,
                items: const [
                  DropdownMenuItem(
                    value: UserType.OPERADOR,
                    child: Text('Operador'),
                  ),
                  DropdownMenuItem(
                    value: UserType.GESTOR,
                    child: Text('Supervisor'),
                  ),
                ],
                onChanged: (valor) => setState(() => _tipo = valor!),
              ),
              const SizedBox(height: 8),
              AppPrimaryButton(
                label: 'Cadastrar',
                carregando: _carregando,
                onPressed: _cadastrar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
