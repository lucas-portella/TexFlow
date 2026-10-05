import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/main.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/providers/operacao_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';

Map<String, dynamic> _operacaoJson({
  int id = 7,
  String status = 'emAndamento',
  String cliente = 'Moda João',
}) {
  return {
    'id': id,
    'referencia': {'id': 1, 'nome': 'MOD-FEM-045'},
    'cliente': {
      'id': 1,
      'cnpj': '12.345.678/0001-90',
      'nomeFantasia': cliente,
      'contato': {'nome': 'Ana', 'telefone': '(47) 99999-0001'},
    },
    'dataEntrega': '2026-10-15',
    'gradePedido': [
      {'descricao': 'P', 'quantidade': 60},
      {'descricao': 'M', 'quantidade': 90},
    ],
    'gradeFabricada': [
      {'descricao': 'P', 'quantidade': 30},
    ],
    'status': status,
  };
}

class FakeUsuarioProvider extends UsuarioProvider {
  Usuario? _logado = Usuario(
    idUsuario: 1,
    nome: 'Ana Carvalho',
    email: 'ana@texflow.com',
    senha: '',
    tipo: UserType.GESTOR,
  );
  int logouts = 0;

  @override
  Usuario? get usuario => _logado;

  @override
  bool get logado => _logado != null;

  @override
  Future<void> carregarUsuarioSalvo() async {}

  @override
  Future<void> logout() async {
    logouts++;
    _logado = null;
    notifyListeners();
  }
}

class FakeOperacaoProvider extends OperacaoProvider {
  final List<Operacao> lista = [
    Operacao.fromMap(_operacaoJson()),
    Operacao.fromMap(
      _operacaoJson(id: 8, status: 'concluido', cliente: 'Baby Chic'),
    ),
  ];
  int carregamentos = 0;

  @override
  List<Operacao> get operacoes => lista;

  @override
  bool get carregando => false;

  @override
  String? get erro => null;

  @override
  Future<void> carregar() async {
    carregamentos++;
  }
}

Future<(FakeUsuarioProvider, FakeOperacaoProvider)> _abrirApp(
  WidgetTester tester, {
  bool logado = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final usuario = FakeUsuarioProvider();
  if (!logado) usuario._logado = null;
  final operacao = FakeOperacaoProvider();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UsuarioProvider>.value(value: usuario),
        ChangeNotifierProvider<OperacaoProvider>.value(value: operacao),
      ],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
  return (usuario, operacao);
}

void main() {
  testWidgets('login: valida campos e esqueci minha senha, sem cadastro', (
    tester,
  ) async {
    await _abrirApp(tester, logado: false);

    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);

    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    expect(find.text('Digite seu e-mail cadastrado'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login: campo de senha alterna visibilidade', (tester) async {
    await _abrirApp(tester, logado: false);

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('dashboard: carrega pelo provider e mostra os dados', (
    tester,
  ) async {
    final (_, operacoes) = await _abrirApp(tester);

    expect(operacoes.carregamentos, 1);
    expect(find.text('Ana Carvalho'), findsOneWidget);
    expect(find.text('Moda João'), findsOneWidget);
    expect(find.text('Baby Chic'), findsOneWidget);
    expect(find.text('Em produção'), findsWidgets);
    expect(find.text('PRODUÇÕES ATIVAS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard: sair volta para o login', (tester) async {
    final (usuarios, _) = await _abrirApp(tester);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(usuarios.logouts, 1);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('rotas: barra inferior, ver todas, + e empresa', (tester) async {
    await _abrirApp(tester);

    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();
    expect(find.text('Pesquisar'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'baby');
    await tester.pumpAndSettle();
    expect(find.text('Baby Chic'), findsOneWidget);
    expect(find.text('Moda João'), findsNothing);
    expect(find.text('RESULTADOS'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nada');
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma produção encontrada'), findsOneWidget);

    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('PRODUÇÕES ATIVAS'), findsOneWidget);

    await tester.tap(find.text('Config.'));
    await tester.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Novo Pedido'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Empresa'));
    await tester.pumpAndSettle();
    expect(find.text('Tela em desenvolvimento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('card da pesquisa abre a tela de detalhes da produção', (
    tester,
  ) async {
    await _abrirApp(tester);

    await tester.tap(find.text('Pesquisa'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Moda João'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes da produção'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('RECENTES'), findsOneWidget);
  });
}
