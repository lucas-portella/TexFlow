import 'package:flutter/material.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/services/operacao_service.dart';
import 'package:texflow/shared/app_bottom_nav.dart';
import 'package:texflow/shared/production_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Operacao>> _operacoesFuture;
  final _buscaController = TextEditingController();
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _operacoesFuture = OperacaoService.listar();
  }

  List<Operacao> _filtrar(List<Operacao> operacoes) {
    if (_busca.isEmpty) return operacoes;

    final termo = _busca.toLowerCase();
    return operacoes.where((operacao) {
      final cliente = operacao.cliente?.nomeFantasia.toLowerCase() ?? '';
      final referencia = operacao.referencia?.nome.toLowerCase() ?? '';
      return cliente.contains(termo) || referencia.contains(termo);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
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
                decoration: InputDecoration(
                  hintText: 'Produções, pedidos, clientes...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'RECENTES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Operacao>>(
                  future: _operacoesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Erro ao carregar: ${snapshot.error}'),
                      );
                    }

                    final operacoes = _filtrar(snapshot.data ?? []);

                    if (operacoes.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma produção encontrada'),
                      );
                    }

                    return ListView.separated(
                      itemCount: operacoes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          ProductionCard(operacao: operacoes[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: 'pesquisa'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E2340),
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
