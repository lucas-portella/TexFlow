import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/tamanho.dart';
import 'package:texflow/providers/tamanho_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/cadastro_item_tile.dart';
import 'package:texflow/shared/confirmar_exclusao.dart';
import 'package:texflow/shared/tamanho_form_sheet.dart';

class TamanhosPage extends StatefulWidget {
  const TamanhosPage({super.key});

  static const route = AppRoutes.tamanhos;

  @override
  State<TamanhosPage> createState() => _TamanhosPageState();
}

class _TamanhosPageState extends State<TamanhosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TamanhoProvider>().carregar();
    });
  }

  Future<void> _excluir(Tamanho tamanho) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<TamanhoProvider>();

    if (!await confirmarExclusao(context, tamanho.nome)) return;

    try {
      await provider.excluir(tamanho.id);
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
      appBar: const ApplicationAppBar(title: 'Tamanhos'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.white,
        tooltip: 'Novo tamanho',
        onPressed: () => TamanhoFormSheet.abrir(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<TamanhoProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.tamanhos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.tamanhos.isEmpty) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.carregar,
            );
          }

          if (provider.tamanhos.isEmpty) {
            return const Center(child: Text('Nenhum tamanho cadastrado'));
          }

          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final tamanho in provider.tamanhos)
                  CadastroItemTile(
                    titulo: tamanho.nome,
                    onTap: () =>
                        TamanhoFormSheet.abrir(context, tamanho: tamanho),
                    onExcluir: () => _excluir(tamanho),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
