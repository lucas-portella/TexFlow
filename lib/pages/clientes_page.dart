import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/providers/cliente_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/cadastro_item_tile.dart';
import 'package:texflow/shared/confirmar_exclusao.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  static const route = AppRoutes.clientes;

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClienteProvider>().carregar();
    });
  }

  Future<void> _abrirCadastro([Empresa? cliente]) async {
    final provider = context.read<ClienteProvider>();
    await Navigator.pushNamed(
      context,
      AppRoutes.novaEmpresa,
      arguments: cliente,
    );
    provider.carregar();
  }

  Future<void> _excluir(Empresa cliente) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<ClienteProvider>();

    if (!await confirmarExclusao(context, cliente.nomeFantasia)) return;

    try {
      await provider.excluir(cliente.id);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Clientes'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.white,
        tooltip: 'Novo cliente',
        onPressed: () => _abrirCadastro(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ClienteProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.clientes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.clientes.isEmpty) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.carregar,
            );
          }

          if (provider.clientes.isEmpty) {
            return const Center(child: Text('Nenhum cliente cadastrado'));
          }

          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final cliente in provider.clientes)
                  CadastroItemTile(
                    titulo: cliente.nomeFantasia,
                    subtitulo: cliente.cnpj,
                    onTap: () => _abrirCadastro(cliente),
                    onExcluir: () => _excluir(cliente),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
