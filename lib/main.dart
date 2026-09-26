import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/pages/dashboard_page.dart';
import 'package:texflow/pages/login_page.dart';
import 'package:texflow/providers/usuario_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UsuarioProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TexFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppStartup(),
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  late Future<void> _carregamento;

  @override
  void initState() {
    super.initState();
    _carregamento = context.read<UsuarioProvider>().carregarUsuarioSalvo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _carregamento,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final logado = context.watch<UsuarioProvider>().logado;
        return const LoginPage();
        // return logado ? const DashboardPage() : const LoginPage();
      },
    );
  }
}
