import 'package:flutter/material.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/services/empresa_service.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/section_title.dart';
import 'package:texflow/shared/validators.dart';

class CadastroEmpresaPage extends StatefulWidget {
  const CadastroEmpresaPage({super.key});

  static const route = AppRoutes.novaEmpresa;

  @override
  State<CadastroEmpresaPage> createState() => _CadastroEmpresaPageState();
}

class _CadastroEmpresaPageState extends State<CadastroEmpresaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _telefoneController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _responsavelController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await EmpresaService.criar(
        nomeFantasia: _nomeController.text.trim(),
        cnpj: _cnpjController.text,
        contatoNome: _responsavelController.text.trim(),
        contatoTelefone: _telefoneController.text,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Empresa cadastrada com sucesso')),
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
      appBar: const ApplicationAppBar(title: 'Cadastrar Empresa'),
      body: SingleChildScrollView(
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
                      label: 'NOME DA EMPRESA',
                      hintText: 'Ex.: Alfa Costuras Ltda.',
                      prefixIcon: Icons.business_center_outlined,
                      controller: _nomeController,
                      validator: (valor) =>
                          validarObrigatorio(valor, 'Digite o nome da empresa'),
                    ),
                    AppTextField(
                      label: 'CNPJ',
                      hintText: '00.000.000/0000-00',
                      prefixIcon: Icons.calendar_today_outlined,
                      controller: _cnpjController,
                      keyboardType: TextInputType.number,
                      validator: (valor) =>
                          validarObrigatorio(valor, 'Digite o CNPJ'),
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
                    const SectionTitle(texto: 'CONTATO'),
                    AppTextField(
                      label: 'NOME DO RESPONSÁVEL',
                      hintText: 'Ex.: João Silva',
                      prefixIcon: Icons.person_outline,
                      controller: _responsavelController,
                      validator: (valor) => validarObrigatorio(
                        valor,
                        'Digite o nome do responsável',
                      ),
                    ),
                    AppTextField(
                      label: 'TELEFONE',
                      hintText: '(11) 99999-9999',
                      prefixIcon: Icons.phone_outlined,
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      validator: (valor) =>
                          validarObrigatorio(valor, 'Digite o telefone'),
                    ),
                  ],
                ),
              ),
              AppPrimaryButton(
                label: 'Cadastrar empresa',
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
