import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/minha_empresa.dart';
import 'package:texflow/providers/minha_empresa_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/section_title.dart';
import 'package:texflow/shared/validators.dart';

class MinhaEmpresaPage extends StatefulWidget {
  const MinhaEmpresaPage({super.key});

  static const route = AppRoutes.minhaEmpresa;

  @override
  State<MinhaEmpresaPage> createState() => _MinhaEmpresaPageState();
}

class _MinhaEmpresaPageState extends State<MinhaEmpresaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _razaoController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  bool _preenchido = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MinhaEmpresaProvider>();
      await provider.carregar();
      _preencher(provider.empresa);
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _razaoController.dispose();
    _cnpjController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  void _preencher(MinhaEmpresa? empresa) {
    if (!mounted || _preenchido || empresa == null) return;
    _nomeController.text = empresa.nomeFantasia;
    _razaoController.text = empresa.razaoSocial ?? '';
    _cnpjController.text = empresa.cnpj ?? '';
    _telefoneController.text = empresa.telefone ?? '';
    _emailController.text = empresa.email ?? '';
    _enderecoController.text = empresa.endereco ?? '';
    _cidadeController.text = empresa.cidade ?? '';
    _preenchido = true;
  }

  String? _opcional(TextEditingController controller) {
    final texto = controller.text.trim();
    return texto.isEmpty ? null : texto;
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<MinhaEmpresaProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      await provider.salvar(
        MinhaEmpresa(
          nomeFantasia: _nomeController.text.trim(),
          razaoSocial: _opcional(_razaoController),
          cnpj: _opcional(_cnpjController),
          telefone: _opcional(_telefoneController),
          email: _opcional(_emailController),
          endereco: _opcional(_enderecoController),
          cidade: _opcional(_cidadeController),
        ),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Dados da empresa salvos')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Minha empresa'),
      body: Consumer<MinhaEmpresaProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.empresa == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.empresa == null) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: () async {
                await provider.carregar();
                _preencher(provider.empresa);
              },
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 16,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        const SectionTitle(texto: 'DADOS DA EMPRESA'),
                        AppTextField(
                          label: 'NOME FANTASIA',
                          hintText: 'Nome da sua empresa',
                          prefixIcon: Icons.business_center_outlined,
                          controller: _nomeController,
                          validator: (valor) => validarObrigatorio(
                            valor,
                            'Informe o nome da empresa',
                          ),
                        ),
                        AppTextField(
                          label: 'RAZÃO SOCIAL',
                          hintText: 'Razão social',
                          prefixIcon: Icons.badge_outlined,
                          controller: _razaoController,
                        ),
                        AppTextField(
                          label: 'CNPJ',
                          hintText: '00.000.000/0000-00',
                          prefixIcon: Icons.numbers,
                          controller: _cnpjController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        const SectionTitle(texto: 'CONTATO E ENDEREÇO'),
                        AppTextField(
                          label: 'TELEFONE',
                          hintText: '(47) 99999-9999',
                          prefixIcon: Icons.phone_outlined,
                          controller: _telefoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        AppTextField(
                          label: 'E-MAIL',
                          hintText: 'contato@empresa.com',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        AppTextField(
                          label: 'ENDEREÇO',
                          hintText: 'Rua, número, bairro',
                          prefixIcon: Icons.location_on_outlined,
                          controller: _enderecoController,
                        ),
                        AppTextField(
                          label: 'CIDADE',
                          hintText: 'Cidade - UF',
                          prefixIcon: Icons.location_city_outlined,
                          controller: _cidadeController,
                        ),
                      ],
                    ),
                  ),
                  AppPrimaryButton(
                    label: 'Salvar',
                    carregando: _salvando,
                    onPressed: _salvar,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
