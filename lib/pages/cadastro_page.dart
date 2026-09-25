import 'package:flutter/material.dart';
import 'package:texflow/pages/login_page.dart';
import 'package:texflow/services/auth_service.dart';
import 'package:texflow/shared/app_colors.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  String? _validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Digite seu nome';
    }
    return null;
  }

  String? _validarEmail(String? valor) {
    if (valor == null || !valor.contains('@')) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.length < 6) {
      return 'A senha precisa ter pelo menos 6 caracteres';
    }
    if (!RegExp(r'[a-z]').hasMatch(valor)) {
      return 'A senha precisa ter uma letra minúscula';
    }
    if (!RegExp(r'[A-Z]').hasMatch(valor)) {
      return 'A senha precisa ter uma letra maiúscula';
    }
    if (!RegExp(r'[.,!?;:@#\$%&*()\-_+=]').hasMatch(valor)) {
      return 'A senha precisa ter uma pontuação';
    }
    return null;
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
    });

    try {
      await AuthService.cadastro(
        _nomeController.text,
        _emailController.text,
        _senhaController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Color.fromARGB(255, 236, 235, 235),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Criar conta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'DM Sans',
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Preencha seus dados para começar',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      AppTextField(
                        label: 'NOME',
                        hintText: 'seu nome completo',
                        prefixIcon: Icons.badge_outlined,
                        controller: _nomeController,
                        validator: _validarNome,
                      ),
                      AppTextField(
                        label: 'E-MAIL',
                        hintText: 'seu.email@exemplo.com',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        validator: _validarEmail,
                      ),
                      AppTextField(
                        label: 'SENHA',
                        hintText: '********',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: Icons.visibility_outlined,
                        controller: _senhaController,
                        obscureText: true,
                        validator: _validarSenha,
                      ),
                      TextButton(
                        onPressed: _carregando ? null : _cadastrar,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(40, 0, 0, 0),
                                offset: Offset(0, 10),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                            color: Color(0xFF1B2D5C),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: _carregando
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    'Cadastrar',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
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
