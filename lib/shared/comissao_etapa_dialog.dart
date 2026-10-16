import 'package:flutter/material.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/formatters.dart';

Future<double?> pedirComissaoDaEtapa(
  BuildContext context, {
  required String etapa,
  required double valorAtual,
}) {
  return showDialog<double>(
    context: context,
    builder: (context) =>
        _ComissaoEtapaDialog(etapa: etapa, valorAtual: valorAtual),
  );
}

class _ComissaoEtapaDialog extends StatefulWidget {
  final String etapa;
  final double valorAtual;

  const _ComissaoEtapaDialog({required this.etapa, required this.valorAtual});

  @override
  State<_ComissaoEtapaDialog> createState() => _ComissaoEtapaDialogState();
}

class _ComissaoEtapaDialogState extends State<_ComissaoEtapaDialog> {
  late final _controller = TextEditingController(
    text: widget.valorAtual.toStringAsFixed(2).replaceAll('.', ','),
  );
  String? _erro;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    final valor = lerValor(_controller.text);
    if (valor == null || valor < 0) {
      setState(() => _erro = 'Informe um valor válido');
      return;
    }
    Navigator.pop(context, valor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Comissão de ${widget.etapa}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: appFieldDecoration(
              hintText: '0,30',
              prefixIcon: Icons.payments_outlined,
            ).copyWith(errorText: _erro),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _confirmar, child: const Text('Salvar')),
      ],
    );
  }
}
