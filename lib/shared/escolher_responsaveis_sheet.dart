import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/funcionario_form_sheet.dart';

Future<List<Funcionario>?> escolherResponsaveis(
  BuildContext context, {
  required String titulo,
  required List<Funcionario> selecionados,
}) {
  return showModalBottomSheet<List<Funcionario>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EscolherResponsaveisSheet(
      titulo: titulo,
      selecionados: selecionados,
    ),
  );
}

class _EscolherResponsaveisSheet extends StatefulWidget {
  final String titulo;
  final List<Funcionario> selecionados;

  const _EscolherResponsaveisSheet({
    required this.titulo,
    required this.selecionados,
  });

  @override
  State<_EscolherResponsaveisSheet> createState() =>
      _EscolherResponsaveisSheetState();
}

class _EscolherResponsaveisSheetState
    extends State<_EscolherResponsaveisSheet> {
  late final List<int> _ids = widget.selecionados.map((item) => item.id).toList();

  void _alternar(Funcionario funcionario, bool marcado) {
    setState(() {
      if (marcado) {
        _ids.add(funcionario.id);
      } else {
        _ids.remove(funcionario.id);
      }
    });
  }

  List<Funcionario> _resultado(List<Funcionario> ativos) {
    final porId = {
      for (final item in [...widget.selecionados, ...ativos]) item.id: item,
    };
    return [
      for (final id in _ids)
        if (porId[id] != null) porId[id]!,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FuncionarioProvider>();

    if (provider.carregando && provider.funcionarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.ativos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Não há funcionários ativos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => FuncionarioFormSheet.abrir(context),
              child: const Text('Cadastrar funcionário'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              widget.titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final funcionario in provider.ativos)
                  CheckboxListTile(
                    value: _ids.contains(funcionario.id),
                    onChanged: (marcado) =>
                        _alternar(funcionario, marcado ?? false),
                    secondary: const Icon(Icons.person_outline),
                    title: Text(funcionario.nome),
                    subtitle: funcionario.cargo == null
                        ? null
                        : Text(funcionario.cargo!),
                  ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Cadastrar funcionário'),
                  onTap: () => FuncionarioFormSheet.abrir(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: AppPrimaryButton(
              label: _ids.isEmpty ? 'Confirmar' : 'Confirmar (${_ids.length})',
              onPressed: _ids.isEmpty
                  ? null
                  : () => Navigator.pop(context, _resultado(provider.ativos)),
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsaveisField extends FormField<List<Funcionario>> {
  ResponsaveisField({
    super.key,
    required List<Funcionario> selecionados,
    required ValueChanged<List<Funcionario>> aoMudar,
  }) : super(
         initialValue: selecionados,
         validator: (valor) => (valor == null || valor.isEmpty)
             ? 'Escolha pelo menos um responsável'
             : null,
         builder: (state) {
           final escolhidos = state.value ?? const <Funcionario>[];

           Future<void> abrir() async {
             final novos = await escolherResponsaveis(
               state.context,
               titulo: 'Responsáveis pela etapa',
               selecionados: escolhidos,
             );
             if (novos == null) return;
             state.didChange(novos);
             aoMudar(novos);
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const AppFieldLabel('RESPONSÁVEIS'),
               InkWell(
                 onTap: abrir,
                 borderRadius: BorderRadius.circular(14),
                 child: InputDecorator(
                   decoration: appFieldDecoration(
                     hintText: 'Escolha os funcionários',
                     prefixIcon: Icons.person_outline,
                   ).copyWith(
                     errorText: state.errorText,
                     suffixIcon: const Icon(Icons.arrow_drop_down),
                   ),
                   isEmpty: escolhidos.isEmpty,
                   child: Text(
                     escolhidos.map((item) => item.nome).join(', '),
                     style: const TextStyle(fontSize: 14, color: Colors.black),
                   ),
                 ),
               ),
             ],
           );
         },
       );
}
