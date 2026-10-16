import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/modo_operacao.dart';
import 'package:texflow/providers/preferencias_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/application_app_bar.dart';

class ModoOperacaoPage extends StatelessWidget {
  const ModoOperacaoPage({super.key});

  static const route = AppRoutes.modoOperacao;

  Future<void> _escolher(BuildContext context, ModoOperacao modo) async {
    final provider = context.read<PreferenciasProvider>();
    if (provider.modoOperacao == modo) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.alterarModoOperacao(modo);
      messenger.showSnackBar(
        SnackBar(content: Text('Modo de operação: ${modo.rotulo}')),
      );
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
      appBar: const ApplicationAppBar(title: 'Modo de operação'),
      body: Consumer<PreferenciasProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Escolha como as produções avançam até a finalização.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              for (final modo in ModoOperacao.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _escolher(context, modo),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            modo == provider.modoOperacao
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: modo == provider.modoOperacao
                                ? AppColors.primary
                                : AppColors.muted,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  modo.rotulo,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  modo.descricao,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
