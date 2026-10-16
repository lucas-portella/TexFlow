import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:texflow/shared/app_text_field.dart';

class DadosDaFinalizacao {
  final int quantidade;
  final DateTime dataEntrega;

  const DadosDaFinalizacao({
    required this.quantidade,
    required this.dataEntrega,
  });
}

Future<DadosDaFinalizacao?> pedirDadosDaFinalizacao(
  BuildContext context, {
  int? sugestao,
}) {
  return showDialog<DadosDaFinalizacao>(
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
  late final _quantidadeController = TextEditingController(
    text: widget.sugestao?.toString(),
  );
  late final _dataController = TextEditingController(text: _paraTela(_data));
  late DateTime _data = _hoje();
  String? _erro;

  static DateTime _hoje() {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  static String _paraTela(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: _hoje(),
    );
    if (escolhida == null) return;

    setState(() {
      _data = escolhida;
      _dataController.text = _paraTela(escolhida);
    });
  }

  void _confirmar() {
    final valor = int.tryParse(_quantidadeController.text);
    if (valor == null || valor <= 0) {
      setState(() => _erro = 'Informe uma quantidade maior que zero');
      return;
    }
    Navigator.pop(
      context,
      DadosDaFinalizacao(quantidade: valor, dataEntrega: _data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Finalizar produção'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informe quando a produção foi entregue e o total de peças '
              'produzidas. A data define o mês do fechamento e as peças '
              'definem o repasse de cada funcionário.',
            ),
            const SizedBox(height: 16),
            const AppFieldLabel('DATA DE ENTREGA'),
            TextField(
              controller: _dataController,
              readOnly: true,
              onTap: _escolherData,
              decoration: appFieldDecoration(
                hintText: 'DD/MM/AAAA',
                prefixIcon: Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(height: 16),
            const AppFieldLabel('PEÇAS PRODUZIDAS'),
            TextField(
              controller: _quantidadeController,
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
