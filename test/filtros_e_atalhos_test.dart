import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/filtro_operacoes.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/pages/atalhos_page.dart';
import 'package:texflow/pages/search_page.dart';
import 'package:texflow/providers/atalhos_provider.dart';
import 'package:texflow/providers/operacao_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_bottom_nav.dart';

Operacao _op(
  int id, {
  String? numero,
  String status = 'emAndamento',
  String cliente = 'Moda João',
  int modeloId = 1,
  String modelo = 'Blusa',
  String entrega = '2026-10-15',
  String? finalizacao,
  int? solicitadas,
  int? produzidas,
}) {
  return Operacao.fromMap({
    'id': id,
    'numero': numero,
    'status': status,
    'referencia': {'id': modeloId, 'nome': modelo},
    'cliente': {
      'id': cliente.hashCode.abs() % 1000,
      'cnpj': '1',
      'nomeFantasia': cliente,
    },
    'dataEntrega': entrega,
    'dataFinalizacao': finalizacao,
    'quantidadeSolicitada': solicitadas,
    'quantidadeProduzida': produzidas,
  });
}

class FakeOperacaoProvider extends OperacaoProvider {
  final List<Operacao> lista;

  FakeOperacaoProvider(this.lista);

  @override
  List<Operacao> get operacoes => lista;

  @override
  bool get carregando => false;

  @override
  String? get erro => null;

  @override
  Future<void> carregar() async {}
}

class FakeUsuarioProvider extends UsuarioProvider {
  final UserType tipo;

  FakeUsuarioProvider({this.tipo = UserType.GESTOR});

  @override
  Usuario? get usuario => Usuario(
    idUsuario: 1,
    nome: 'Ana',
    email: 'ana@texflow.com',
    senha: '',
    tipo: tipo,
    modulos: tipo == UserType.GESTOR ? Modulo.values.toSet() : <Modulo>{},
  );
}

void main() {
  group('Operacao', () {
    test('o código usa o número do pedido, ou o id quando não tem', () {
      expect(_op(7, numero: '4521').codigo, 'OP-4521');
      expect(_op(7).codigo, 'OP-7');
    });

    test('peças: produzidas, senão solicitadas, senão a grade', () {
      expect(_op(1, solicitadas: 100, produzidas: 90).pecas, 90);
      expect(_op(1, solicitadas: 100).pecas, 100);
      expect(_op(1).pecas, 0);
    });

    test('progresso sem grade usa as etapas concluídas', () {
      final operacao = Operacao.fromMap({
        'id': 1,
        'status': 'emAndamento',
        'processos': [
          {'descricao': 'A', 'status': 'concluido'},
          {'descricao': 'B', 'status': 'naoIniciado'},
        ],
      });

      expect(operacao.progresso, 0.5);
      expect(_op(2).progresso, isNull);
    });
  });

  group('FiltroOperacoes', () {
    final operacoes = [
      _op(
        1,
        numero: '4521',
        status: 'concluido',
        finalizacao: '2026-10-03',
        entrega: '2026-09-28',
      ),
      _op(
        2,
        numero: '4522',
        cliente: 'Baby Chic',
        modelo: 'Camisa',
        modeloId: 2,
      ),
      _op(3, status: 'concluido', finalizacao: '2026-11-02'),
      _op(4, entrega: '2026-10-30', status: 'naoIniciado'),
    ];

    List<int> ids(FiltroOperacoes filtro) =>
        filtro.aplicar(operacoes).map((o) => o.id).toList();

    test('sem filtro traz tudo', () {
      expect(ids(const FiltroOperacoes()), [1, 2, 3, 4]);
      expect(const FiltroOperacoes().temFiltro, isFalse);
    });

    test('status', () {
      expect(ids(const FiltroOperacoes(status: Status.concluido)), [1, 3]);
    });

    test('mês usa a finalização, ou a entrega se ainda está aberta', () {
      expect(ids(FiltroOperacoes(mes: DateTime(2026, 10))), [1, 2, 4]);
      expect(ids(FiltroOperacoes(mes: DateTime(2026, 11))), [3]);
      expect(ids(FiltroOperacoes(mes: DateTime(2026, 9))), isEmpty);
    });

    test('modelo, cliente e texto', () {
      expect(ids(const FiltroOperacoes(modeloId: 2)), [2]);
      expect(ids(const FiltroOperacoes(texto: 'baby')), [2]);
      expect(ids(const FiltroOperacoes(texto: '4521')), [1]);
      expect(ids(const FiltroOperacoes(texto: 'op-4522')), [2]);
    });

    test('filtros combinados e limpar', () {
      final filtro = FiltroOperacoes(
        mes: DateTime(2026, 10),
        status: Status.concluido,
      );
      expect(ids(filtro), [1]);
      expect(filtro.quantidadeAtivos, 2);
      expect(filtro.copiarCom(limparStatus: true).quantidadeAtivos, 1);
      expect(filtro.semFiltros.temFiltro, isFalse);
    });
  });

  group('AtalhosProvider', () {
    test('começa no padrão e troca sem repetir atalhos', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = AtalhosProvider();
      await provider.carregar();

      expect(provider.ids, ['inicio', 'pesquisa', 'clientes', 'configuracoes']);

      await provider.trocar(2, 'modelos');
      expect(provider.ids, ['inicio', 'pesquisa', 'modelos', 'configuracoes']);

      await provider.trocar(0, 'configuracoes');
      expect(provider.ids, ['configuracoes', 'pesquisa', 'modelos', 'inicio']);
    });

    test('guarda a escolha e restaura o padrão', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = AtalhosProvider();
      await provider.trocar(3, 'fechamento');

      final outro = AtalhosProvider();
      await outro.carregar();
      expect(outro.ids.last, 'fechamento');

      await outro.restaurarPadrao();
      expect(outro.ids, ['inicio', 'pesquisa', 'clientes', 'configuracoes']);
    });

    test('ignora o que foi salvo com atalho que não existe mais', () async {
      SharedPreferences.setMockInitialValues({
        'atalhos_rapidos': ['inicio', 'pesquisa', 'xpto', 'configuracoes'],
      });
      final provider = AtalhosProvider();
      await provider.carregar();

      expect(provider.ids, ['inicio', 'pesquisa', 'clientes', 'configuracoes']);
    });
  });

  testWidgets('pesquisa: filtra por status, período e limpa', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OperacaoProvider>.value(
            value: FakeOperacaoProvider([
              _op(1, status: 'concluido', finalizacao: '2026-10-03'),
              _op(2, cliente: 'Baby Chic', modelo: 'Camisa', modeloId: 2),
              _op(
                3,
                status: 'concluido',
                finalizacao: '2026-11-02',
                cliente: 'Casa Mod',
              ),
            ]),
          ),
          ChangeNotifierProvider(create: (_) => AtalhosProvider()),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 produções'), findsOneWidget);
    expect(find.text('Limpar filtros'), findsNothing);

    await tester.tap(find.text('Status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluído').last);
    await tester.pumpAndSettle();
    expect(find.text('2 produções'), findsOneWidget);
    expect(find.text('Baby Chic'), findsNothing);

    await tester.tap(find.text('Período'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Out'));
    await tester.pumpAndSettle();
    expect(find.text('1 produção'), findsOneWidget);
    expect(find.text('Casa Mod'), findsNothing);
    expect(find.text('Limpar filtros'), findsOneWidget);

    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();
    expect(find.text('3 produções'), findsOneWidget);
  });

  testWidgets('pesquisa: filtra por modelo e cliente tirados das produções', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OperacaoProvider>.value(
            value: FakeOperacaoProvider([
              _op(1),
              _op(2, cliente: 'Baby Chic', modelo: 'Camisa', modeloId: 2),
            ]),
          ),
          ChangeNotifierProvider(create: (_) => AtalhosProvider()),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Modelo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camisa'));
    await tester.pumpAndSettle();
    expect(find.text('1 produção'), findsOneWidget);
    expect(find.text('Baby Chic'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(find.text('2 produções'), findsOneWidget);

    await tester.tap(find.text('Cliente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moda João').last);
    await tester.pumpAndSettle();
    expect(find.text('1 produção'), findsOneWidget);
  });

  testWidgets('atalhos: trocar um atalho muda a barra de baixo', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final atalhos = AtalhosProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AtalhosProvider>.value(value: atalhos),
          ChangeNotifierProvider<UsuarioProvider>.value(
            value: FakeUsuarioProvider(),
          ),
        ],
        child: MaterialApp(
          routes: {AppRoutes.atalhos: (context) => const AtalhosPage()},
          home: const Scaffold(
            bottomNavigationBar: AppBottomNav(current: AppRoutes.dashboard),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Modelos'), findsNothing);

    atalhos.trocar(2, 'modelos');
    await tester.pumpAndSettle();
    expect(find.text('Modelos'), findsOneWidget);
    expect(find.text('Clientes'), findsNothing);
  });

  testWidgets(
    'atalhos: tela mostra as opções e operador não vê as de supervisor',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> abrir(UserType tipo) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AtalhosProvider()),
              ChangeNotifierProvider<UsuarioProvider>.value(
                value: FakeUsuarioProvider(tipo: tipo),
              ),
            ],
            child: const MaterialApp(home: AtalhosPage()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Atalho 3'));
        await tester.pumpAndSettle();
      }

      await abrir(UserType.GESTOR);
      expect(find.text('Fechamento'), findsOneWidget);
      expect(find.text('Modelos'), findsOneWidget);
      await tester.tap(find.text('Modelos'));
      await tester.pumpAndSettle();
      expect(find.text('Modelos'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
      await abrir(UserType.OPERADOR);
      expect(find.text('Fechamento'), findsNothing);
      expect(find.text('Modelos'), findsNothing);
      expect(find.text('Pesquisa'), findsWidgets);
    },
  );
}
