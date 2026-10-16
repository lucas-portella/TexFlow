import 'package:flutter/material.dart';

class RedefinirSenhaDialog extends StatefulWidget {
  final String empresa;

  const RedefinirSenhaDialog({super.key, required this.empresa});

  static Future<String?> abrir(BuildContext context, String empresa) {
    return showDialog<String>(
      context: context,
      builder: (context) => RedefinirSenhaDialog(empresa: empresa),
    );
  }

  @override
  State<RedefinirSenhaDialog> createState() => _RedefinirSenhaDialogState();
}

class _RedefinirSenhaDialogState extends State<RedefinirSenhaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Redefinir senha'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _senhaController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nova senha do primeiro usuário de ${widget.empresa}',
          ),
          validator: (valor) => (valor == null || valor.length < 6)
              ? 'A senha precisa ter pelo menos 6 caracteres'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, _senhaController.text);
          },
          child: const Text('Redefinir'),
        ),
      ],
    );
  }
}
