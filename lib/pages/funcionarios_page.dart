import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/cadastro_item_tile.dart';
import 'package:texflow/shared/confirmar_exclusao.dart';
import 'package:texflow/shared/funcionario_form_sheet.dart';

class FuncionariosPage extends StatefulWidget {
  const FuncionariosPage({super.key});

  static const route = AppRoutes.funcionarios;

  @override
  State<FuncionariosPage> createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends State<FuncionariosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FuncionarioProvider>().carregar();
    });
  }

  Future<void> _excluir(Funcionario funcionario) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<FuncionarioProvider>();

    if (!await confirmarExclusao(context, funcionario.nome)) return;

    try {
      await provider.excluir(funcionario.id);
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
      appBar: const ApplicationAppBar(title: 'Funcionários'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.white,
        onPressed: () => FuncionarioFormSheet.abrir(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<FuncionarioProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.funcionarios.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.funcionarios.isEmpty) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.carregar,
            );
          }

          if (provider.funcionarios.isEmpty) {
            return const Center(child: Text('Nenhum funcionário cadastrado'));
          }

          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final funcionario in provider.funcionarios)
                  CadastroItemTile(
                    titulo: funcionario.nome,
                    subtitulo: funcionario.cargo,
                    selo: funcionario.ativo
                        ? null
                        : const Text(
                            'Inativo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            ),
                          ),
                    onTap: () => FuncionarioFormSheet.abrir(
                      context,
                      funcionario: funcionario,
                    ),
                    onExcluir: () => _excluir(funcionario),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
