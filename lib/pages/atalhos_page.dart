import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/atalho_rapido.dart';
import 'package:texflow/providers/atalhos_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/application_app_bar.dart';

class AtalhosPage extends StatelessWidget {
  const AtalhosPage({super.key});

  static const route = AppRoutes.atalhos;

  Future<void> _escolher(BuildContext context, int posicao) async {
    final provider = context.read<AtalhosProvider>();
    final usuario = context.read<UsuarioProvider>().usuario;
    final atuais = provider.ids;

    final escolhido = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final opcoes = AtalhoRapido.catalogo
            .where((atalho) => atalho.liberadoPara(usuario))
            .toList();

        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Atalho ${posicao + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            for (final atalho in opcoes)
              ListTile(
                leading: Icon(atalho.icone, color: AppColors.navBar),
                title: Text(atalho.rotulo),
                trailing: atuais[posicao] == atalho.id
                    ? const Icon(Icons.check, color: AppColors.success)
                    : null,
                onTap: () => Navigator.pop(sheetContext, atalho.id),
              ),
          ],
        );
      },
    );

    if (escolhido != null) await provider.trocar(posicao, escolhido);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const ApplicationAppBar(title: 'Atalhos da tela inicial'),
      body: Consumer<AtalhosProvider>(
        builder: (context, provider, child) {
          final atalhos = provider.atalhos;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Escolha os 4 atalhos que aparecem na barra de baixo.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final atalho in atalhos)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(atalho.icone, color: AppColors.navBar),
                          const SizedBox(height: 4),
                          Text(
                            atalho.rotulo,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < atalhos.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _escolher(context, i),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(atalhos[i].icone, color: AppColors.primary),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Atalho ${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  atalhos[i].rotulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: provider.restaurarPadrao,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Restaurar padrão'),
              ),
            ],
          );
        },
      ),
    );
  }
}
