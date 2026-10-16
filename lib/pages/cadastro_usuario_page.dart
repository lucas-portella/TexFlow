import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/providers/usuarios_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_dropdown_field.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/modulos_switches.dart';
import 'package:texflow/shared/validators.dart';

class CadastroUsuarioPage extends StatefulWidget {
  final Usuario? usuario;

  const CadastroUsuarioPage({super.key, this.usuario});

  static const route = AppRoutes.novoUsuario;

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(
    text: widget.usuario?.nome,
  );
  late final _emailController = TextEditingController(
    text: widget.usuario?.email,
  );
  late final _cargoController = TextEditingController(
    text: widget.usuario?.cargo,
  );
  final _senhaController = TextEditingController();
  late UserType _tipo = widget.usuario?.tipo ?? UserType.OPERADOR;
  late Set<Modulo> _modulos = Set.of(widget.usuario?.modulos ?? <Modulo>{});
  bool _carregando = false;

  bool get _editando => widget.usuario != null;

  bool get _travado {
    final alvo = widget.usuario;
    if (alvo == null) return false;

    final logado = context.read<UsuarioProvider>().usuario;
    return alvo.donoDaEmpresa || alvo.idUsuario == logado?.idUsuario;
  }

  Set<Modulo> get _liberados =>
      context.read<UsuarioProvider>().usuario?.modulos ?? <Modulo>{};

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cargoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<UsuariosProvider>();
    final travado = _travado;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    final cargo = _cargoController.text.trim();

    try {
      if (_editando) {
        await provider.atualizar(
          widget.usuario!,
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          cargo: cargo,
          tipo: travado ? null : _tipo,
          modulos: travado ? null : _modulos,
        );
      } else {
        await provider.criar(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text,
          tipo: _tipo,
          modulos: _modulos,
          cargo: cargo.isEmpty ? null : cargo,
        );
      }

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Usuário atualizado com sucesso'
                : 'Usuário cadastrado com sucesso',
          ),
        ),
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
    final travado = _travado;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: ApplicationAppBar(
        title: _editando ? 'Alterar usuário' : 'Cadastrar usuário',
      ),
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
                label: 'CARGO',
                hintText: 'Ex.: Gerente de produção',
                prefixIcon: Icons.work_outline,
                controller: _cargoController,
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
                enabled: !_editando,
                validator: _editando ? null : validarSenha,
              ),
              AppDropdownField<UserType>(
                label: 'PERFIL',
                hintText: 'Selecione o perfil',
                prefixIcon: Icons.person_outline,
                value: _tipo,
                enabled: !travado,
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
                onChanged: (valor) => setState(() {
                  _tipo = valor!;
                  if (!_editando) {
                    _modulos = _tipo == UserType.GESTOR
                        ? Set.of(_liberados)
                        : {};
                  }
                }),
              ),
              const AppFieldLabel('ACESSOS'),
              ModulosSwitches(
                selecionados: _modulos,
                liberados: _liberados,
                travado: travado,
                aoMudar: (novos) => setState(() => _modulos = novos),
              ),
              const SizedBox(height: 8),
              AppPrimaryButton(
                label: _editando ? 'Salvar' : 'Cadastrar',
                carregando: _carregando,
                onPressed: _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
