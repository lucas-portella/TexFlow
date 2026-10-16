import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/pages/dashboard_page.dart';
import 'package:texflow/pages/login_page.dart';
import 'package:texflow/providers/admin_provider.dart';
import 'package:texflow/providers/atalhos_provider.dart';
import 'package:texflow/providers/cliente_provider.dart';
import 'package:texflow/providers/custo_provider.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/providers/fechamento_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/logs_provider.dart';
import 'package:texflow/providers/minha_empresa_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';
import 'package:texflow/providers/operacao_provider.dart';
import 'package:texflow/providers/preferencias_provider.dart';
import 'package:texflow/providers/relatorios_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/providers/usuarios_provider.dart';
import 'package:texflow/routes/app_router.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => OperacaoProvider()),
        ChangeNotifierProvider(create: (_) => NewOperationPageProvider()),
        ChangeNotifierProvider(create: (_) => EtapaProvider()),
        ChangeNotifierProvider(create: (_) => FuncionarioProvider()),
        ChangeNotifierProvider(create: (_) => ModeloProvider()),
        ChangeNotifierProvider(create: (_) => FechamentoProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => CustoProvider()),
        ChangeNotifierProvider(create: (_) => LogsProvider()),
        ChangeNotifierProvider(create: (_) => RelatoriosProvider()),
        ChangeNotifierProvider(create: (_) => UsuariosProvider()),
        ChangeNotifierProvider(create: (_) => MinhaEmpresaProvider()),
        ChangeNotifierProvider(create: (_) => AtalhosProvider()..carregar()),
        ChangeNotifierProvider(
          create: (_) => PreferenciasProvider()..carregar(),
        ),
      ],
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
        fontFamily: 'DM Sans',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      navigatorKey: AppRouter.navigatorKey,
      routes: AppRouter.routes,
      onUnknownRoute: AppRouter.rotaDesconhecida,
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

        return Consumer<UsuarioProvider>(
          builder: (context, usuarioProvider, child) {
            return usuarioProvider.logado
                ? const DashboardPage()
                : const LoginPage();
          },
        );
      },
    );
  }
}
