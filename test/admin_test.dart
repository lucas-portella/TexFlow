import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/empresa_cliente.dart';
import 'package:texflow/pages/login_page.dart';
import 'package:texflow/providers/admin_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_router.dart';
import 'package:texflow/routes/app_routes.dart';

class FakeUsuarioProvider extends UsuarioProvider {
  final List<List<String>> logins = [];

  @override
  Future<void> login(String email, String senha) async {
    logins.add([email, senha]);
  }
}

class FakeAdminProvider extends AdminProvider {
  final List<List<String>> entradas = [];
  final List<String> criadas = [];
  final List<String> alteracoes = [];
  final List<String> senhas = [];
  bool falhar = false;

  List<EmpresaCliente> lista = [
    EmpresaCliente(
      id: 1,
      nomeFantasia: 'Confecções Alfa',
      ativa: true,
      totalUsuarios: 3,
      donoNome: 'Ana',
      donoEmail: 'ana@alfa.com',
    ),
    EmpresaCliente(
      id: 2,
      nomeFantasia: 'Malhas Beta',
      ativa: false,
      totalUsuarios: 1,
    ),
  ];

  @override
  List<EmpresaCliente> get empresas => lista;

  @override
  Future<void> entrar(String usuario, String codigo) async {
    entradas.add([usuario, codigo]);
    if (falhar) throw Exception('Usuario ou codigo invalidos');
  }

  @override
  Future<void> carregar() async {}

  @override
  Future<void> criar({
    required String nomeFantasia,
    String? cnpj,
    required String usuarioNome,
    required String usuarioEmail,
    required String usuarioSenha,
  }) async {
    criadas.add('$nomeFantasia|$usuarioNome|$usuarioEmail|$usuarioSenha');
  }

  @override
  Future<void> alterarAtiva(EmpresaCliente empresa, bool ativa) async {
    alteracoes.add('${empresa.nomeFantasia}=$ativa');
  }

  @override
  Future<void> redefinirSenhaDoDono(
    EmpresaCliente empresa,
    String senha,
  ) async {
    senhas.add('${empresa.nomeFantasia}=$senha');
  }
}

Future<(FakeUsuarioProvider, FakeAdminProvider)> _abrirLogin(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final usuario = FakeUsuarioProvider();
  final admin = FakeAdminProvider();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UsuarioProvider>.value(value: usuario),
        ChangeNotifierProvider<AdminProvider>.value(value: admin),
      ],
      child: MaterialApp(
        routes: {
          ...AppRouter.routes,
          AppRoutes.dashboard: (context) => const Text('Tela inicial'),
        },
        home: const LoginPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (usuario, admin);
}

Future<void> _entrarComo(
  WidgetTester tester,
  String usuario,
  String senha,
) async {
  final campos = find.byType(TextFormField);
  await tester.enterText(campos.at(0), usuario);
  await tester.enterText(campos.at(1), senha);
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();
}

void main() {
  test('EmpresaCliente lê o JSON do painel', () {
    final empresa = EmpresaCliente.fromMap({
      'id': 5,
      'nomeFantasia': 'Alfa',
      'ativa': false,
      'totalUsuarios': 2,
      'donoNome': 'Ana',
      'donoEmail': 'ana@alfa.com',
    });

    expect(empresa.id, 5);
    expect(empresa.ativa, isFalse);
    expect(empresa.descricao, 'Ana · ana@alfa.com · 2 usuário(s)');
    expect(
      EmpresaCliente.fromMap({'id': 1, 'nomeFantasia': 'B'}).descricao,
      '0 usuário(s)',
    );
  });

  testWidgets('usuário com e-mail entra como usuário comum', (tester) async {
    final (usuario, admin) = await _abrirLogin(tester);

    await _entrarComo(tester, 'ana@alfa.com', 'Senha123!');

    expect(usuario.logins, [
      ['ana@alfa.com', 'Senha123!'],
    ]);
    expect(admin.entradas, isEmpty);
    expect(find.text('Tela inicial'), findsOneWidget);
  });

  testWidgets('usuário sem @ e código de 6 dígitos entra no painel do admin', (
    tester,
  ) async {
    final (usuario, admin) = await _abrirLogin(tester);

    await _entrarComo(tester, 'admin.emee18', '123456');

    expect(admin.entradas, [
      ['admin.emee18', '123456'],
    ]);
    expect(usuario.logins, isEmpty);
    expect(find.text('Empresas do TexFlow'), findsOneWidget);
    expect(find.text('Confecções Alfa'), findsOneWidget);
    expect(find.text('Ana · ana@alfa.com · 3 usuário(s)'), findsOneWidget);
    expect(find.text('Ativa'), findsOneWidget);
    expect(find.text('Desativada'), findsOneWidget);
  });

  testWidgets('código errado mostra o erro e continua no login', (
    tester,
  ) async {
    final (_, admin) = await _abrirLogin(tester);
    admin.falhar = true;

    await _entrarComo(tester, 'admin.emee18', '000000');

    expect(find.text('Usuario ou codigo invalidos'), findsOneWidget);
    expect(find.text('Empresas do TexFlow'), findsNothing);
  });

  testWidgets('admin desativa uma empresa e redefine a senha do dono', (
    tester,
  ) async {
    final (_, admin) = await _abrirLogin(tester);
    await _entrarComo(tester, 'admin.emee18', '123456');

    await tester.tap(find.text('Confecções Alfa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desativar empresa'));
    await tester.pumpAndSettle();
    expect(admin.alteracoes, ['Confecções Alfa=false']);
    expect(find.text('Empresa desativada'), findsOneWidget);

    await tester.tap(find.text('Malhas Beta'));
    await tester.pumpAndSettle();
    expect(find.text('Reativar empresa'), findsOneWidget);
    await tester.tap(find.text('Redefinir senha do primeiro usuário'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123');
    await tester.tap(find.text('Redefinir'));
    await tester.pumpAndSettle();
    expect(admin.senhas, isEmpty);

    await tester.enterText(find.byType(TextFormField), 'nova123');
    await tester.tap(find.text('Redefinir'));
    await tester.pumpAndSettle();
    expect(admin.senhas, ['Malhas Beta=nova123']);
  });

  testWidgets('admin cadastra uma empresa com o primeiro usuário', (
    tester,
  ) async {
    final (_, admin) = await _abrirLogin(tester);
    await _entrarComo(tester, 'admin.emee18', '123456');

    await tester.tap(find.text('Nova empresa'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cadastrar empresa'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o nome da empresa'), findsOneWidget);
    expect(admin.criadas, isEmpty);

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Têxtil Gama');
    await tester.enterText(campos.at(2), 'Carla Dona');
    await tester.enterText(campos.at(3), 'carla@gama.com');
    await tester.enterText(campos.at(4), 'Senha123!');
    await tester.tap(find.text('Cadastrar empresa'));
    await tester.pumpAndSettle();

    expect(admin.criadas, ['Têxtil Gama|Carla Dona|carla@gama.com|Senha123!']);
    expect(find.text('Empresa cadastrada'), findsOneWidget);
  });
}
