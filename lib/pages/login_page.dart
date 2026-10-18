import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/providers/admin_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_info.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/login_page_logo.dart';
import 'package:texflow/shared/validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const route = AppRoutes.login;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    final usuario = _emailController.text.trim();
    final ehAdmin = !usuario.contains('@');

    try {
      if (ehAdmin) {
        await context.read<AdminProvider>().entrar(
          usuario,
          _senhaController.text.trim(),
        );

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.admin);
        return;
      }

      await context.read<UsuarioProvider>().login(
        usuario,
        _senhaController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
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
      backgroundColor: AppColors.loginBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const LoginPageLogo(),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      AppTextField(
                        label: 'USUÁRIO',
                        hintText: 'seu.email@exemplo.com',
                        prefixIcon: Icons.person_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (valor) =>
                            validarObrigatorio(valor, 'Informe seu e-mail'),
                      ),
                      AppTextField(
                        label: 'SENHA',
                        hintText: '********',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _senhaController,
                        obscureText: true,
                        validator: (valor) =>
                            validarObrigatorio(valor, 'Informe sua senha'),
                      ),
                      const SizedBox(height: 8),
                      AppPrimaryButton(
                        label: 'Entrar',
                        carregando: _carregando,
                        onPressed: _entrar,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'TexFlow v${AppInfo.versao} © 2026 Todos os direitos reservados',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
