import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/minha_empresa.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/pages/cadastro_usuario_page.dart';
import 'package:texflow/pages/clientes_page.dart';
import 'package:texflow/pages/minha_empresa_page.dart';
import 'package:texflow/pages/new_order_page.dart';
import 'package:texflow/pages/settings_page.dart';
import 'package:texflow/providers/atalhos_provider.dart';
import 'package:texflow/providers/cliente_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/minha_empresa_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';
import 'package:texflow/providers/preferencias_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/shared/production_card.dart';

class FakeMinhaEmpresaProvider extends MinhaEmpresaProvider {
  MinhaEmpresa? atual;
  final List<MinhaEmpresa> salvas = [];

  FakeMinhaEmpresaProvider({this.atual});

  @override
  MinhaEmpresa? get empresa => atual;

  @override
  bool get carregando => false;

  @override
  String? get erro => null;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> salvar(MinhaEmpresa empresa) async {
    salvas.add(empresa);
    atual = empresa;
  }
}

class FakeClienteProvider extends ClienteProvider {
  @override
  List<Empresa> get clientes => [
    Empresa(id: 1, cnpj: '12.345.678/0001-90', nomeFantasia: 'Moda João'),
    Empresa(id: 2, cnpj: '98.765.432/0001-10', nomeFantasia: 'Baby Chic'),
  ];

  @override
  bool get carregando => false;

  @override
  String? get erro => null;

  @override
  Future<void> carregar() async {}
}

class FakeNovoPedidoProvider extends NewOperationPageProvider {
  @override
  Future<List<Empresa>> listarEmpresas() async => [
    Empresa(id: 1, cnpj: '12.345.678/0001-90', nomeFantasia: 'Moda João'),
    Empresa(id: 2, cnpj: '98.765.432/0001-10', nomeFantasia: 'Alfa Costuras'),
  ];
}

class FakeModeloProvider extends ModeloProvider {
  @override
  Future<void> carregar() async {}
}

class FakeFuncionarioProvider extends FuncionarioProvider {
  @override
  Future<void> carregar() async {}
}

class FakeUsuarioProvider extends UsuarioProvider {
  @override
  Usuario? get usuario => Usuario(
    idUsuario: 1,
    nome: 'Ana Carvalho',
    email: 'ana@texflow.com',
    senha: '',
    tipo: UserType.GESTOR,
    modulos: Modulo.values.toSet(),
    cargo: 'Gerente de produção',
    donoDaEmpresa: true,
  );
}

void _tamanho(WidgetTester tester, Size tamanho) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('minha empresa: exige o nome e salva os dados', (tester) async {
    _tamanho(tester, const Size(800, 2400));
    final provider = FakeMinhaEmpresaProvider(
      atual: MinhaEmpresa(nomeFantasia: 'Alfa', cidade: 'Blumenau'),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<MinhaEmpresaProvider>.value(
        value: provider,
        child: const MaterialApp(home: MinhaEmpresaPage()),
      ),
    );
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    expect(find.text('Alfa'), findsOneWidget);
    expect(find.text('Blumenau'), findsOneWidget);

    await tester.enterText(campos.at(0), '');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o nome da empresa'), findsOneWidget);
    expect(provider.salvas, isEmpty);

    await tester.enterText(campos.at(0), 'Alfa Confecções');
    await tester.enterText(campos.at(2), '12.345.678/0001-90');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(provider.salvas.single.nomeFantasia, 'Alfa Confecções');
    expect(provider.salvas.single.cnpj, '12.345.678/0001-90');
    expect(provider.salvas.single.razaoSocial, isNull);
    expect(provider.salvas.single.cidade, 'Blumenau');
    expect(find.text('Dados da empresa salvos'), findsOneWidget);
  });

  testWidgets('clientes: lista os clientes cadastrados', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ClienteProvider>.value(
        value: FakeClienteProvider(),
        child: const MaterialApp(home: ClientesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Moda João'), findsOneWidget);
    expect(find.text('98.765.432/0001-10'), findsOneWidget);
  });

  testWidgets(
    'configurações: rola sem estourar e tem minha empresa e atalhos',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      _tamanho(tester, const Size(480, 700));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UsuarioProvider>.value(
              value: FakeUsuarioProvider(),
            ),
            ChangeNotifierProvider(create: (_) => PreferenciasProvider()),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gerente de produção'), findsOneWidget);
      expect(find.text('Minha empresa'), findsOneWidget);
      expect(find.text('Modo de operação'), findsOneWidget);
      expect(find.text('Por status'), findsOneWidget);
      expect(find.text('Atalhos da tela inicial'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Sair da conta'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Sair da conta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cadastrar usuário: tem o campo de cargo', (tester) async {
    _tamanho(tester, const Size(800, 2000));

    await tester.pumpWidget(
      ChangeNotifierProvider<UsuarioProvider>.value(
        value: FakeUsuarioProvider(),
        child: const MaterialApp(home: CadastroUsuarioPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CARGO'), findsOneWidget);
    expect(find.text('ACESSOS'), findsOneWidget);
    expect(find.text('Custos'), findsOneWidget);
  });

  testWidgets('card da produção mostra número, data e peças solicitadas', (
    tester,
  ) async {
    final operacao = Operacao.fromMap({
      'id': 11,
      'numero': '4521',
      'status': 'concluido',
      'dataEntrega': '2026-10-31',
      'quantidadeSolicitada': 1000,
      'referencia': {'id': 1, 'nome': 'Blusa Cumprida'},
      'cliente': {'id': 1, 'cnpj': '1', 'nomeFantasia': 'Vestuario Nobre SA'},
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductionCard(operacao: operacao)),
      ),
    );

    expect(find.text('OP-4521'), findsOneWidget);
    expect(find.textContaining('31/10/2026'), findsOneWidget);
    expect(find.textContaining('1000 peças'), findsOneWidget);
    expect(find.text('0 peças'), findsNothing);
  });

  testWidgets('novo pedido: número do pedido e seleção de cliente com busca', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _tamanho(tester, const Size(800, 3000));
    final provider = FakeNovoPedidoProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NewOperationPageProvider>.value(
            value: provider,
          ),
          ChangeNotifierProvider<ModeloProvider>.value(
            value: FakeModeloProvider(),
          ),
          ChangeNotifierProvider<FuncionarioProvider>.value(
            value: FakeFuncionarioProvider(),
          ),
          ChangeNotifierProvider(create: (_) => AtalhosProvider()),
        ],
        child: const MaterialApp(home: NovoPedidoPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NÚMERO DO PEDIDO'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Ex.: 4521'), '4521');
    expect(provider.numero, '4521');

    await tester.tap(find.text('Selecione o cliente'));
    await tester.pumpAndSettle();
    expect(find.text('Selecionar cliente'), findsOneWidget);
    expect(find.text('Moda João'), findsOneWidget);
    expect(find.text('Alfa Costuras'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'alfa');
    await tester.pumpAndSettle();
    expect(find.text('Moda João'), findsNothing);

    await tester.tap(find.text('Alfa Costuras'));
    await tester.pumpAndSettle();

    expect(provider.cliente!.nomeFantasia, 'Alfa Costuras');
    expect(find.text('98.765.432/0001-10'), findsOneWidget);
  });
}
