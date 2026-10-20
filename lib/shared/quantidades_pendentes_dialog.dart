import 'package:flutter/material.dart';

Future<bool> confirmarQuantidadesPendentes(
  BuildContext context, {
  required int quantidade,
  required List<String> pendencias,
}) async {
  const limite = 6;
  final mostradas = pendencias.take(limite).toList();
  final restantes = pendencias.length - mostradas.length;

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Peças sem informar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ao concluir, as $quantidade peças informadas agora serão atribuídas a quem ainda não tem peças na etapa:',
              ),
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Concluir'),
          ),
        ],
      );
    },
  );

  return confirmado ?? false;
}
