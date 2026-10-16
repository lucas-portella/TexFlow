import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/providers/usuarios_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/cadastro_item_tile.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  static const route = AppRoutes.usuarios;

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuariosProvider>().carregar();
    });
  }

  Future<void> _novo() async {
    final provider = context.read<UsuariosProvider>();
    await Navigator.pushNamed(context, AppRoutes.novoUsuario);
    provider.carregar();
  }

  Future<void> _abrir(Usuario usuario) async {
    final provider = context.read<UsuariosProvider>();
    await Navigator.pushNamed(
      context,
      AppRoutes.novoUsuario,
      arguments: usuario,
    );
    provider.carregar();
  }

  String _resumo(Usuario usuario) {
    if (usuario.donoDaEmpresa) return 'Acessa tudo';
    final total = usuario.modulos.length;
    if (total == 0) return 'Somente produções';
    return '$total ${total == 1 ? 'acesso liberado' : 'acessos liberados'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Usuários'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.white,
        onPressed: _novo,
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
      body: Consumer<UsuariosProvider>(
        builder: (context, provider, child) {
          if (provider.carregando && provider.usuarios.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null && provider.usuarios.isEmpty) {
            return AppErrorMessage(
              mensagem: provider.erro!,
              onRetry: provider.carregar,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final usuario in provider.usuarios)
                  CadastroItemTile(
                    titulo: usuario.nome,
                    subtitulo:
                        '${usuario.descricaoDoPerfil} · ${_resumo(usuario)}',
                    selo: usuario.donoDaEmpresa
                        ? const Text(
                            'Principal',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                    onTap: () => _abrir(usuario),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
