import 'package:flutter/material.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_text_field.dart';

class SelecionarClienteSheet extends StatefulWidget {
  final Future<List<Empresa>> Function() carregar;

  const SelecionarClienteSheet({super.key, required this.carregar});

  static Future<Empresa?> abrir(
    BuildContext context, {
    required Future<List<Empresa>> Function() carregar,
  }) {
    return showModalBottomSheet<Empresa>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SelecionarClienteSheet(carregar: carregar),
    );
  }

  @override
  State<SelecionarClienteSheet> createState() => _SelecionarClienteSheetState();
}

class _SelecionarClienteSheetState extends State<SelecionarClienteSheet> {
  late Future<List<Empresa>> _clientes = widget.carregar();
  final _buscaController = TextEditingController();
  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Empresa> _filtrar(List<Empresa> clientes) {
    final termo = _busca.trim().toLowerCase();
    if (termo.isEmpty) return clientes;
    return clientes.where((cliente) {
      return cliente.nomeFantasia.toLowerCase().contains(termo) ||
          cliente.cnpj.toLowerCase().contains(termo);
    }).toList();
  }

  void _recarregar() {
    setState(() => _clientes = widget.carregar());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecionar cliente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _buscaController,
              onChanged: (valor) => setState(() => _busca = valor),
              decoration: appFieldDecoration(
                hintText: 'Buscar por nome ou CNPJ',
                prefixIcon: Icons.search,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Empresa>>(
                future: _clientes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Erro ao carregar os clientes'),
                          TextButton(
                            onPressed: _recarregar,
                            child: const Text('Tentar de novo'),
                          ),
                        ],
                      ),
                    );
                  }

                  final clientes = _filtrar(snapshot.data ?? []);

                  if (clientes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _busca.isEmpty
                                ? 'Nenhum cliente cadastrado'
                                : 'Nenhum cliente encontrado',
                          ),
                          if (_busca.isEmpty)
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.novaEmpresa,
                                );
                              },
                              child: const Text('Cadastrar cliente'),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: clientes.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          foregroundColor: AppColors.primary,
                          child: Text(
                            cliente.nomeFantasia.isEmpty
                                ? '?'
                                : cliente.nomeFantasia[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        title: Text(
                          cliente.nomeFantasia,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(cliente.cnpj),
                        onTap: () => Navigator.pop(context, cliente),
                      );
                    },
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
