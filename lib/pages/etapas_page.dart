import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/cadastro_item_tile.dart';
import 'package:texflow/shared/confirmar_exclusao.dart';
import 'package:texflow/shared/etapa_form_sheet.dart';
import 'package:texflow/shared/formatters.dart';

class EtapasPage extends StatefulWidget {
  const EtapasPage({super.key});

  static const route = AppRoutes.etapas;

  @override
  State<EtapasPage> createState() => _EtapasPageState();
}

class _EtapasPageState extends State<EtapasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EtapaProvider>().carregar();
    });
  }

  Future<void> _excluir(Etapa etapa) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<EtapaProvider>();

    if (!await confirmarExclusao(context, etapa.nome)) return;

    try {
      await provider.excluir(etapa.id);
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
      appBar: const ApplicationAppBar(title: 'Etapas'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.white,
        onPressed: () => EtapaFormSheet.abrir(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<EtapaProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.etapas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.etapas.isEmpty) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.carregar,
            );
          }

          if (provider.etapas.isEmpty) {
            return const Center(child: Text('Nenhuma etapa cadastrada'));
          }

          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final etapa in provider.etapas)
                  CadastroItemTile(
                    titulo: etapa.nome,
                    subtitulo: '${formatarMoeda(etapa.valorComissao)} por peça',
                    onTap: () => EtapaFormSheet.abrir(context, etapa: etapa),
                    onExcluir: () => _excluir(etapa),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
