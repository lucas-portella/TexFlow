import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/cor.dart';
import 'package:texflow/providers/cor_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/cadastro_item_tile.dart';
import 'package:texflow/shared/confirmar_exclusao.dart';
import 'package:texflow/shared/cor_form_sheet.dart';
import 'package:texflow/shared/cor_quadradinho.dart';

class CoresPage extends StatefulWidget {
  const CoresPage({super.key});

  static const route = AppRoutes.cores;

  @override
  State<CoresPage> createState() => _CoresPageState();
}

class _CoresPageState extends State<CoresPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CorProvider>().carregar();
    });
  }

  Future<void> _excluir(Cor cor) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<CorProvider>();

    if (!await confirmarExclusao(context, cor.nome)) return;

    try {
      await provider.excluir(cor.id);
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
      appBar: const ApplicationAppBar(title: 'Cores'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.white,
        tooltip: 'Nova cor',
        onPressed: () => CorFormSheet.abrir(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<CorProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.cores.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.cores.isEmpty) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.carregar,
            );
          }

          if (provider.cores.isEmpty) {
            return const Center(child: Text('Nenhuma cor cadastrada'));
          }

          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final cor in provider.cores)
                  CadastroItemTile(
                    titulo: cor.nome,
                    subtitulo: cor.hex,
                    selo: CorQuadradinho(cor: cor, tamanho: 18),
                    onTap: () => CorFormSheet.abrir(context, cor: cor),
                    onExcluir: () => _excluir(cor),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
