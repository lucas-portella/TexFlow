import 'package:flutter/material.dart';
import 'package:texflow/models/empresa.dart';
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
  final Empresa? empresa;

  const CadastroEmpresaPage({super.key, this.empresa});

  static const route = AppRoutes.novaEmpresa;

  @override
  State<CadastroEmpresaPage> createState() => _CadastroEmpresaPageState();
}

class _CadastroEmpresaPageState extends State<CadastroEmpresaPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(
    text: widget.empresa?.nomeFantasia,
  );
  late final _cnpjController = TextEditingController(text: widget.empresa?.cnpj);
  late final _responsavelController = TextEditingController(
    text: widget.empresa?.contatoNome,
  );
  late final _telefoneController = TextEditingController(
    text: widget.empresa?.contatoTelefone,
  );
  bool _carregando = false;

  bool get _editando => widget.empresa != null;

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
      if (_editando) {
        await EmpresaService.atualizar(
          id: widget.empresa!.id,
          nomeFantasia: _nomeController.text.trim(),
          cnpj: _cnpjController.text,
          contatoNome: _responsavelController.text.trim(),
          contatoTelefone: _telefoneController.text,
        );
      } else {
        await EmpresaService.criar(
          nomeFantasia: _nomeController.text.trim(),
          cnpj: _cnpjController.text,
          contatoNome: _responsavelController.text.trim(),
          contatoTelefone: _telefoneController.text,
        );
      }

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Cliente atualizado com sucesso'
                : 'Cliente cadastrado com sucesso',
          ),
        ),
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
      appBar: ApplicationAppBar(
        title: _editando ? 'Alterar cliente' : 'Cadastrar cliente',
      ),
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
                    const SectionTitle(texto: 'DADOS DO CLIENTE'),
                    AppTextField(
                      label: 'NOME DO CLIENTE',
                      hintText: 'Ex.: Alfa Costuras Ltda.',
                      prefixIcon: Icons.business_center_outlined,
                      controller: _nomeController,
                      validator: (valor) =>
                          validarObrigatorio(valor, 'Digite o nome do cliente'),
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
                label: _editando ? 'Salvar' : 'Cadastrar cliente',
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
