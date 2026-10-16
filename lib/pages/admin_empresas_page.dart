import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/empresa_cliente.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/providers/admin_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/cadastro_item_tile.dart';
import 'package:texflow/shared/nova_empresa_sheet.dart';
import 'package:texflow/shared/pacote_modulos_sheet.dart';
import 'package:texflow/shared/redefinir_senha_dialog.dart';

class AdminEmpresasPage extends StatefulWidget {
  const AdminEmpresasPage({super.key});

  static const route = AppRoutes.admin;

  @override
  State<AdminEmpresasPage> createState() => _AdminEmpresasPageState();
}

class _AdminEmpresasPageState extends State<AdminEmpresasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().carregar();
    });
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _executar(Future<void> Function() acao, String sucesso) async {
    try {
      await acao();
      _avisar(sucesso);
    } catch (e) {
      _avisar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _abrirOpcoes(EmpresaCliente empresa) async {
    final provider = context.read<AdminProvider>();

    final escolha = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              empresa.nomeFantasia,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          ListTile(
            leading: Icon(
              empresa.ativa ? Icons.block : Icons.check_circle_outline,
              color: empresa.ativa ? AppColors.danger : AppColors.success,
            ),
            title: Text(
              empresa.ativa ? 'Desativar empresa' : 'Reativar empresa',
            ),
            subtitle: empresa.ativa
                ? const Text('Ninguém dessa empresa consegue entrar.')
                : null,
            onTap: () => Navigator.pop(sheetContext, 'ativa'),
          ),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: const Text('Redefinir senha do primeiro usuário'),
            onTap: () => Navigator.pop(sheetContext, 'senha'),
          ),
          ListTile(
            leading: const Icon(Icons.apps_outlined),
            title: const Text('Pacote de módulos'),
            subtitle: Text(
              '${empresa.modulos.length} de ${Modulo.values.length} liberados',
            ),
            onTap: () => Navigator.pop(sheetContext, 'pacote'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );

    if (!mounted || escolha == null) return;

    if (escolha == 'pacote') {
      await PacoteModulosSheet.abrir(context, empresa);
      return;
    }

    if (escolha == 'ativa') {
      await _executar(
        () => provider.alterarAtiva(empresa, !empresa.ativa),
        empresa.ativa ? 'Empresa desativada' : 'Empresa reativada',
      );
      return;
    }

    final senha = await RedefinirSenhaDialog.abrir(
      context,
      empresa.nomeFantasia,
    );
    if (senha == null) return;

    await _executar(
      () => provider.redefinirSenhaDoDono(empresa, senha),
      'Senha redefinida',
    );
  }

  void _sair() {
    context.read<AdminProvider>().sair();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Empresas do TexFlow',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: _sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.white,
        onPressed: () => NovaEmpresaSheet.abrir(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova empresa'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.empresas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.empresas.isEmpty) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.carregar,
            );
          }

          if (provider.empresas.isEmpty) {
            return const Center(child: Text('Nenhuma empresa cadastrada'));
          }

          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final empresa in provider.empresas)
                  CadastroItemTile(
                    titulo: empresa.nomeFantasia,
                    subtitulo: empresa.descricao,
                    selo: Text(
                      empresa.ativa ? 'Ativa' : 'Desativada',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: empresa.ativa
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                    onTap: () => _abrirOpcoes(empresa),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
