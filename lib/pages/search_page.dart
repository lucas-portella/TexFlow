import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/providers/operacao_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_error_message.dart';
import 'package:texflow/shared/app_main_scaffold.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/production_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const route = AppRoutes.pesquisa;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _buscaController = TextEditingController();
  String _busca = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperacaoProvider>().carregar();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Operacao> _filtrar(List<Operacao> operacoes) {
    final termo = _busca.trim().toLowerCase();
    if (termo.isEmpty) return operacoes;

    return operacoes.where((operacao) {
      final cliente = operacao.cliente?.nomeFantasia.toLowerCase() ?? '';
      final referencia = operacao.referencia?.nome.toLowerCase() ?? '';
      final codigo = 'op-${operacao.id}';
      return cliente.contains(termo) ||
          referencia.contains(termo) ||
          codigo.contains(termo);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppMainScaffold(
      current: SearchPage.route,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pesquisar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _buscaController,
              onChanged: (valor) => setState(() => _busca = valor),
              decoration: appFieldDecoration(
                hintText: 'Produções, pedidos, clientes...',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _busca.trim().isEmpty ? 'RECENTES' : 'RESULTADOS',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<OperacaoProvider>(
                builder: (context, provider, child) {
                  if (provider.carregando && provider.operacoes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.erro != null && provider.operacoes.isEmpty) {
                    return AppErrorMessage(
                      mensagem: provider.erro!,
                      onRetry: provider.carregar,
                    );
                  }

                  final operacoes = _filtrar(provider.operacoes);

                  if (operacoes.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma produção encontrada'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: provider.carregar,
                    child: ListView.separated(
                      itemCount: operacoes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          ProductionCard(operacao: operacoes[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
