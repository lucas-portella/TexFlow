import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:texflow/shared/app_text_field.dart';

Future<int?> pedirQuantidadeProduzida(BuildContext context, {int? sugestao}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _FinalizarProducaoDialog(sugestao: sugestao),
  );
}

class _FinalizarProducaoDialog extends StatefulWidget {
  final int? sugestao;

  const _FinalizarProducaoDialog({this.sugestao});

  @override
  State<_FinalizarProducaoDialog> createState() =>
      _FinalizarProducaoDialogState();
}

class _FinalizarProducaoDialogState extends State<_FinalizarProducaoDialog> {
  late final _controller = TextEditingController(
    text: widget.sugestao?.toString(),
  );
  String? _erro;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    final valor = int.tryParse(_controller.text);
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe uma quantidade maior que zero');
      return;
    }
    Navigator.pop(context, valor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Finalizar produção'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informe o total de peças que foram produzidas. Esse valor '
            'define o repasse de cada funcionário e o fechamento do mês.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: appFieldDecoration(
              hintText: 'Total de peças produzidas',
              prefixIcon: Icons.inventory_2_outlined,
            ).copyWith(errorText: _erro),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _confirmar, child: const Text('Finalizar')),
      ],
    );
  }
}
