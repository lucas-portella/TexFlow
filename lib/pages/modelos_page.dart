import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/cadastro_item_tile.dart';
import 'package:texflow/shared/confirmar_exclusao.dart';

class ModelosPage extends StatefulWidget {
  const ModelosPage({super.key});

  static const route = AppRoutes.modelos;

  @override
  State<ModelosPage> createState() => _ModelosPageState();
}

class _ModelosPageState extends State<ModelosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModeloProvider>().carregar();
    });
  }

  Future<void> _excluir(Referencia modelo) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<ModeloProvider>();

    if (!await confirmarExclusao(context, modelo.nome)) return;

    try {
      await provider.excluir(modelo.id);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  String _resumoEtapas(Referencia modelo) {
    if (modelo.etapas.isEmpty) return 'Nenhuma etapa';
    return modelo.etapas.map((etapa) => etapa.nome).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Modelos'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.white,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.modeloForm),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ModeloProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.modelos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.modelos.isEmpty) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.carregar,
            );
          }

          if (provider.modelos.isEmpty) {
            return const Center(child: Text('Nenhum modelo cadastrado'));
          }

          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final modelo in provider.modelos)
                  CadastroItemTile(
                    titulo: modelo.nome,
                    subtitulo: _resumoEtapas(modelo),
                    selo: modelo.ativo
                        ? null
                        : const Text(
                            'Inativo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            ),
                          ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.modeloForm,
                      arguments: modelo,
                    ),
                    onExcluir: () => _excluir(modelo),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
