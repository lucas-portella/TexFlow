import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/pages/settings_page.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_router.dart';
import 'package:texflow/routes/app_routes.dart';

class FakeUsuarioProvider extends UsuarioProvider {
  Usuario? _logado = Usuario(
    idUsuario: 1,
    nome: 'Ana Carvalho',
    email: 'ana@texflow.com',
    senha: '',
    tipo: UserType.GESTOR,
  );
  final List<List<String>> trocas = [];
  int logouts = 0;

  @override
  Usuario? get usuario => _logado;

  @override
  bool get logado => _logado != null;

  @override
  Future<void> alterarSenha(String senhaAtual, String novaSenha) async {
    trocas.add([senhaAtual, novaSenha]);
  }

  @override
  Future<void> logout() async {
    logouts++;
    _logado = null;
    notifyListeners();
  }
}

Future<FakeUsuarioProvider> _abrirConfiguracoes(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final usuario = FakeUsuarioProvider();

  await tester.pumpWidget(
    ChangeNotifierProvider<UsuarioProvider>.value(
      value: usuario,
      child: MaterialApp(
        routes: {
          ...AppRouter.routes,
          AppRoutes.login: (context) => const Text('Tela de login'),
        },
        home: const SettingsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return usuario;
}

void main() {
  testWidgets('configurações: mostra o usuário logado', (tester) async {
    await _abrirConfiguracoes(tester);

    expect(find.text('Ana Carvalho'), findsOneWidget);
    expect(find.text('Alterar senha'), findsOneWidget);
    expect(find.text('Cadastrar usuário'), findsOneWidget);
  });

  testWidgets('configurações: sair volta para o login', (tester) async {
    final usuario = await _abrirConfiguracoes(tester);

    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    expect(usuario.logouts, 1);
    expect(find.text('Tela de login'), findsOneWidget);
  });

  testWidgets('alterar senha: valida os campos e confirma a nova senha', (
    tester,
  ) async {
    final usuario = await _abrirConfiguracoes(tester);

    await tester.tap(find.text('Alterar senha'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Alterar senha'));
    await tester.pumpAndSettle();
    expect(find.text('Informe a senha atual'), findsOneWidget);
    expect(
      find.text('A senha precisa ter pelo menos 6 caracteres'),
      findsOneWidget,
    );

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Antiga@1');
    await tester.enterText(campos.at(1), 'Nova@123');
    await tester.enterText(campos.at(2), 'Outra@123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Alterar senha'));
    await tester.pumpAndSettle();
    expect(find.text('As senhas não conferem'), findsOneWidget);
    expect(usuario.trocas, isEmpty);

    await tester.enterText(campos.at(2), 'Nova@123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Alterar senha'));
    await tester.pumpAndSettle();

    expect(usuario.trocas, [
      ['Antiga@1', 'Nova@123'],
    ]);
    expect(find.text('Senha alterada com sucesso'), findsOneWidget);
    expect(find.text('Cadastrar usuário'), findsOneWidget);
  });

  testWidgets('cadastrar usuário: valida os campos e mostra o perfil', (
    tester,
  ) async {
    await _abrirConfiguracoes(tester);

    await tester.tap(find.text('Cadastrar usuário'));
    await tester.pumpAndSettle();

    expect(find.text('Operador'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pumpAndSettle();
    expect(find.text('Digite o nome'), findsOneWidget);
    expect(find.text('Digite um e-mail válido'), findsOneWidget);
    expect(
      find.text('A senha precisa ter pelo menos 6 caracteres'),
      findsOneWidget,
    );

    await tester.tap(find.text('Operador'));
    await tester.pumpAndSettle();
    expect(find.text('Supervisor'), findsOneWidget);
  });
}
