import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/pages/cadastro_page.dart';
import 'package:texflow/pages/dashboard_page.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/shared/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  Future<void> _entrar() async {
    setState(() {
      _carregando = true;
    });

    try {
      await context.read<UsuarioProvider>().login(
        _emailController.text,
        _senhaController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
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
              SizedBox(height: 50),
              LoginPageLogo(),
              SizedBox(height: 50),
              Form(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      AppTextField(
                        label: 'USUÁRIO',
                        hintText: 'seu.usuario',
                        prefixIcon: Icons.person_outlined,
                        controller: _emailController,
                      ),
                      AppTextField(
                        label: 'SENHA',
                        hintText: '********',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: Icons.visibility_outlined,
                        controller: _senhaController,
                        obscureText: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Esqueci minha senha',
                              style: TextStyle(
                                color: Color(0xFF3A5BD9),
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CadastroPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Cadastrar',
                              style: TextStyle(
                                color: Color(0xFF3A5BD9),
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _carregando ? null : _entrar,
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
                                    'Entrar',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Text(
                        'TexFlow v0.0.1 © 2026 Todos os direitos reservados',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontFamily: 'DM Sans',
                          fontSize: 12,
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

class AppTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, color: Color(0xFF6B7280)),
              suffixIcon: Icon(suffixIcon, color: Color(0xFF6B7280)),
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  // color: Colors.grey,
                  color: Color.fromARGB(255, 239, 239, 239),
                  width: 1,
                ),
              ),
              filled: true,
              hintText: hintText,
            ),
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPageLogo extends StatelessWidget {
  const LoginPageLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(40, 0, 0, 0),
                blurRadius: 20,
                spreadRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'lib/assets/images/logo-mark.png',
            width: 72,
            height: 72,
          ),
        ),
        Text(
          'TexFlow',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            fontFamily: 'DM Sans',
            color: AppColors.black,
          ),
        ),
        Text(
          'Gestão de produção têxtil',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
