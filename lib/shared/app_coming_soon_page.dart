import 'package:flutter/material.dart';
import 'package:texflow/shared/application_app_bar.dart';

class AppComingSoonPage extends StatelessWidget {
  final String titulo;

  const AppComingSoonPage({super.key, this.titulo = 'Em breve'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationAppBar(title: titulo),
      body: const Center(child: Text('Tela em desenvolvimento')),
    );
  }
}
