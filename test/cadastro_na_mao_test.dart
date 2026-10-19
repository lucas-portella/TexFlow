import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/pages/new_order_page.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';
import 'package:texflow/routes/app_router.dart';

class _Modelos extends ModeloProvider {
  final List<Referencia> lista = [];

  @override
  List<Referencia> get modelos => lista;

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> salvar({
    int? id,
    required String nome,
    required List<int> etapaIds,
    bool ativo = true,
  }) async {
    lista.add(Referencia(id: lista.length + 5, nome: nome, ativo: ativo));
    notifyListeners();
  }
}

class _Etapas extends EtapaProvider {
  @override
  List<Etapa> get etapas => const [];

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}
}

class _Funcionarios extends FuncionarioProvider {
  @override
  Future<void> carregar() async {}
}

Future<_Modelos> _abrir(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final modelos = _Modelos();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewOperationPageProvider()),
        ChangeNotifierProvider<ModeloProvider>.value(value: modelos),
        ChangeNotifierProvider<EtapaProvider>.value(value: _Etapas()),
        ChangeNotifierProvider<FuncionarioProvider>.value(
          value: _Funcionarios(),
        ),
      ],
      child: MaterialApp(
        routes: AppRouter.routes,
        home: const NovoPedidoPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return modelos;
}

void main() {
  testWidgets('sem modelos, o próprio pedido avisa e oferece o cadastro', (
    tester,
  ) async {
    await _abrir(tester);

    expect(find.text('Não há modelos cadastrados.'), findsOneWidget);
    expect(find.text('Cadastrar modelo'), findsOneWidget);
    expect(
      find.text('Ao escolher o modelo, as etapas aparecem aqui.'),
      findsNothing,
    );
  });

  testWidgets('a lista de modelos vazia também leva ao cadastro', (
    tester,
  ) async {
    await _abrir(tester);

    await tester.tap(find.text('Selecione o modelo'));
    await tester.pumpAndSettle();

    expect(find.text('Não há modelos cadastrados.'), findsNWidgets(2));
    expect(find.widgetWithText(FilledButton, 'Cadastrar modelo'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Cadastrar modelo'));
    await tester.pumpAndSettle();

    expect(find.text('Novo modelo'), findsOneWidget);
  });

  testWidgets(
    'cadastra o modelo sem etapas, volta ao pedido já escolhido e sem perder o que foi digitado',
    (tester) async {
      await _abrir(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Ex.: 4521'), '4521');
      await tester.enterText(find.widgetWithText(TextField, '0,00'), '5,50');

      await tester.tap(find.text('Cadastrar modelo'));
      await tester.pumpAndSettle();
      expect(find.text('Novo modelo'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Camisa');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar modelo'));
      await tester.pumpAndSettle();

      expect(find.text('Novo modelo'), findsNothing);
      expect(find.text('Alterar Pedido'), findsNothing);
      expect(find.text('Camisa'), findsOneWidget);
      expect(find.text('Não há modelos cadastrados.'), findsNothing);
      expect(
        find.text('Este modelo não tem etapas. Adicione abaixo.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(OutlinedButton, 'Adicionar etapa'), findsOneWidget);
      expect(find.widgetWithText(TextField, '4521'), findsOneWidget);
      expect(find.widgetWithText(TextField, '5,50'), findsOneWidget);
    },
  );

  testWidgets('sem etapas cadastradas, o pedido já abre no cadastro de etapa nova', (
    tester,
  ) async {
    final modelos = await _abrir(tester);
    modelos.lista.add(Referencia(id: 1, nome: 'Camisa'));
    modelos.notifyListeners();

    await tester.tap(find.text('Selecione o modelo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camisa'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Adicionar etapa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Adicionar etapa'));
    await tester.pumpAndSettle();

    expect(find.text('NOME DA ETAPA'), findsOneWidget);
    final botao = tester.widget<SegmentedButton<bool>>(
      find.byType(SegmentedButton<bool>),
    );
    expect(botao.selected, {true});
  });
}
