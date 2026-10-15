import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/pages/etapas_page.dart';
import 'package:texflow/pages/fechamento_page.dart';
import 'package:texflow/pages/funcionarios_page.dart';
import 'package:texflow/pages/modelo_form_page.dart';
import 'package:texflow/pages/modelos_page.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/providers/fechamento_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/routes/app_routes.dart';

class FakeEtapaProvider extends EtapaProvider {
  final List<Etapa> lista = [
    Etapa(id: 1, nome: 'Manga', valorComissao: 0.3),
    Etapa(id: 2, nome: 'Gola', valorComissao: 0.5),
    Etapa(id: 3, nome: 'Lateral', valorComissao: 0.3),
  ];
  final List<Map<String, dynamic>> salvos = [];

  @override
  List<Etapa> get etapas => lista;

  @override
  bool get carregando => false;

  @override
  String? get erro => null;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> salvar({
    int? id,
    required String nome,
    required double valorComissao,
  }) async {
    salvos.add({'id': id, 'nome': nome, 'valor': valorComissao});
  }
}

class FakeFuncionarioProvider extends FuncionarioProvider {
  final List<Funcionario> lista = [
    Funcionario(id: 1, nome: 'João Costureiro'),
    Funcionario(id: 2, nome: 'Maria Cortadora', ativo: false),
  ];
  final List<Map<String, dynamic>> salvos = [];

  @override
  List<Funcionario> get funcionarios => lista;

  @override
  bool get carregando => false;

  @override
  String? get erro => null;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> salvar({
    int? id,
    required String nome,
    required bool ativo,
  }) async {
    salvos.add({'id': id, 'nome': nome, 'ativo': ativo});
  }
}

class FakeModeloProvider extends ModeloProvider {
  final List<Referencia> lista = [
    Referencia(id: 2, nome: 'Camisa', ativo: false),
    Referencia(
      id: 1,
      nome: 'Blusa',
      etapas: [
        Etapa(id: 1, nome: 'Manga', valorComissao: 0.3),
        Etapa(id: 2, nome: 'Gola', valorComissao: 0.5),
      ],
    ),
  ];
  final List<Map<String, dynamic>> salvos = [];

  @override
  List<Referencia> get modelos => lista;

  @override
  bool get carregando => false;

  @override
  String? get erro => null;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> salvar({
    int? id,
    required String nome,
    required List<int> etapaIds,
    bool ativo = true,
  }) async {
    salvos.add({'id': id, 'nome': nome, 'etapaIds': etapaIds, 'ativo': ativo});
  }
}

class FakeFechamentoProvider extends FechamentoProvider {
  int mudancasDeMes = 0;

  @override
  Fechamento? get fechamento => Fechamento(
    mes: '2026-10',
    quantidadeOperacoes: 2,
    totalPecas: 1500,
    totalRecebido: 7000,
    totalRepasse: 700,
    lucro: 6300,
    repasses: [
      RepasseFuncionario(
        funcionarioId: 1,
        funcionario: 'João Costureiro',
        total: 700,
        operacoes: [
          RepasseOperacao(
            operacaoId: 7,
            cliente: 'Moda João',
            quantidade: 1000,
            total: 300,
            etapas: [
              RepasseEtapa(etapa: 'Manga', valorPorPeca: 0.3, total: 300),
            ],
          ),
          RepasseOperacao(
            operacaoId: 8,
            cliente: 'Baby Chic',
            quantidade: 500,
            total: 400,
            etapas: [
              RepasseEtapa(etapa: 'Gola', valorPorPeca: 0.5, total: 250),
              RepasseEtapa(etapa: 'Lateral', valorPorPeca: 0.3, total: 150),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  bool get carregando => false;

  @override
  String? get erro => null;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> mesAnterior() async {
    mudancasDeMes++;
  }
}

Future<void> _abrir(
  WidgetTester tester,
  Widget pagina, {
  EtapaProvider? etapas,
  FuncionarioProvider? funcionarios,
  ModeloProvider? modelos,
  FechamentoProvider? fechamento,
  Map<String, WidgetBuilder> rotas = const {},
}) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<EtapaProvider>.value(
          value: etapas ?? FakeEtapaProvider(),
        ),
        ChangeNotifierProvider<FuncionarioProvider>.value(
          value: funcionarios ?? FakeFuncionarioProvider(),
        ),
        ChangeNotifierProvider<ModeloProvider>.value(
          value: modelos ?? FakeModeloProvider(),
        ),
        ChangeNotifierProvider<FechamentoProvider>.value(
          value: fechamento ?? FakeFechamentoProvider(),
        ),
      ],
      child: MaterialApp(routes: rotas, home: pagina),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('etapas: lista com valor e valida o cadastro', (tester) async {
    final etapas = FakeEtapaProvider();
    await _abrir(tester, const EtapasPage(), etapas: etapas);

    expect(find.text('Manga'), findsOneWidget);
    expect(find.text('R\$ 0,30 por peça'), findsNWidgets(2));
    expect(find.text('R\$ 0,50 por peça'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o nome da etapa'), findsOneWidget);
    expect(find.text('Informe o valor da comissão'), findsOneWidget);

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Barra');
    await tester.enterText(campos.at(1), '1,25');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(etapas.salvos, [
      {'id': null, 'nome': 'Barra', 'valor': 1.25},
    ]);
  });

  testWidgets('etapas: tocar numa etapa abre a edição preenchida', (
    tester,
  ) async {
    final etapas = FakeEtapaProvider();
    await _abrir(tester, const EtapasPage(), etapas: etapas);

    await tester.tap(find.text('Gola'));
    await tester.pumpAndSettle();
    expect(find.text('Editar etapa'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(etapas.salvos, [
      {'id': 2, 'nome': 'Gola', 'valor': 0.5},
    ]);
  });

  testWidgets('funcionários: mostra inativo e salva novo', (tester) async {
    final funcionarios = FakeFuncionarioProvider();
    await _abrir(tester, const FuncionariosPage(), funcionarios: funcionarios);

    expect(find.text('João Costureiro'), findsOneWidget);
    expect(find.text('Inativo'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o nome do funcionário'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Ana Silva');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(funcionarios.salvos, [
      {'id': null, 'nome': 'Ana Silva', 'ativo': true},
    ]);
  });

  testWidgets('modelos: lista com as etapas de cada modelo', (tester) async {
    await _abrir(tester, const ModelosPage());

    expect(find.text('Blusa'), findsOneWidget);
    expect(find.text('Manga · Gola'), findsOneWidget);
    expect(find.text('Camisa'), findsOneWidget);
    expect(find.text('Inativo'), findsOneWidget);
  });

  testWidgets('modelo: inativar pelo formulário mantém as etapas', (
    tester,
  ) async {
    final modelos = FakeModeloProvider();
    await _abrir(
      tester,
      ModeloFormPage(modelo: modelos.lista.last),
      modelos: modelos,
    );

    expect(
      find.text('Modelos inativos não aparecem ao criar uma produção.'),
      findsOneWidget,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar modelo'));
    await tester.pumpAndSettle();

    expect(modelos.salvos, [
      {
        'id': 1,
        'nome': 'Blusa',
        'etapaIds': [1, 2],
        'ativo': false,
      },
    ]);
  });

  testWidgets('modelo: escolhe etapas do catálogo, remove e salva na ordem', (
    tester,
  ) async {
    final modelos = FakeModeloProvider();
    await _abrir(tester, const ModeloFormPage(), modelos: modelos);

    await tester.enterText(find.byType(TextFormField), 'Blusinha');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar modelo'));
    await tester.pumpAndSettle();
    expect(find.text('Adicione ao menos uma etapa'), findsOneWidget);

    await tester.tap(find.text('Adicionar etapa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lateral').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar etapa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manga').last);
    await tester.pumpAndSettle();

    expect(find.text('1. Lateral'), findsOneWidget);
    expect(find.text('2. Manga'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar modelo'));
    await tester.pumpAndSettle();

    expect(modelos.salvos, [
      {
        'id': null,
        'nome': 'Blusinha',
        'etapaIds': [3, 1],
        'ativo': true,
      },
    ]);
  });

  testWidgets('fechamento: totais, detalhe por funcionário e troca de mês', (
    tester,
  ) async {
    final fechamento = FakeFechamentoProvider();
    await _abrir(tester, const FechamentoPage(), fechamento: fechamento);

    expect(find.text('R\$ 7.000,00'), findsOneWidget);
    expect(find.text('2 produções finalizadas · 1500 peças'), findsOneWidget);
    expect(find.text('R\$ 700,00'), findsOneWidget);
    expect(find.text('R\$ 6.300,00'), findsOneWidget);
    expect(find.text('João Costureiro'), findsNothing);

    await tester.tap(find.text('Total a repassar'));
    await tester.pumpAndSettle();
    expect(find.text('João Costureiro'), findsOneWidget);
    expect(find.text('2 produções'), findsOneWidget);

    await tester.tap(find.text('João Costureiro'));
    await tester.pumpAndSettle();
    expect(find.text('Total a receber: R\$ 700,00'), findsOneWidget);
    expect(find.text('OP-8 · Baby Chic'), findsOneWidget);
    expect(find.text('Gola · R\$ 0,50 × 500'), findsOneWidget);
    expect(find.text('R\$ 250,00'), findsOneWidget);
    expect(find.text('R\$ 150,00'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mês anterior'));
    await tester.pumpAndSettle();
    expect(fechamento.mudancasDeMes, 1);
  });

  testWidgets('rotas dos cadastros existem', (tester) async {
    expect(AppRoutes.modelos, '/modelos');
    expect(AppRoutes.etapas, '/etapas');
    expect(AppRoutes.funcionarios, '/funcionarios');
    expect(AppRoutes.fechamento, '/fechamento');
  });
}
