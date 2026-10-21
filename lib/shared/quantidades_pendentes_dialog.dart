import 'package:flutter/material.dart';

Future<void> avisarQuantidadesPendentes(
  BuildContext context, {
  required List<String> pendencias,
}) {
  const limite = 8;
  final mostradas = pendencias.take(limite).toList();
  final restantes = pendencias.length - mostradas.length;

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Falta completar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Para concluir, falta completar:'),
              const SizedBox(height: 12),
              for (final item in mostradas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $item'),
                ),
              if (restantes > 0) Text('e mais $restantes'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
}
