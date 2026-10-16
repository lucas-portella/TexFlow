import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/empresa_cliente.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/providers/admin_provider.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/modulos_switches.dart';

class PacoteModulosSheet extends StatefulWidget {
  final EmpresaCliente empresa;

  const PacoteModulosSheet({super.key, required this.empresa});

  static Future<void> abrir(BuildContext context, EmpresaCliente empresa) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PacoteModulosSheet(empresa: empresa),
    );
  }

  @override
  State<PacoteModulosSheet> createState() => _PacoteModulosSheetState();
}

class _PacoteModulosSheetState extends State<PacoteModulosSheet> {
  late Set<Modulo> _selecionados = Set.of(widget.empresa.modulos);
  bool _carregando = false;

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<AdminProvider>();

    setState(() => _carregando = true);

    try {
      await provider.alterarModulos(widget.empresa, _selecionados);
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Pacote salvo')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pacote de ${widget.empresa.nomeFantasia}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ModulosSwitches(
            selecionados: _selecionados,
            liberados: Modulo.opcionaisNoPacote,
            aoMudar: (novos) => setState(() => _selecionados = novos),
          ),
          const SizedBox(height: 12),
          AppPrimaryButton(
            label: 'Salvar pacote',
            carregando: _carregando,
            onPressed: _salvar,
          ),
        ],
      ),
    );
  }
}
