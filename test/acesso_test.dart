import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/pages/settings_page.dart';
import 'package:texflow/providers/preferencias_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_router.dart';
import 'package:texflow/services/api_client.dart';

class FakeUsuarioProvider extends UsuarioProvider {
  final Usuario _dado;

  FakeUsuarioProvider(this._dado);

  @override
  Usuario? get usuario => _dado;
}

Usuario _usuario({
  required UserType tipo,
  bool dono = false,
  Set<Modulo> modulos = const {},
}) {
  return Usuario(
    idUsuario: 1,
    nome: 'Ana Carvalho',
    email: 'ana@texflow.com',
    senha: '',
    tipo: tipo,
    donoDaEmpresa: dono,
    modulos: modulos,
  );
}

Future<void> _abrir(WidgetTester tester, Usuario usuario) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UsuarioProvider>.value(
          value: FakeUsuarioProvider(usuario),
        ),
        ChangeNotifierProvider(create: (_) => PreferenciasProvider()),
      ],
      child: MaterialApp(routes: AppRouter.routes, home: const SettingsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('Usuario lê token, empresa e se é o dono da empresa', () {
    final usuario = Usuario.fromMap({
      'idUsuario': 3,
      'nome': 'Bia',
      'email': 'bia@x.com',
      'tipo': 'GESTOR',
      'token': 'abc.def.ghi',
      'empresaId': 9,
      'donoDaEmpresa': true,
    });

    expect(usuario.token, 'abc.def.ghi');
    expect(usuario.empresaId, 9);
    expect(usuario.donoDaEmpresa, isTrue);
    expect(usuario.ehAdm, isTrue);
    expect(Usuario.fromMap(usuario.toMap()).token, 'abc.def.ghi');

    final operador = Usuario.fromMap({
      'idUsuario': 4,
      'nome': 'Caio',
      'email': 'caio@x.com',
      'tipo': 'OPERADOR',
    });
    expect(operador.donoDaEmpresa, isFalse);
    expect(operador.ehAdm, isFalse);
  });

  test('Sessao guarda o token para as chamadas', () {
    Sessao.token = 'meu-token';
    expect(Sessao.token, 'meu-token');
    Sessao.token = null;
  });

  testWidgets('primeiro usuário da empresa vê tudo', (tester) async {
    await _abrir(
      tester,
      _usuario(
        tipo: UserType.GESTOR,
        dono: true,
        modulos: Modulo.values.toSet(),
      ),
    );

    expect(find.text('Minha empresa'), findsOneWidget);
    expect(find.text('Modo de operação'), findsOneWidget);
    expect(find.text('Usuários'), findsOneWidget);
  });

  testWidgets('outro ADM não vê o cadastro da empresa', (tester) async {
    await _abrir(
      tester,
      _usuario(
        tipo: UserType.GESTOR,
        modulos: {Modulo.usuarios, Modulo.etapas, Modulo.modoOperacao},
      ),
    );

    expect(find.text('Minha empresa'), findsNothing);
    expect(find.text('Modo de operação'), findsOneWidget);
    expect(find.text('Usuários'), findsOneWidget);
    expect(find.text('Atalhos da tela inicial'), findsOneWidget);
  });

  testWidgets('cada item das configurações depende só do acesso liberado', (
    tester,
  ) async {
    await _abrir(
      tester,
      _usuario(tipo: UserType.GESTOR, modulos: {Modulo.etapas}),
    );

    expect(find.text('Modo de operação'), findsNothing);
    expect(find.text('Usuários'), findsNothing);
    expect(find.text('Minha empresa'), findsNothing);
    expect(find.text('Atalhos da tela inicial'), findsOneWidget);
  });

  testWidgets('operador só vê o que é dele', (tester) async {
    await _abrir(tester, _usuario(tipo: UserType.OPERADOR));

    expect(find.text('Minha empresa'), findsNothing);
    expect(find.text('Modo de operação'), findsNothing);
    expect(find.text('Usuários'), findsNothing);
    expect(find.text('Atalhos da tela inicial'), findsOneWidget);
    expect(find.text('Alterar senha'), findsOneWidget);
  });
}
