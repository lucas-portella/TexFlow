import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class OpcaoFiltro<T> {
  final String rotulo;
  final T valor;
  final Widget? icone;

  const OpcaoFiltro({required this.rotulo, required this.valor, this.icone});
}

class ResultadoFiltro<T> {
  final T? valor;

  const ResultadoFiltro(this.valor);
}

Future<ResultadoFiltro<T>?> abrirOpcoesDeFiltro<T>(
  BuildContext context, {
  required String titulo,
  required List<OpcaoFiltro<T>> opcoes,
  required T? selecionado,
  String textoTodos = 'Todos',
}) {
  return showModalBottomSheet<ResultadoFiltro<T>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ListTile(
              title: Text(textoTodos),
              trailing: selecionado == null
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () =>
                  Navigator.pop(sheetContext, ResultadoFiltro<T>(null)),
            ),
            for (final opcao in opcoes)
              ListTile(
                leading: opcao.icone,
                title: Text(opcao.rotulo),
                trailing: selecionado == opcao.valor
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(
                  sheetContext,
                  ResultadoFiltro<T>(opcao.valor),
                ),
              ),
            if (opcoes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhuma opção disponível ainda.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
          ],
        ),
      );
    },
  );
}
