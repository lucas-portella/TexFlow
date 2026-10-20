import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';

Future<Map<int, int>?> pedirQuantidadesDaEtapa(
  BuildContext context,
  ProcessoProdutivo processo,
) {
  return showModalBottomSheet<Map<int, int>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _QuantidadesDaEtapaSheet(processo: processo),
  );
}

class _QuantidadesDaEtapaSheet extends StatefulWidget {
  final ProcessoProdutivo processo;

  const _QuantidadesDaEtapaSheet({required this.processo});

  @override
  State<_QuantidadesDaEtapaSheet> createState() =>
      _QuantidadesDaEtapaSheetState();
}

class _QuantidadesDaEtapaSheetState extends State<_QuantidadesDaEtapaSheet> {
  late final Map<int, TextEditingController> _campos = {
    for (final funcionario in widget.processo.funcionarios)
      funcionario.id: TextEditingController(
        text: widget.processo.quantidades[funcionario.id]?.toString(),
      ),
  };

  @override
  void dispose() {
    for (final campo in _campos.values) {
      campo.dispose();
    }
    super.dispose();
  }

  void _salvar() {
    final quantidades = <int, int>{};
    for (final entrada in _campos.entries) {
      final valor = int.tryParse(entrada.value.text.trim());
      if (valor != null) quantidades[entrada.key] = valor;
    }
    Navigator.pop(context, quantidades);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(
            'Peças por responsável',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Text(
            widget.processo.descricao,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          for (final funcionario in widget.processo.funcionarios)
            AppTextField(
              label: funcionario.nome.toUpperCase(),
              hintText: 'Peças',
              prefixIcon: Icons.checkroom_outlined,
              controller: _campos[funcionario.id]!,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          AppPrimaryButton(label: 'Salvar', onPressed: _salvar),
        ],
      ),
    );
  }
}
